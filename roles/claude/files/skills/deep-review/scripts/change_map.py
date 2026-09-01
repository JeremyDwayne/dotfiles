#!/usr/bin/env python3
"""Build a change map for a diff: changed files, changed identifiers, and every
place in the repo that references each identifier.

Usage:
  change_map.py <base-ref>            diff base-ref...HEAD (merge-base) in the current repo
  change_map.py --diff path.diff      use a saved unified diff instead of git
  change_map.py <base-ref> --json     machine-readable output

Run from the repository root. Requires git and ripgrep (rg); falls back to grep.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict

DEF_PATTERNS = [
    re.compile(r"^\s*(?:def|class|module|function|fn|func|struct|enum|interface|type|trait|impl)\s+(?:self\.)?([A-Za-z_][A-Za-z0-9_:.]*)"),
    re.compile(r"^\s*(?:async\s+)?(?:def|function)\s+([A-Za-z_][A-Za-z0-9_]*)"),
    re.compile(r"^\s*(?:public|private|protected|static|final|abstract|export|default|\s)*\s*(?:[A-Za-z_<>\[\],\s]+\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*\([^;]*\)\s*(?:\{|=>|:)?\s*$"),
    re.compile(r"^\s*(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][A-Za-z0-9_$]*)\s*=\s*(?:async\s*)?(?:\(|function|[A-Za-z_$][A-Za-z0-9_$]*\s*=>)"),
    re.compile(r"^\s*(?:scope|has_many|has_one|belongs_to|attr_accessor|attr_reader|attr_writer|validates?|before_action|after_commit|after_save|before_save|enum|delegate)\s+:?([A-Za-z_][A-Za-z0-9_?!]*)"),
    re.compile(r"^\s*(?:add_column|remove_column|rename_column|add_index|remove_index|add_reference|create_table|drop_table|change_column(?:_null|_default)?)\s+:([A-Za-z_][A-Za-z0-9_]*)\s*,\s*:?([A-Za-z_][A-Za-z0-9_]*)?"),
    re.compile(r"^\s*(?:get|post|put|patch|delete|resources?|namespace|match)\s+['\":]([A-Za-z_][A-Za-z0-9_/]*)"),
    re.compile(r"^\s*([A-Z][A-Z0-9_]{2,})\s*="),
    re.compile(r"ENV(?:\.fetch|\[)\s*\(?['\"]([A-Z][A-Z0-9_]+)['\"]"),
]

DEF_LINE_HINT = re.compile(r"^\s*(?:def|class|module|function|fn|func|struct|enum|interface|type|trait|impl|scope|has_many|has_one|belongs_to|attr_|validates?|before_|after_|add_|remove_|rename_|create_table|drop_table|change_column|get |post |put |patch |delete |resources?|namespace|export|const|let|var|public|private|protected|static|async)")

SIGNATURE_LINE = re.compile(r"^\s*(?:def|function|fn|func)\s+[A-Za-z_][A-Za-z0-9_.:]*\s*\(?.*\)?")

SKIP_DIRS = {".git", "node_modules", "vendor", "tmp", "log", "coverage", "dist", "build", ".bundle", "public/assets", "public/packs", "storage"}
SKIP_FILE_SUFFIXES = (".lock", "-lock.json", ".min.js", ".map", ".svg", ".png", ".jpg", ".jpeg", ".gif", ".ico", ".woff", ".woff2", ".ttf")

STOPWORDS = {
    "self", "this", "true", "false", "nil", "null", "none", "None", "True", "False",
    "new", "get", "set", "id", "name", "value", "data", "type", "index", "show", "create",
    "update", "destroy", "edit", "call", "run", "main", "init", "initialize", "test",
    "setup", "teardown", "change", "up", "down", "params", "user", "users", "item", "items", "result", "results",
}


def run(cmd, check=True):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if check and p.returncode != 0:
        sys.stderr.write(p.stderr)
        sys.exit(p.returncode)
    return p.stdout


def get_diff(base_ref):
    return run(["git", "diff", "-U0", "--no-color", "--find-renames", f"{base_ref}...HEAD"])


def parse_diff(diff_text):
    files = {}
    current = None
    for line in diff_text.splitlines():
        if line.startswith("diff --git"):
            m = re.match(r"diff --git a/(.*?) b/(.*)$", line)
            if m:
                current = m.group(2)
                files[current] = {"status": "modified", "old_path": m.group(1), "hunks": [], "added": [], "removed": []}
        elif current is None:
            continue
        elif line.startswith("new file mode"):
            files[current]["status"] = "added"
        elif line.startswith("deleted file mode"):
            files[current]["status"] = "deleted"
        elif line.startswith("rename from"):
            files[current]["status"] = "renamed"
        elif line.startswith("@@"):
            m = re.match(r"@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@ ?(.*)$", line)
            if m:
                files[current]["hunks"].append({
                    "old_start": int(m.group(1)),
                    "new_start": int(m.group(3)),
                    "context": m.group(5).strip(),
                })
        elif line.startswith("+") and not line.startswith("+++"):
            files[current]["added"].append(line[1:])
        elif line.startswith("-") and not line.startswith("---"):
            files[current]["removed"].append(line[1:])
    return files


def extract_identifiers(lines):
    found = set()
    for raw in lines:
        line = raw.rstrip()
        if not line.strip() or line.strip().startswith(("#", "//", "/*", "*", "--")):
            continue
        for pat in DEF_PATTERNS:
            m = pat.search(line)
            if m:
                for g in m.groups():
                    if g:
                        name = g.split(".")[-1].split("::")[-1]
                        if len(name) >= 3 and name not in STOPWORDS:
                            found.add(name)
    return found


def extract_hunk_context_symbols(hunks):
    found = set()
    for h in hunks:
        ctx = h["context"]
        if not ctx:
            continue
        for pat in DEF_PATTERNS:
            m = pat.search(ctx)
            if m:
                for g in m.groups():
                    if g:
                        name = g.split(".")[-1].split("::")[-1]
                        if len(name) >= 3 and name not in STOPWORDS:
                            found.add(name)
    return found


def signature_changed(file_info):
    added_sigs = {l.strip() for l in file_info["added"] if SIGNATURE_LINE.match(l)}
    removed_sigs = {l.strip() for l in file_info["removed"] if SIGNATURE_LINE.match(l)}
    changed = []
    for r in removed_sigs:
        name = re.sub(r"\s*\(.*$", "", r).split()[-1]
        for a in added_sigs:
            aname = re.sub(r"\s*\(.*$", "", a).split()[-1]
            if name == aname and r != a:
                changed.append({"name": name.split(".")[-1], "before": r, "after": a})
    return changed


def rg_available():
    return shutil.which("rg") is not None


def find_references(identifier, exclude_path=None, limit=200):
    word = re.escape(identifier)
    if rg_available():
        cmd = ["rg", "-n", "--no-heading", "-w", "--color", "never", "-S", word, "."]
        for d in SKIP_DIRS:
            cmd += ["-g", f"!{d}"]
    else:
        cmd = ["grep", "-rnw", "--color=never", identifier, "."]
        for d in SKIP_DIRS:
            cmd += [f"--exclude-dir={d}"]
    p = subprocess.run(cmd, capture_output=True, text=True)
    refs = []
    for line in p.stdout.splitlines():
        m = re.match(r"^\.?/?(.*?):(\d+):(.*)$", line)
        if not m:
            continue
        path, lineno, text = m.group(1), int(m.group(2)), m.group(3).strip()
        if path.endswith(SKIP_FILE_SUFFIXES):
            continue
        refs.append({"path": path, "line": lineno, "text": text[:200]})
        if len(refs) >= limit:
            break
    return refs


def classify_ref(path):
    p = path.lower()
    if re.search(r"(^|/)(spec|test|tests|__tests__)/|_spec\.|_test\.|\.test\.|\.spec\.", p):
        return "test"
    if "/jobs/" in p or "/workers/" in p or "/tasks/" in p or p.endswith(".rake"):
        return "job/task"
    if "/db/migrate/" in p:
        return "migration"
    if re.search(r"\.(erb|haml|slim|html|jsx|tsx|vue|svelte)$", p) or "/views/" in p:
        return "view"
    if "config/" in p:
        return "config"
    return "code"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("base_ref", nargs="?", help="git base ref (e.g. main, origin/main)")
    ap.add_argument("--diff", help="path to a unified diff file instead of git")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--max-refs", type=int, default=60, help="max references shown per identifier in text mode")
    args = ap.parse_args()

    if args.diff:
        with open(args.diff) as f:
            diff_text = f.read()
    elif args.base_ref:
        diff_text = get_diff(args.base_ref)
    else:
        ap.error("give a base ref or --diff")

    files = parse_diff(diff_text)
    if not files:
        print("No changes found in diff.")
        return

    changed_paths = set(files.keys())
    report = {"files": [], "identifiers": {}}
    all_idents = defaultdict(lambda: {"defined_in": set(), "kind": set()})

    for path, info in files.items():
        added_ids = extract_identifiers(info["added"])
        removed_ids = extract_identifiers(info["removed"])
        ctx_ids = extract_hunk_context_symbols(info["hunks"])
        sig = signature_changed(info)
        entry = {
            "path": path,
            "status": info["status"],
            "added_lines": len(info["added"]),
            "removed_lines": len(info["removed"]),
            "hunks": len(info["hunks"]),
            "identifiers_added": sorted(added_ids - removed_ids),
            "identifiers_removed": sorted(removed_ids - added_ids),
            "identifiers_modified": sorted(added_ids & removed_ids),
            "enclosing_symbols_touched": sorted(ctx_ids - added_ids - removed_ids),
            "signature_changes": sig,
        }
        report["files"].append(entry)
        for i in added_ids - removed_ids:
            all_idents[i]["defined_in"].add(path); all_idents[i]["kind"].add("added")
        for i in removed_ids - added_ids:
            all_idents[i]["defined_in"].add(path); all_idents[i]["kind"].add("removed")
        for i in added_ids & removed_ids:
            all_idents[i]["defined_in"].add(path); all_idents[i]["kind"].add("modified")
        for i in ctx_ids - added_ids - removed_ids:
            all_idents[i]["defined_in"].add(path); all_idents[i]["kind"].add("body-changed")
        for s in sig:
            all_idents[s["name"]]["defined_in"].add(path); all_idents[s["name"]]["kind"].add("signature-changed")

    in_repo = os.path.isdir(".git") or subprocess.run(["git", "rev-parse", "--is-inside-work-tree"], capture_output=True).returncode == 0

    for ident, meta in sorted(all_idents.items()):
        refs = find_references(ident) if in_repo else []
        outside = [r for r in refs if r["path"] not in changed_paths]
        inside = [r for r in refs if r["path"] in changed_paths]
        report["identifiers"][ident] = {
            "kind": sorted(meta["kind"]),
            "defined_in": sorted(meta["defined_in"]),
            "refs_outside_diff": outside,
            "refs_inside_diff_count": len(inside),
        }

    if args.json:
        json.dump(report, sys.stdout, indent=2)
        return

    print("=" * 78)
    print("CHANGE MAP")
    print("=" * 78)
    print(f"\nFiles changed: {len(report['files'])}\n")
    for f in report["files"]:
        print(f"[{f['status']}] {f['path']}  (+{f['added_lines']} -{f['removed_lines']}, {f['hunks']} hunks)")
        if f["identifiers_added"]:
            print(f"    added:     {', '.join(f['identifiers_added'])}")
        if f["identifiers_removed"]:
            print(f"    removed:   {', '.join(f['identifiers_removed'])}")
        if f["identifiers_modified"]:
            print(f"    modified:  {', '.join(f['identifiers_modified'])}")
        if f["enclosing_symbols_touched"]:
            print(f"    body of:   {', '.join(f['enclosing_symbols_touched'])}")
        for s in f["signature_changes"]:
            print(f"    SIGNATURE CHANGED {s['name']}:")
            print(f"        - {s['before']}")
            print(f"        + {s['after']}")

    print("\n" + "=" * 78)
    print("INVESTIGATION QUEUE  (every identifier, every reference outside the diff)")
    print("=" * 78)
    if not in_repo:
        print("\nNot inside a git repo: reference search skipped. Trace by hand.\n")

    ranked = sorted(report["identifiers"].items(), key=lambda kv: (-len(kv[1]["refs_outside_diff"]), kv[0]))
    for ident, meta in ranked:
        refs = meta["refs_outside_diff"]
        flag = ""
        if "removed" in meta["kind"] and refs:
            flag = "  <<< REMOVED BUT STILL REFERENCED"
        elif "signature-changed" in meta["kind"] and refs:
            flag = "  <<< SIGNATURE CHANGED, CHECK EVERY CALLER"
        print(f"\n{ident}  [{', '.join(meta['kind'])}]  defined in {', '.join(meta['defined_in'])}")
        print(f"  {len(refs)} reference(s) outside the diff, {meta['refs_inside_diff_count']} inside{flag}")
        by_class = defaultdict(list)
        for r in refs:
            by_class[classify_ref(r["path"])].append(r)
        shown = 0
        for cls in ["code", "job/task", "view", "config", "migration", "test"]:
            for r in by_class.get(cls, []):
                if shown >= args.max_refs:
                    break
                print(f"    [{cls:9}] {r['path']}:{r['line']}  {r['text']}")
                shown += 1
        if len(refs) > shown:
            print(f"    ... {len(refs) - shown} more (use --json or rg -nw {ident})")

    print("\n" + "=" * 78)
    print("Every reference above is a place to open and read. Removed-but-referenced and")
    print("signature-changed entries are the highest priority. Identifiers with zero outside")
    print("references still need callee, sibling, data-flow and history checks.")
    print("=" * 78)


if __name__ == "__main__":
    main()
