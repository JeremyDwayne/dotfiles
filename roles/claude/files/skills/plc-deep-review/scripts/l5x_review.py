#!/usr/bin/env python3
"""Static review aid for Studio 5000 L5X exports. It only reads files.

Usage:
  l5x_review.py map PROGRAM.L5X [--all]
  l5x_review.py diff OLD.L5X NEW.L5X [--all]
  l5x_review.py xchg MASTER.L5X REMOTE.L5X [LINK] [--all]
  l5x_review.py routine PROGRAM.L5X NAME          NAME or Program/NAME
  l5x_review.py xref PROGRAM.L5X TAG               a tag, member, element or bit

Long lists print the first 15 entries unless --all is given. Standard library only.
"""

from __future__ import annotations

import ast
import difflib
import re
import statistics
import sys
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from pathlib import Path

LIMIT = 15

# Instructions that only test conditions; they form the series logic in front of outputs.
INPUT_INSTR = {
    "XIC",
    "XIO",
    "ONS",
    "LIMIT",
    "EQU",
    "EQ",
    "NEQ",
    "NE",
    "LES",
    "LT",
    "LEQ",
    "LE",
    "GRT",
    "GT",
    "GEQ",
    "GE",
    "LIM",
    "MEQ",
    "CMP",
    "AFI",
}
READ_ONLY = INPUT_INSTR | {
    "NOP",
    "JSR",
    "JMP",
    "LBL",
    "RET",
    "SBR",
    "TND",
    "MCR",
    "UID",
    "UIE",
    "SSV",
    "EOT",
    "SFR",
    "SFP",
    "EVENT",
    "IOT",
}
# Operand positions each instruction writes.
WRITE_ARGS = {
    "OTE": (0,),
    "OTL": (0,),
    "OTU": (0,),
    "OSR": (0, 1),
    "OSF": (0, 1),
    "TON": (0,),
    "TOF": (0,),
    "RTO": (0,),
    "TONR": (0,),
    "TOFR": (0,),
    "RTOR": (0,),
    "CTU": (0,),
    "CTD": (0,),
    "CTUD": (0,),
    "RES": (0,),
    "MOV": (1,),
    "MOVE": (1,),
    "COP": (1,),
    "CPS": (1,),
    "FLL": (1,),
    "CLR": (0,),
    "CPT": (0,),
    "ADD": (2,),
    "SUB": (2,),
    "MUL": (2,),
    "DIV": (2,),
    "MOD": (2,),
    "XPY": (2,),
    "SQR": (1,),
    "SQRT": (1,),
    "ABS": (1,),
    "NEG": (1,),
    "TOD": (1,),
    "FRD": (1,),
    "DEG": (1,),
    "RAD": (1,),
    "SIN": (1,),
    "COS": (1,),
    "TAN": (1,),
    "ASN": (1,),
    "ACS": (1,),
    "ATN": (1,),
    "LN": (1,),
    "LOG": (1,),
    "TRN": (1,),
    "TRUNC": (1,),
    "AND": (2,),
    "OR": (2,),
    "XOR": (2,),
    "NOT": (1,),
    "BAND": (2,),
    "BOR": (2,),
    "BXOR": (2,),
    "BNOT": (1,),
    "MVM": (2,),
    "BTD": (2,),
    "SWPB": (2,),
    "SCP": (5,),
    "SCL": (0,),
    "MSG": (0,),
    "GSV": (3,),
    "PID": (0, 3),
    "PIDE": (0,),
    "BSL": (0, 1),
    "BSR": (0, 1),
    "FFL": (1, 2),
    "FFU": (1, 2),
    "LFL": (1, 2),
    "LFU": (1, 2),
    "SQO": (2, 3),
    "SQL": (2, 3),
    "CONCAT": (2,),
    "MID": (3,),
    "INSERT": (3,),
    "DELETE": (3,),
    "FIND": (3,),
    "DTOS": (1,),
    "STOD": (1,),
    "RTOS": (1,),
    "STOR": (1,),
    "UPPER": (1,),
    "LOWER": (1,),
    "ALMD": (0,),
    "ALMA": (0,),
    "TOT": (0,),
    "RMPS": (0,),
}
# Instance or storage operands; writing them is ownership, not a competing value write.
OWNER_INSTR = {
    "TON",
    "TOF",
    "RTO",
    "TONR",
    "TOFR",
    "RTOR",
    "CTU",
    "CTD",
    "CTUD",
    "MSG",
    "PID",
    "PIDE",
    "ONS",
    "OSR",
    "OSF",
    "ALMD",
    "ALMA",
    "TOT",
    "RMPS",
    "SCL",
    "BSL",
    "BSR",
    "FFL",
    "FFU",
    "LFL",
    "LFU",
    "SQO",
    "SQL",
}
TIMERS = {"TON", "TOF", "RTO"}
MATH = {
    "CPT",
    "ADD",
    "SUB",
    "MUL",
    "DIV",
    "MOD",
    "SCL",
    "SCP",
    "SQR",
    "SQRT",
    "XPY",
    "ABS",
    "NEG",
}
COPY = {"COP", "CPS"}
MOVES = {"MOV", "MOVE"}
CPT_FUNCS = {
    "MOD",
    "AND",
    "OR",
    "XOR",
    "NOT",
    "SQR",
    "SQRT",
    "SIN",
    "COS",
    "TAN",
    "ASN",
    "ACS",
    "ATN",
    "LN",
    "LOG",
    "DEG",
    "RAD",
    "TRN",
    "FRD",
    "TOD",
    "ABS",
}
ST_WORDS = {
    "IF",
    "THEN",
    "ELSE",
    "ELSIF",
    "END_IF",
    "CASE",
    "OF",
    "END_CASE",
    "FOR",
    "TO",
    "BY",
    "DO",
    "END_FOR",
    "WHILE",
    "END_WHILE",
    "REPEAT",
    "UNTIL",
    "END_REPEAT",
    "EXIT",
    "RETURN",
    "TRUE",
    "FALSE",
    "AND",
    "OR",
    "XOR",
    "NOT",
    "MOD",
}
BUILTIN_TYPES = {
    "BOOL",
    "SINT",
    "INT",
    "DINT",
    "LINT",
    "USINT",
    "UINT",
    "UDINT",
    "ULINT",
    "REAL",
    "LREAL",
    "STRING",
    "TIMER",
    "COUNTER",
    "CONTROL",
    "PID",
    "PID_ENHANCED",
    "MESSAGE",
    "TOTALIZER",
    "ALARM",
    "ALARM_ANALOG",
    "ALARM_DIGITAL",
    "FBD_TIMER",
    "FBD_COUNTER",
    "SELECT",
    "RAMP_SOAK",
    "AXIS",
    "MOTION_GROUP",
    "MOTION_INSTRUCTION",
    "DATALOG_INSTRUCTION",
    "SERIAL_PORT_CONTROL",
}
FBD_NAMES = {
    "TOT",
    "PIDE",
    "RMPS",
    "LDLG",
    "DEDT",
    "HPF",
    "LPF",
    "NTCH",
    "INTG",
    "MAVE",
    "MAXC",
    "MINC",
    "MSTD",
    "SEL",
    "ESEL",
    "SSUM",
    "SNEG",
    "HLL",
    "RLIM",
    "DFF",
    "JKFF",
    "SETD",
    "RESD",
    "OSRI",
    "OSFI",
    "D2SD",
    "D3SD",
    "IMC",
    "CC",
    "MMC",
    "POSP",
    "SRTP",
    "LDL2",
    "FGEN",
    "SCRV",
    "UPDN",
}
BUILTIN_NAMES = BUILTIN_TYPES | set(WRITE_ARGS) | READ_ONLY | FBD_NAMES | {"ONS"}
ATOMIC = {"BOOL", "SINT", "INT", "DINT", "LINT", "REAL", "LREAL", "STRING"}
SIZES = {"SINT": 1, "INT": 2, "DINT": 4, "REAL": 4, "LINT": 8, "LREAL": 8}

IDENT = re.compile(r"[A-Za-z_]\w*")
REF = re.compile(
    r"(?<![\w.\]:#'])("
    r"\\?[A-Za-z_]\w*(?::\d+)?(?::[A-Za-z]\w*)?"
    r"(?:\[[^\[\]]*(?:\[[^\[\]]*\][^\[\]]*)*\])?"
    r"(?:\.(?:[A-Za-z_]\w*|\d+)(?:\[[^\[\]]*\])?)*)"
)
LOGIX_NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
ALARM_NAME = re.compile(r"alarm|^alm|_alm", re.I)
MAP_ROUTINE = re.compile(r"map", re.I)


def norm(text: str) -> str:
    return re.sub(r"\s+", "", text).lower()


def clip(text: str, n: int = 160) -> str:
    text = re.sub(r"\s+", " ", text).strip()
    return text if len(text) <= n else text[: n - 3] + "..."


def valid_name(name: str) -> bool:
    return (
        bool(LOGIX_NAME.match(name))
        and "__" not in name
        and not name.endswith("_")
        and len(name) <= 40
    )


def show(items: list, all_items: bool, indent: str = "  ") -> None:
    """Print a capped list with a count of what was left out."""
    shown = items if all_items else items[:LIMIT]
    for item in shown:
        print(f"{indent}{item}")
    if len(items) > len(shown):
        print(f"{indent}... {len(items) - len(shown)} more (use --all)")


def section(title: str) -> None:
    print(f"\n== {title} ==")


@dataclass
class Instr:
    name: str
    args: list
    cond: str
    feeds: str = ""


@dataclass
class Use:
    key: str
    member: str
    text: str
    write: bool
    owner: bool
    instr: str
    param: str
    program: str
    routine: str
    where: str
    context: str
    cond: str = ""
    feeds: str = ""
    args: tuple = ()
    argi: int = -1

    @property
    def loc(self) -> str:
        return f"{self.program}/{self.routine} {self.where}"


@dataclass
class Routine:
    program: str
    name: str
    type: str
    description: str
    rungs: list = field(default_factory=list)  # (number, text, comment)
    lines: list = field(default_factory=list)  # (number, text)
    sheets: list = field(default_factory=list)  # Sheet elements

    @property
    def size(self) -> int:
        return len(self.rungs) or len(self.lines) or len(self.sheets)

    @property
    def unit(self) -> str:
        return {"RLL": "rungs", "ST": "lines", "FBD": "sheets"}.get(self.type, "items")


@dataclass
class Tag:
    scope: str
    name: str
    datatype: str
    dims: str
    tagtype: str
    alias: str
    access: str
    constant: bool
    description: str
    elem: ET.Element

    @property
    def where(self) -> str:
        return f"{self.scope}/{self.name}" if self.scope else self.name


@dataclass
class Aoi:
    name: str
    revision: str
    protected: bool
    params: list  # (name, usage, required, datatype)

    @property
    def ladder_params(self) -> list:
        return [
            p for p in self.params if p[2] and p[0] not in ("EnableIn", "EnableOut")
        ]


@dataclass
class Call:
    program: str
    caller: str
    where: str
    target: str
    conditional: bool


@dataclass
class AlarmRow:
    kind: str
    instance: str
    key: str
    loc: str
    operands: dict
    trigger: str = ""
    trigger_kind: str = ""
    settings: dict = field(default_factory=dict)


def decorated_values(elem: ET.Element | None, prefix: str = "") -> dict:
    """Flatten a Decorated data structure to {member.path: value}."""
    out: dict = {}
    if elem is None:
        return out
    for ch in elem:
        name = ch.get("Name") or ""
        path = f"{prefix}.{name}" if prefix else name
        if ch.tag == "DataValueMember":
            out[path] = (ch.get("DataType"), ch.get("Value"))
        elif ch.tag in ("StructureMember", "Structure"):
            out.update(decorated_values(ch, path))
        elif ch.tag == "ArrayMember":
            for el in ch:
                idx = el.get("Index", "")
                if el.get("Value") is not None:
                    out[f"{path}{idx}"] = (ch.get("DataType"), el.get("Value"))
                else:
                    inner = el.find("Structure")
                    out.update(
                        decorated_values(el if inner is None else inner, f"{path}{idx}")
                    )
    return out


def l5k_numbers(text: str) -> list:
    try:
        value = ast.literal_eval(re.sub(r"\s+", "", text))
    except (ValueError, SyntaxError):
        return []
    flat: list = []

    def walk(v):
        if isinstance(v, (list, tuple)):
            for x in v:
                walk(x)
        elif isinstance(v, (int, float)):
            flat.append(float(v))

    walk(value)
    return flat


class Project:
    """One L5X export, parsed into tags, routines, AOIs, modules and every operand use."""

    def __init__(self, path: str):
        self.path = Path(path)
        raw = self.path.read_bytes()
        self.bom = raw.startswith(b"\xef\xbb\xbf")
        self.crlf = b"\r\n" in raw[:65536]
        if b"<!DOCTYPE" in raw[:4096] or b"<!ENTITY" in raw[:4096]:
            sys.exit(
                f"{path}: has a DOCTYPE or ENTITY declaration; real L5X exports do not"
            )
        self.root = ET.fromstring(raw)
        c = self.root.find("Controller")
        if c is None:
            sys.exit(f"{path}: no Controller element; export the full project as L5X")
        self.c = c
        self.name = c.get("Name", "")
        self.software = self.root.get("SoftwareRevision", "")
        self.aois = self._aois()
        self.udts = {d.get("Name", ""): d for d in c.iterfind("DataTypes/DataType")}
        self.tags: dict = {}
        self.scope_tags: dict = defaultdict(dict)
        self._add_tags("", c.find("Tags"))
        self.programs: dict = {}
        self.routines: dict = {}
        for p in c.iterfind("Programs/Program"):
            pname = p.get("Name", "")
            self.programs[pname] = p
            self._add_tags(pname, p.find("Tags"))
            for r in p.iterfind("Routines/Routine"):
                self.routines[(pname, r.get("Name", ""))] = self._routine(pname, r)
        self.tasks = [
            (
                t.get("Name"),
                t.get("Type"),
                t.get("Rate"),
                t.get("Priority"),
                t.get("Watchdog"),
                [s.get("Name") for s in t.iter("ScheduledProgram")],
            )
            for t in c.iterfind("Tasks/Task")
        ]
        self.modules = list(c.iterfind("Modules/Module"))
        self.uses: list = []
        self.calls: list = []
        self.alarms: list = []
        self.unknown: Counter = Counter()
        self.syntax: list = []
        self.rung_instrs: dict = {}
        self.fbd_alarm_inputs: dict = {}
        self._collect()

    # parsing ---------------------------------------------------------------

    def _aois(self) -> dict:
        out = {}
        for a in self.c.iterfind("AddOnInstructionDefinitions/*"):
            params = [
                (
                    p.get("Name", ""),
                    p.get("Usage", ""),
                    p.get("Required") == "true",
                    p.get("DataType", ""),
                )
                for p in a.iterfind("Parameters/Parameter")
            ]
            name = a.get("Name", "")
            out[name.lower()] = Aoi(
                name, a.get("Revision", ""), a.tag == "EncodedData", params
            )
        return out

    def _add_tags(self, scope: str, tags: ET.Element | None) -> None:
        for t in tags if tags is not None else []:
            tag = Tag(
                scope,
                t.get("Name", ""),
                t.get("DataType", ""),
                t.get("Dimensions", ""),
                t.get("TagType", "Base"),
                t.get("AliasFor", ""),
                t.get("ExternalAccess", ""),
                t.get("Constant") == "true",
                (t.findtext("Description") or "").strip(),
                t,
            )
            key = f"{scope.lower()}/{tag.name.lower()}" if scope else tag.name.lower()
            self.tags[key] = tag
            self.scope_tags[scope.lower()][tag.name.lower()] = tag

    def _routine(self, prog: str, r: ET.Element) -> Routine:
        rt = Routine(
            prog,
            r.get("Name", ""),
            r.get("Type", ""),
            (r.findtext("Description") or "").strip(),
        )
        for rung in r.iterfind("RLLContent/Rung"):
            rt.rungs.append(
                (
                    int(rung.get("Number", "0")),
                    (rung.findtext("Text") or "").strip(),
                    (rung.findtext("Comment") or "").strip(),
                )
            )
        for line in r.iterfind("STContent/Line"):
            rt.lines.append(
                (int(line.get("Number", "0")), (line.text or "").strip("\r\n"))
            )
        rt.sheets = list(r.iterfind("FBDContent/Sheet"))
        return rt

    def split_ref(self, prog: str, ref: str) -> tuple:
        """Resolve an operand to (base key, member key, kind) where kind is tag, io or sys."""
        r = ref.lstrip("\\")
        if r.lower().startswith("program:") or ref.startswith("\\"):
            body = r[8:] if r.lower().startswith("program:") else r
            p, _, rest = body.partition(".")
            head = re.split(r"[.\[]", rest, maxsplit=1)[0]
            key = f"{p.lower()}/{head.lower()}"
            return key, key + norm(rest[len(head) :]), "tag"
        head = re.split(r"[.\[]", r, maxsplit=1)[0]
        tail = norm(r[len(head) :])
        if ":" in head:
            kind = "sys" if head.upper().startswith("S:") else "io"
            return head.lower(), head.lower() + tail, kind
        low = head.lower()
        key = (
            f"{prog.lower()}/{low}"
            if prog and low in self.scope_tags.get(prog.lower(), {})
            else low
        )
        return key, key + tail, "tag"

    def refs(self, text: str) -> list:
        """Operand references in an argument: (ref, top_level)."""
        out = []
        for m in REF.finditer(text):
            ref = m.group(1)
            nxt = text[m.end() : m.end() + 1]
            if nxt == "(" or ref.upper() in CPT_FUNCS or ref.upper() in ST_WORDS:
                continue
            out.append((ref, True))
            for inner in re.findall(r"\[([^\[\]]*)\]", ref):
                for im in REF.finditer(inner):
                    if not im.group(1)[0].isdigit():
                        out.append((im.group(1), False))
        return out

    def add(
        self,
        prog,
        routine,
        where,
        context,
        arg,
        write,
        owner,
        instr,
        param="",
        cond="",
        feeds="",
        args=(),
        argi=-1,
    ) -> None:
        for ref, top in self.refs(arg):
            key, member, kind = self.split_ref(prog, ref)
            w = write and top
            self.uses.append(
                Use(
                    key,
                    member,
                    ref,
                    w,
                    owner and w,
                    instr,
                    param,
                    prog,
                    routine,
                    where,
                    context,
                    cond,
                    feeds,
                    tuple(args),
                    argi,
                )
            )

    def _instr_uses(self, prog, routine, where, context, ins: Instr) -> None:
        up = ins.name.upper()
        aoi = self.aois.get(ins.name.lower())
        if up == "JSR":
            if ins.args:
                self.calls.append(
                    Call(prog, routine, where, ins.args[0], bool(ins.cond))
                )
            for a in ins.args[1:]:
                self.add(
                    prog,
                    routine,
                    where,
                    context,
                    a,
                    False,
                    False,
                    ins.name,
                    cond=ins.cond,
                )
            return
        if aoi:
            params = aoi.ladder_params
            for i, a in enumerate(ins.args):
                if i == 0:
                    self.add(
                        prog,
                        routine,
                        where,
                        context,
                        a,
                        True,
                        True,
                        aoi.name,
                        "(instance)",
                        ins.cond,
                        args=ins.args,
                        argi=0,
                    )
                    continue
                p = params[i - 1] if i - 1 < len(params) else ("?", "Input", True, "")
                self.add(
                    prog,
                    routine,
                    where,
                    context,
                    a,
                    p[1] in ("Output", "InOut"),
                    False,
                    aoi.name,
                    p[0],
                    ins.cond,
                    args=ins.args,
                    argi=i,
                )
            if (
                ALARM_NAME.search(aoi.name)
                and "ack" not in aoi.name.lower()
                and ins.args
            ):
                ops = {
                    p[0]: ins.args[i + 1]
                    for i, p in enumerate(params)
                    if i + 1 < len(ins.args)
                }
                self._alarm(
                    aoi.name,
                    prog,
                    ins.args[0],
                    f"{prog}/{routine} {where}",
                    ops,
                    ins.cond,
                )
            return
        writes = WRITE_ARGS.get(up)
        if writes is None and up not in READ_ONLY:
            self.unknown[up] += 1
            writes = ()
        for i, a in enumerate(ins.args):
            self.add(
                prog,
                routine,
                where,
                context,
                a,
                i in (writes or ()),
                up in OWNER_INSTR and i == 0,
                ins.name,
                cond=ins.cond,
                feeds=ins.feeds,
                args=ins.args,
                argi=i,
            )
        if up in ("ALMD", "ALMA") and ins.args:
            self._alarm(
                up, prog, ins.args[0], f"{prog}/{routine} {where}", {}, ins.cond
            )

    def _alarm(self, kind, prog, instance, loc, ops, cond) -> None:
        key = self.split_ref(prog, instance)[0]
        self.alarms.append(AlarmRow(kind, instance, key, loc, ops, cond))

    def _collect(self) -> None:
        for (prog, rname), rt in self.routines.items():
            for num, text, _ in rt.rungs:
                instrs, problems = parse_ladder(text)
                self.rung_instrs[(prog, rname, num)] = instrs
                for p in problems:
                    self.syntax.append(f"{prog}/{rname} rung {num}: {p}")
                for ins in instrs:
                    self._instr_uses(prog, rname, f"rung {num}", text, ins)
            if rt.lines:
                self._st(prog, rname, rt.lines)
            for si, sheet in enumerate(rt.sheets, 1):
                self._fbd(prog, rname, si, sheet)
        for t in self.c.iter("Tag"):
            mp = t.find(".//MessageParameters")
            if mp is None:
                continue
            scope = self._tag_scope(t)
            local = mp.get("LocalElement") or mp.get("DestinationTag") or ""
            if local:
                is_read = "Read" in mp.get("MessageType", "")
                self.add(
                    scope,
                    "(MSG)",
                    t.get("Name", ""),
                    "MessageParameters",
                    local,
                    is_read,
                    False,
                    "MSG",
                )

    def _tag_scope(self, t: ET.Element) -> str:
        for pname, p in self.programs.items():
            if t in list(p.iterfind("Tags/Tag")):
                return pname
        return ""

    def _st(self, prog: str, rname: str, lines: list) -> None:
        text = "\n".join(t for _, t in lines)
        clean = re.sub(
            r"\(\*.*?\*\)|/\*.*?\*/|//[^\n]*|'[^']*'|\"[^\"]*\"",
            lambda m: re.sub(r"[^\n]", " ", m.group(0)),
            text,
            flags=re.S,
        )
        for (num, raw), line in zip(lines, clean.split("\n")):
            where, consumed = f"line {num}", []
            for m in IDENT.finditer(line):
                if line[m.end() : m.end() + 1] != "(" or any(
                    a <= m.start() < b for a, b in consumed
                ):
                    continue
                args, end = parse_call(line, m.end())
                consumed.append((m.start(), end))
                self._instr_uses(prog, rname, where, raw, Instr(m.group(0), args, ""))
            for m in re.finditer(REF.pattern + r"\s*:=", line):
                if not any(a <= m.start() < b for a, b in consumed):
                    consumed.append((m.start(), m.end()))
                    self.add(prog, rname, where, raw, m.group(1), True, False, ":=")
            rest = "".join(
                " " if any(a <= i < b for a, b in consumed) else ch
                for i, ch in enumerate(line)
            )
            self.add(prog, rname, where, raw, rest, False, False, "ST")

    def _fbd(self, prog: str, rname: str, si: int, sheet: ET.Element) -> None:
        els = {e.get("ID"): e for e in sheet}
        into, out_of = defaultdict(list), defaultdict(list)
        for w in sheet.iter("Wire"):
            src, dst = els.get(w.get("FromID")), els.get(w.get("ToID"))
            if src is None or dst is None:
                continue
            if src.tag == "IRef":
                into[src.get("ID")].append((dst, w.get("ToParam", "")))
            if dst.tag == "ORef":
                out_of[dst.get("ID")].append((src, w.get("FromParam", "")))
        where = f"sheet {si}"
        for e in sheet:
            op = e.get("Operand", "")
            if e.tag == "IRef" and op:
                targets = into.get(e.get("ID"), []) or [(None, "")]
                for dst, pin in targets:
                    blk = dst.get("Operand", "") if dst is not None else ""
                    self.add(
                        prog,
                        rname,
                        where,
                        f"IRef {op}",
                        op,
                        False,
                        False,
                        "IRef",
                        f"{blk}.{pin}" if blk else pin,
                    )
                    if dst is not None and dst.tag == "AddOnInstruction":
                        self.fbd_alarm_inputs.setdefault(blk.lower(), {})[pin] = op
            elif e.tag == "ORef" and op:
                srcs = out_of.get(e.get("ID"), []) or [(None, "")]
                for src, pin in srcs:
                    blk = src.get("Operand", "") if src is not None else ""
                    self.add(
                        prog,
                        rname,
                        where,
                        f"ORef {op}",
                        op,
                        True,
                        False,
                        "ORef",
                        f"{blk}.{pin}" if blk else pin,
                    )
            elif e.tag in ("Block", "AddOnInstruction") and op:
                kind = e.get("Type") or e.get("Name") or e.tag
                self.add(
                    prog,
                    rname,
                    where,
                    f"{kind} {op}",
                    op,
                    True,
                    True,
                    kind,
                    "(instance)",
                )
                if (
                    e.tag == "AddOnInstruction"
                    and ALARM_NAME.search(kind)
                    and "ack" not in kind.lower()
                ):
                    self._alarm(kind, prog, op, f"{prog}/{rname} {where}", {}, "")
            elif e.tag == "JSR" and e.get("Routine"):
                self.calls.append(Call(prog, rname, where, e.get("Routine", ""), False))
        for row in self.alarms:
            if row.loc == f"{prog}/{rname} {where}" and not row.operands:
                row.operands = dict(self.fbd_alarm_inputs.get(row.instance.lower(), {}))

    # derived views ---------------------------------------------------------

    def tag(self, key: str) -> Tag | None:
        return self.tags.get(key)

    def is_map(self, routine: str) -> bool:
        return bool(MAP_ROUTINE.search(routine))

    def instance_values(self, tag: Tag | None) -> dict:
        if tag is None:
            return {}
        for d in tag.elem.iterfind("Data"):
            if d.get("Format") == "Decorated":
                return {
                    k.lower(): v
                    for k, (_, v) in decorated_values(d.find("Structure")).items()
                }
        return {}

    def resolve_alarms(self) -> None:
        """Fill each alarm's trigger and settings from its rung and from writes to its members."""
        if any(row.trigger_kind for row in self.alarms):
            return
        # Logic latches only; defaults and first-scan latches are configuration. A latch whose
        # OTU waits on a reset or acknowledge is a lockout; one cleared by the process is state.
        latched = {
            u.member
            for u in self.uses
            if u.instr.upper() == "OTL"
            and u.write
            and "s:fs" not in u.cond.lower()
            and not re.search(r"default|config|init", u.routine, re.I)
        }
        lockouts = {
            u.member
            for u in self.uses
            if u.instr.upper() == "OTU"
            and u.member in latched
            and re.search(r"rst|reset|ack", u.cond, re.I)
        }
        inputs, settings = defaultdict(list), defaultdict(dict)
        for u in self.uses:
            if not u.write or not u.member[len(u.key) :].startswith("."):
                continue
            member = u.member[len(u.key) + 1 :]
            if member in ("x", "triggerinput", "in", "input", "cond", "condition"):
                inputs[u.key].append(u)
            elif u.instr.upper() in MOVES and u.args:
                settings[u.key][member] = u.args[0]
            elif u.instr.upper() in ("OTL", "OTU"):
                settings[u.key][member] = "1" if u.instr.upper() == "OTL" else "0"
            elif u.instr == ":=":
                m = re.search(r":=\s*(.+?)\s*;", u.context)
                if m:
                    settings[u.key][member] = m.group(1)
        for row in self.alarms:
            row.settings = settings.get(row.key, {})
            src = inputs.get(row.key)
            if src:
                row.trigger = " | ".join(clip(u.cond or u.context, 90) for u in src)
            elif row.trigger == "" and row.operands:
                row.trigger = row.operands.get("X") or row.operands.get("In") or ""
            text = row.trigger
            refs = [
                self.split_ref(row.loc.split("/")[0], r)[1] for r, _ in self.refs(text)
            ]
            if not text:
                row.trigger_kind = "none found"
            elif any(r in lockouts for r in refs):
                row.trigger_kind = "lockout"
            elif any(r in latched for r in refs):
                row.trigger_kind = "state latch"
            elif ".dn" in text.lower():
                row.trigger_kind = "timer"
            else:
                row.trigger_kind = "direct"


def parse_call(text: str, open_idx: int) -> tuple:
    """Split the arguments of a call whose '(' is at open_idx. Returns (args, end index)."""
    depth, bdepth, j, start, args = 0, 0, open_idx, open_idx + 1, []
    while j < len(text):
        ch = text[j]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                break
        elif ch == "[":
            bdepth += 1
        elif ch == "]":
            bdepth -= 1
        elif ch == "," and depth == 1 and bdepth == 0:
            args.append(text[start:j].strip())
            start = j + 1
        j += 1
    args.append(text[start:j].strip())
    return ([] if args == [""] else args), j + 1


def parse_ladder(text: str) -> tuple:
    """Split rung text into instructions, each with the series conditions in front of it."""
    instrs, problems, cond, stack = [], [], [], []
    i, n = 0, len(text)
    while i < n:
        ch = text[i]
        if ch == "[":
            stack.append([list(cond), [], 0])
        elif ch == "," and stack:
            frame = stack[-1]
            frame[1].append(cond[len(frame[0]) :])
            frame[2] += 1
            cond = list(frame[0])
        elif ch == "]":
            if not stack:
                problems.append("unbalanced ]")
            else:
                base, legs, commas = stack.pop()
                legs.append(cond[len(base) :])
                if commas == 0:
                    problems.append("single-leg branch")
                if all(legs):
                    cond = base + [
                        "[" + " | ".join(" ".join(leg) for leg in legs) + "]"
                    ]
                else:
                    cond = base
        else:
            m = IDENT.match(text, i)
            if m and text[m.end() : m.end() + 1] == "(":
                args, end = parse_call(text, m.end())
                if end > n:
                    problems.append(f"unbalanced ( in {m.group(0)}")
                instrs.append(Instr(m.group(0), args, " ".join(cond)))
                if m.group(0).upper() in INPUT_INSTR:
                    cond.append(f"{m.group(0)}({','.join(args)})")
                i = end
                continue
        i += 1
    if stack:
        problems.append("unbalanced [")
    for k, ins in enumerate(instrs):
        if ins.name.upper() in INPUT_INSTR:
            for nxt in instrs[k + 1 :]:
                up = nxt.name.upper()
                if up not in INPUT_INSTR:
                    pos = WRITE_ARGS.get(up, (0,))
                    if pos and pos[0] < len(nxt.args):
                        ins.feeds = f"{nxt.name}({nxt.args[pos[0]]})"
                    break
    return instrs, problems


# map ---------------------------------------------------------------------


def cmd_map(path: str, all_items: bool) -> None:
    p = Project(path)
    p.resolve_alarms()
    c = p.c
    print(
        f"{p.path.name}: controller {p.name}, {c.get('ProcessorType')}, "
        f"software {p.software}, export options: {p.root.get('ExportOptions', '')}"
    )
    print(
        f"tags {len(p.tags)}, programs {len(p.programs)}, routines {len(p.routines)}, "
        f"AOIs {len(p.aois)}, modules {len(p.modules)}, operand uses {len(p.uses)}"
    )
    map_tasks(p)
    map_calls(p, all_items)
    map_aois(p, all_items)
    map_msgs(p, all_items)
    map_modules(p, all_items)
    map_io(p, all_items)
    map_alarms(p, all_items)
    map_writers(p, all_items)
    map_tags(p, all_items)
    map_docs(p, all_items)
    map_hazards(p, all_items)
    if p.unknown:
        section("Not modelled")
        print(
            "  Instructions whose writes this script does not track (treated as reads):"
        )
        print("  " + ", ".join(f"{k} x{v}" for k, v in p.unknown.most_common()))


def map_tasks(p: Project) -> None:
    section("Tasks")
    scheduled = set()
    for name, typ, rate, prio, wd, progs in p.tasks:
        scheduled.update(progs)
        rate_s = f" rate {rate} ms" if rate else ""
        print(
            f"  {name}: {typ}{rate_s}, priority {prio}, watchdog {wd} ms -> {', '.join(progs)}"
        )
    for pname, prog in p.programs.items():
        if pname not in scheduled:
            print(f"  NOT SCHEDULED: program {pname} runs in no task")
        if prog.get("Disabled") == "true":
            print(f"  DISABLED: program {pname}")


def map_calls(p: Project, all_items: bool) -> None:
    section("Call tree (JSR order is execution order)")
    by_caller = defaultdict(list)
    for call in p.calls:
        by_caller[(call.program, call.caller.lower())].append(call)
    names = {(pr, r.lower()): r for (pr, r) in p.routines}
    reached, counts, missing = set(), Counter(), []

    def walk(pname: str, rname: str, depth: int, stack: set, lines: list) -> None:
        """Append rname and everything it calls, in JSR order, to lines."""
        real = names.get((pname, rname.lower()))
        rt = p.routines.get((pname, real)) if real else None
        reached.add((pname, real or rname))
        size = f"{rt.size} {rt.unit}" if rt else "MISSING"
        lines.append(f"{'  ' * depth}{rname} [{rt.type if rt else '?'}, {size}]")
        for call in by_caller.get((pname, rname.lower()), []):
            counts[(pname, call.target.lower())] += 1
            if (pname, call.target.lower()) not in names:
                missing.append(
                    f"{pname}/{rname} {call.where}: JSR to missing routine {call.target}"
                )
            if call.target.lower() in stack:
                lines.append(f"{'  ' * (depth + 1)}{call.target} (recursive call)")
                continue
            before = len(lines)
            walk(pname, call.target, depth + 1, stack | {call.target.lower()}, lines)
            if call.conditional:
                lines[before] += " (conditional)"

    for pname, prog in p.programs.items():
        main = prog.get("MainRoutineName", "")
        fault = prog.get("FaultRoutineName", "")
        print(f"  {pname} (main {main}{', fault ' + fault if fault else ''})")
        lines: list = []
        for root in (main, fault):
            if root:
                walk(pname, root, 2, {root.lower()}, lines)
        show(lines, all_items, "")
    unreached = [
        f"{pr}/{r} [{rt.type}, {rt.size} {rt.unit}]"
        for (pr, r), rt in p.routines.items()
        if (pr, r) not in reached
    ]
    twice = [
        f"{pr}/{names.get((pr, r), r)} called {n} times"
        for (pr, r), n in counts.items()
        if n > 1
    ]
    if unreached:
        print(f"  Never called ({len(unreached)}):")
        show(unreached, all_items, "    ")
    if missing:
        print(f"  JSR to missing routines ({len(missing)}):")
        show(missing, all_items, "    ")
    if twice:
        print(f"  Called more than once ({len(twice)}):")
        show(twice, all_items, "    ")
    sizes = [rt.size for rt in p.routines.values() if rt.type == "RLL"]
    if sizes:
        big = sorted(
            (
                (rt.size, f"{rt.program}/{rt.name}")
                for rt in p.routines.values()
                if rt.type == "RLL" and rt.size > 50
            ),
            reverse=True,
        )
        print(
            f"  Ladder routine size: {len(sizes)} routines, median {statistics.median(sizes):g}, "
            f"max {max(sizes)} rungs; {len(big)} over 50 rungs"
        )
        show([f"{name}: {n} rungs" for n, name in big], all_items, "    ")


def map_aois(p: Project, all_items: bool) -> None:
    section("Add-On Instructions")
    used = Counter(u.instr.lower() for u in p.uses if u.param == "(instance)")
    typed = Counter(t.datatype.lower() for t in p.tags.values())
    for key, a in sorted(p.aois.items()):
        n, inst = used.get(key, 0), typed.get(key, 0)
        flag = "" if n else "  UNUSED"
        prot = "protected" if a.protected else "source visible"
        print(
            f"  {a.name} rev {a.revision}, {prot}, {n} calls, {inst} instance tags{flag}"
        )
    called = Counter(u.member for u in p.uses if u.param == "(instance)")
    multi = [
        f"{m} called {n} times"
        for m, n in called.items()
        if n > 1 and any(u.member == m and u.instr.lower() in p.aois for u in p.uses)
    ]
    if multi:
        print("  AOI instances called more than once per scan:")
        show(multi, all_items, "    ")


def map_msgs(p: Project, all_items: bool) -> None:
    section("Messages")
    execs = defaultdict(list)
    for u in p.uses:
        if u.instr.upper() == "MSG" and u.owner:
            execs[u.key].append(u)
    task_of = {prog: name for name, _, _, _, _, progs in p.tasks for prog in progs}
    rows, idle = [], []
    for key, t in p.tags.items():
        if t.datatype != "MESSAGE":
            continue
        mp = t.elem.find(".//MessageParameters")
        a = mp.attrib if mp is not None else {}
        local = a.get("LocalElement") or a.get("DestinationTag") or ""
        rows.append(
            f"{t.where}: {a.get('MessageType', '?')}, local {local}, remote "
            f"{a.get('RemoteElement', '-')}, length {a.get('RequestedLength', '?')}, path "
            f"'{a.get('ConnectionPath', '')}', cached {a.get('CacheConnections', '-')}, "
            f"connected {a.get('ConnectedFlag', '-')}"
        )
        ex = execs.get(key, [])
        for u in ex:
            rows.append(
                f"    runs at {u.loc} [{task_of.get(u.program, 'no task')}] "
                f"when {clip(u.cond, 100) or 'always'}"
            )
        if not ex:
            idle.append(t.where)
        elif len(ex) > 1:
            rows.append(f"    RUNS IN {len(ex)} PLACES")
    if not rows:
        print("  none")
        return
    show(rows, all_items)
    if idle:
        print(f"  MSG tags never executed ({len(idle)}): {', '.join(idle)}")


def module_address(m: ET.Element) -> str:
    for port in m.iterfind("Ports/Port"):
        if port.get("Upstream") == "true" and port.get("Address"):
            return port.get("Address", "")
    return ""


def channel_summary(values: dict) -> list:
    """Group channel members (Ch00.x, Ch0x, Pt00.x) and print identical channels once."""
    chans = defaultdict(dict)
    keep = re.compile(
        r"range|signal|engineering|filter|disable|inputen$|outputen$|alarmlimit|"
        r"faultmode|progmode|faultvalue|progvalue|clamp|sensortype",
        re.I,
    )
    for path, (_, value) in values.items():
        m = re.match(r"^(Ch|Pt)(\d+)[._]?(.*)$", path)
        if m and keep.search(m.group(3)):
            chans[f"{m.group(1)}{int(m.group(2)):02d}"][m.group(3)] = value
    groups = defaultdict(list)
    for ch, cfg in sorted(chans.items()):
        groups[" ".join(f"{k}={v}" for k, v in cfg.items())].append(ch)
    return [
        f"{','.join(chs) if len(chs) < 4 else chs[0] + '-' + chs[-1]}: {cfg}"
        for cfg, chs in groups.items()
    ]


def config_mismatch(m: ET.Element) -> list:
    """Decorated INT/DINT/REAL config values with no matching number in the L5K config data."""
    ct = m.find(".//ConfigTag")
    if ct is None:
        return []
    l5k = deco = None
    for d in ct.iterfind("Data"):
        if d.get("Format") == "L5K":
            l5k = d.text or ""
        elif d.get("Format") == "Decorated":
            deco = d.find("Structure")
    if l5k is None or deco is None:
        return []
    pool = Counter(round(v, 3) for v in l5k_numbers(l5k))
    out = []
    for path, (dtype, value) in decorated_values(deco).items():
        if dtype not in ("INT", "DINT", "REAL") or value is None:
            continue
        try:
            v = round(float(value), 3)
        except ValueError:
            continue
        if pool[v] > 0:
            pool[v] -= 1
        else:
            out.append(f"{path}={value}")
    return out


def map_modules(p: Project, all_items: bool) -> None:
    section("I/O modules")
    for m in p.modules:
        flags = []
        if m.get("Inhibited") == "true":
            flags.append("INHIBITED")
        if m.get("MajorFault") == "true":
            flags.append("major fault on connection loss")
        rpi = [
            conn.get("RPI")
            for conn in m.iterfind("Communications/Connections/Connection")
            if conn.get("RPI")
        ]
        print(
            f"  {m.get('Name')} {m.get('CatalogNumber')} parent {m.get('ParentModule')} "
            f"@ {module_address(m) or '-'}{' RPI ' + rpi[0] + ' us' if rpi else ''}"
            f"{' [' + ', '.join(flags) + ']' if flags else ''}"
        )
        ct = m.find(".//ConfigTag")
        if ct is None:
            continue
        deco = next(
            (
                d.find("Structure")
                for d in ct.iterfind("Data")
                if d.get("Format") == "Decorated"
            ),
            None,
        )
        for line in channel_summary(decorated_values(deco)):
            print(f"      {line}")
        bad = config_mismatch(m)
        if bad:
            print(
                f"      L5K/decorated config disagree (heuristic, {len(bad)} values): "
                f"{', '.join(bad[:8])}"
            )


def map_io(p: Project, all_items: bool) -> None:
    section("I/O references")
    outside = Counter()
    readers = defaultdict(set)
    for u in p.uses:
        if p.split_ref(u.program, u.text)[2] != "io" or u.routine == "(MSG)":
            continue
        readers[u.key].add(f"{u.program}/{u.routine}")
        if not p.is_map(u.routine):
            outside[f"{u.program}/{u.routine}"] += 1
    maps = sorted({r for (pr, r) in p.routines if p.is_map(r)})
    print(f"  Map routines (name contains 'map'): {', '.join(maps) or 'none'}")
    if outside:
        print(
            f"  Module addresses used outside the map routines ({sum(outside.values())} uses):"
        )
        show([f"{r}: {n}" for r, n in outside.most_common()], all_items, "    ")
    multi = [f"{k}: {', '.join(sorted(v))}" for k, v in readers.items() if len(v) > 1]
    if multi:
        print("  Module tags used in more than one routine:")
        show(multi, all_items, "    ")
    math = []
    for (prog, rname, num), instrs in p.rung_instrs.items():
        if p.is_map(rname) and "out" not in rname.lower():
            for ins in instrs:
                up = ins.name.upper()
                scale = ins.name.lower() in p.aois and re.search(
                    "scal|scl|ain", ins.name, re.I
                )
                if up in MATH or scale:
                    math.append(
                        f"{prog}/{rname} rung {num}: {ins.name}({','.join(ins.args)})"
                    )
    if math:
        print(f"  Math or scaling inside input map routines ({len(math)}):")
        show(math, all_items, "    ")


def map_alarms(p: Project, all_items: bool) -> None:
    section("Alarm census")
    if not p.alarms:
        print("  no alarm blocks found (AOIs named *alarm*/*alm*, ALMD, ALMA)")
        return
    kinds = Counter(a.kind for a in p.alarms)
    print("  " + ", ".join(f"{k} x{n}" for k, n in kinds.most_common()))
    resets = Counter()
    rows, latch, series, zero = [], [], [], []
    for a in p.alarms:
        # Operands win over member writes, which win over the tag's stored values.
        vals = p.instance_values(p.tag(a.key))
        merged = {k: v for k, v in vals.items() if re.search("delay|dly|cfg", k, re.I)}
        merged.update({k.lower(): v for k, v in a.settings.items()})
        merged.update({k.lower(): v for k, v in a.operands.items()})
        reset = next(
            (
                v
                for k, v in merged.items()
                if re.search("reset|ack", k) and not re.search("auto|cfg", k)
            ),
            "",
        )
        delays = {k: v for k, v in merged.items() if re.search("delay|dly|cfg", k)}
        outs = [v for k, v in a.operands.items() if re.search("output|out$", k, re.I)]
        resets[reset or "(none)"] += 1
        extra = " ".join(f"{k}={v}" for k, v in delays.items())
        rows.append(
            f"{a.instance} @ {a.loc}: trigger[{a.trigger_kind}] {clip(a.trigger, 90)}"
            f"; reset {reset or '-'}{'; ' + extra if extra else ''}"
            f"{'; out ' + ','.join(outs) if outs else ''}"
        )
        if a.trigger_kind == "lockout":
            latch.append(f"{a.instance} @ {a.loc}: {clip(a.trigger, 100)}")
        on_delay = next(
            (
                v
                for k, v in delays.items()
                if re.search("on|^delay$", k, re.I) and "clear" not in k.lower()
            ),
            None,
        )
        if a.trigger_kind == "timer" and on_delay not in (None, "0", "0.0"):
            series.append(
                f"{a.instance} @ {a.loc}: timer trigger plus on-delay {on_delay}"
            )
        if on_delay in ("0", "0.0") and a.trigger_kind != "timer":
            zero.append(
                f"{a.instance} @ {a.loc}: on-delay 0 with a {a.trigger_kind} trigger"
            )
    show(rows, all_items)
    print("  Reset sources: " + ", ".join(f"{k} x{n}" for k, n in resets.most_common()))
    if latch:
        print(
            f"  Alarms triggered by a reset-cleared lockout ({len(latch)}); auto-reset cannot"
            " clear them and the operator may need two resets:"
        )
        show(latch, all_items, "    ")
    if series:
        print(f"  Delays in series ({len(series)}):")
        show(series, all_items, "    ")
    if zero:
        print(
            f"  Zero on-delay ({len(zero)}); a one-scan blip alarms unless the trigger is"
            " already debounced:"
        )
        show(zero, all_items, "    ")
    called = {a.key for a in p.alarms}
    idle = [
        t.where
        for k, t in p.tags.items()
        if (
            ALARM_NAME.search(t.datatype)
            and "ack" not in t.datatype.lower()
            and t.datatype.lower() in p.aois
            or t.datatype in ("ALARM_DIGITAL", "ALARM_ANALOG")
        )
        and k not in called
    ]
    if idle:
        print(f"  Alarm instance tags never called ({len(idle)}):")
        show(idle, all_items, "    ")


def map_writers(p: Project, all_items: bool) -> None:
    section("Writers")
    ote = defaultdict(list)
    latch = defaultdict(set)
    value_writers = defaultdict(set)
    shown = {}
    for u in p.uses:
        if not u.write or u.routine == "(MSG)":
            continue
        shown.setdefault(u.member, u.text)
        up = u.instr.upper()
        if up == "OTE":
            ote[u.member].append(u.loc)
        elif up in ("OTL", "OTU"):
            latch[u.member].add(up)
        if not u.owner and up not in ("OTL", "OTU", "RES") and u.param != "(instance)":
            value_writers[u.member].add(f"{u.program}/{u.routine}")
    dup = [f"{shown[m]}: {', '.join(locs)}" for m, locs in ote.items() if len(locs) > 1]
    mixed = [
        f"{shown[m]}: OTE and {'/'.join(sorted(latch[m]))}" for m in ote if m in latch
    ]
    many = [
        f"{shown[m]}: {', '.join(sorted(rs))}"
        for m, rs in value_writers.items()
        if len(rs) > 1
    ]
    print(f"  Duplicate OTE coils ({len(dup)}):")
    show(dup, all_items, "    ")
    if mixed:
        print(f"  OTE mixed with OTL/OTU on one bit ({len(mixed)}):")
        show(mixed, all_items, "    ")
    print(f"  Written from more than one routine ({len(many)}):")
    show(many, all_items, "    ")


def map_tags(p: Project, all_items: bool) -> None:
    section("Tag use")
    read, written = set(), set()
    for u in p.uses:
        (written if u.write else read).add(u.key)
    for t in p.tags.values():
        if t.tagtype == "Alias" and t.alias:
            key = p.split_ref(t.scope, t.alias)[0]
            read.add(key)
            written.add(key)
    unref, wnr, rnw, scada = [], [], [], []
    for key, t in sorted(p.tags.items()):
        base_type = t.datatype.upper()
        plain = base_type in ATOMIC or t.datatype in p.udts
        r, w = key in read, key in written
        label = f"{t.where} ({t.datatype}{'[' + t.dims + ']' if t.dims else ''})"
        if not r and not w:
            unref.append(label)
        elif not plain or t.tagtype in ("Produced", "Consumed"):
            continue
        elif w and not r:
            wnr.append(f"{label} access {t.access}")
        elif r and not w and not t.constant:
            (scada if t.access == "Read/Write" else rnw).append(label)
    print(f"  Never referenced ({len(unref)}):")
    show(unref, all_items, "    ")
    print(
        f"  Written, never read in logic ({len(wnr)}), fine only if SCADA or a MSG reads them:"
    )
    show(wnr, all_items, "    ")
    print(f"  Read, never written, External Access not Read/Write ({len(rnw)}):")
    show(rnw, all_items, "    ")
    print(
        f"  Read, never written by logic, External Access Read/Write ({len(scada)}); SCADA, a MSG or nothing writes each, confirm which:"
    )
    show(scada, all_items, "    ")


def map_docs(p: Project, all_items: bool) -> None:
    section("Documentation and readability")
    total = commented = 0
    bare, no_header = [], []
    for rt in p.routines.values():
        if rt.type == "RLL" and rt.rungs:
            n = sum(1 for _, _, cmt in rt.rungs if cmt)
            total += len(rt.rungs)
            commented += n
            if n == 0 and len(rt.rungs) > 3:
                bare.append(
                    f"{rt.program}/{rt.name}: {len(rt.rungs)} rungs, no comments"
                )
            if not rt.rungs[0][2] and not rt.description:
                no_header.append(f"{rt.program}/{rt.name}")
        elif rt.type == "ST" and rt.lines:
            first = next((t for _, t in rt.lines if t.strip()), "")
            if not re.match(r"\s*(\(\*|//|/\*)", first) and not rt.description:
                no_header.append(f"{rt.program}/{rt.name}")
    if total:
        print(
            f"  Ladder rungs with a comment: {commented} of {total} ({100 * commented // total}%)"
        )
    print(f"  Routines with no header comment or description ({len(no_header)}):")
    show(no_header, all_items, "    ")
    if bare:
        print(f"  Routines with no rung comments at all ({len(bare)}):")
        show(bare, all_items, "    ")
    alarm_keys = {a.key for a in p.alarms}
    io_keys = {
        u.key
        for u in p.uses
        if p.is_map(u.routine) and p.split_ref(u.program, u.text)[2] == "tag"
    }
    undoc_alarm = [
        p.tags[k].where
        for k in sorted(alarm_keys)
        if k in p.tags and not p.tags[k].description
    ]
    undoc_io = [
        p.tags[k].where
        for k in sorted(io_keys)
        if k in p.tags and not p.tags[k].description
    ]
    undoc = sum(1 for t in p.tags.values() if not t.description)
    print(f"  Tags without a description: {undoc} of {len(p.tags)}")
    print(f"    alarm instances ({len(undoc_alarm)}):")
    show(undoc_alarm, all_items, "      ")
    print(f"    tags used in map routines ({len(undoc_io)}):")
    show(undoc_io, all_items, "      ")
    dense = []
    for (prog, rname, num), instrs in p.rung_instrs.items():
        text = next((t for n, t, _ in p.routines[(prog, rname)].rungs if n == num), "")
        depth = max_depth(text)
        if len(instrs) > 24 or depth > 2:
            dense.append(
                (
                    len(instrs),
                    f"{prog}/{rname} rung {num}: {len(instrs)} instructions, "
                    f"branch depth {depth}",
                )
            )
    if dense:
        print(f"  Dense rungs a technician will struggle to read ({len(dense)}):")
        show([d for _, d in sorted(dense, reverse=True)], all_items, "    ")
    zero = []
    for u in p.uses:
        if u.instr.upper() in TIMERS and u.argi == 0 and u.args:
            pre = u.args[1] if len(u.args) > 1 else "?"
            if pre == "?":
                pre = p.instance_values(p.tag(u.key)).get("pre", "?")
            if pre in ("0", "0.0"):
                zero.append(
                    f"{u.loc}: {u.instr}({u.text}) preset 0, DN sets on the first true scan"
                )
    if zero:
        print(f"  Timers with preset 0 ({len(zero)}):")
        show(zero, all_items, "    ")


def max_depth(text: str) -> int:
    depth = best = 0
    in_args = 0
    for ch in text:
        if ch == "(":
            in_args += 1
        elif ch == ")":
            in_args -= 1
        elif in_args == 0 and ch == "[":
            depth += 1
            best = max(best, depth)
        elif in_args == 0 and ch == "]":
            depth -= 1
    return best


def map_hazards(p: Project, all_items: bool) -> None:
    section("Import hazards")
    out = []
    if not p.bom:
        out.append("file has no UTF-8 BOM (real exports have one)")
    if not p.crlf:
        out.append("file uses LF line endings (real exports use CRLF)")
    if not valid_name(p.path.stem):
        out.append(
            f"file name '{p.path.stem}' is not a valid Logix name; the .ACD takes this name"
        )
    names = [("program", n) for n in p.programs] + [
        ("routine", r) for (_, r) in p.routines
    ]
    names += [("tag", t.where.split("/")[-1]) for t in p.tags.values()]
    names += [("AOI", a.name) for a in p.aois.values()] + [("UDT", n) for n in p.udts]
    names += [
        ("module", m.get("Name", "")) for m in p.modules if m.get("Name") != "Local"
    ]
    for kind, name in names:
        if not valid_name(name):
            out.append(
                f"{kind} '{name}' breaks Logix naming (letters, digits, single '_', <= 40)"
            )
        if name.upper() in BUILTIN_NAMES and kind != "module":
            out.append(f"{kind} '{name}' collides with a built-in instruction or type")
    for scope, tags in p.scope_tags.items():
        if not scope:
            continue
        for low, t in tags.items():
            if low in p.scope_tags[""]:
                out.append(
                    f"program tag {t.where} shadows controller tag {p.scope_tags[''][low].name}"
                )
    for prog, r in p.routines:
        if (
            r.lower() in p.scope_tags.get(prog.lower(), {})
            or r.lower() in p.scope_tags[""]
        ):
            out.append(f"routine {prog}/{r} has the same name as a tag")
    for t in p.tags.values():
        if len(t.description) > 128:
            out.append(
                f"tag {t.where} description is {len(t.description)} characters (> 128)"
            )
    for rt in p.routines.values():
        for num, _, cmt in rt.rungs:
            if len(cmt) > 500:
                out.append(
                    f"{rt.program}/{rt.name} rung {num} comment is {len(cmt)} characters (> 500)"
                )
    out += p.syntax
    if p.c.get("Description") and len(p.c.findtext("Description") or "") > 128:
        out.append(
            "controller description is long; long controller descriptions have failed import"
        )
    print(f"  {len(out)} found")
    show(out, all_items)


# diff --------------------------------------------------------------------


def rung_category(text: str, p: Project) -> str:
    names = {n.upper() for n in re.findall(r"([A-Za-z_]\w*)\(", text)}
    lower = {n.lower() for n in names}
    if any(ALARM_NAME.search(n) and n in p.aois for n in lower) or names & {
        "ALMD",
        "ALMA",
    }:
        return "alarm"
    if "MSG" in names or re.search(r"(Tx|Rx)\w*\[", text):
        return "comms"
    if re.search(r"\w+:\d*:?[IOC]\d*\.", text):
        return "io"
    if "JSR" in names:
        return "structure"
    if names & TIMERS:
        return "timer"
    if names & MATH:
        return "math"
    return "logic"


def alarm_sig(p: Project) -> dict:
    p.resolve_alarms()
    out = {}
    for a in p.alarms:
        vals = p.instance_values(p.tag(a.key))
        settings = {
            k: vals[k] for k in ("delay", "clear_delay", "cfg_reset") if k in vals
        }
        out[a.key] = {
            "kind": a.kind,
            "where": a.loc,
            "trigger": clip(a.trigger, 120),
            "operands": a.operands,
            "settings": settings,
        }
    return out


def msg_sig(p: Project) -> dict:
    out = {}
    for key, t in p.tags.items():
        if t.datatype == "MESSAGE":
            mp = t.elem.find(".//MessageParameters")
            out[key] = dict(mp.attrib) if mp is not None else {}
    return out


def cmd_diff(old_path: str, new_path: str, all_items: bool) -> None:
    old, new = Project(old_path), Project(new_path)
    print(
        f"{old.path.name} (software {old.software}) -> {new.path.name} (software {new.software})"
    )
    if old.c.get("ProcessorType") != new.c.get("ProcessorType"):
        print(
            f"  processor {old.c.get('ProcessorType')} -> {new.c.get('ProcessorType')}"
        )
    section("Tasks")
    ot, nt = {t[0]: t for t in old.tasks}, {t[0]: t for t in new.tasks}
    for k in sorted(set(ot) | set(nt)):
        if ot.get(k) != nt.get(k):
            print(f"  {k}: {ot.get(k)} -> {nt.get(k)}")
    section("Routines")
    o, n = set(old.routines), set(new.routines)
    for k in sorted(o - n):
        print(f"  removed {k[0]}/{k[1]}")
    for k in sorted(n - o):
        rt = new.routines[k]
        print(f"  added {k[0]}/{k[1]} [{rt.type}, {rt.size} {rt.unit}]")
    changes, cats = [], Counter()
    for k in sorted(o & n):
        a, b = old.routines[k], new.routines[k]
        if a.type != b.type:
            changes.append(f"[structure] {k[0]}/{k[1]} type {a.type} -> {b.type}")
            continue
        if a.type == "RLL":
            at = [norm(t) for _, t, _ in a.rungs]
            bt = [norm(t) for _, t, _ in b.rungs]
            sm = difflib.SequenceMatcher(None, at, bt, autojunk=False)
            for op, i1, i2, j1, j2 in sm.get_opcodes():
                if op == "equal":
                    for i, j in zip(range(i1, i2), range(j1, j2)):
                        if a.rungs[i][2] != b.rungs[j][2]:
                            cats["comment"] += 1
                            changes.append(
                                f"[comment] {k[0]}/{k[1]} rung {b.rungs[j][0]}: "
                                f"{clip(a.rungs[i][2], 60)!r} -> {clip(b.rungs[j][2], 60)!r}"
                            )
                    continue
                olds, news = a.rungs[i1:i2], b.rungs[j1:j2]
                text = " ".join(t for _, t, _ in olds + news)
                cat = rung_category(text, new)
                cats[cat] += max(len(olds), len(news))
                head = (
                    f"[{cat}] {k[0]}/{k[1]} old rungs {i1}-{i2 - 1} -> new rungs {j1}-{j2 - 1}"
                    if op == "replace"
                    else f"[{cat}] {k[0]}/{k[1]} {'removed old' if op == 'delete' else 'added new'} "
                    f"rungs {(i1 if op == 'delete' else j1)}-{(i2 if op == 'delete' else j2) - 1}"
                )
                body = [f"      - {clip(t, 300)}" for _, t, _ in olds] + [
                    f"      + {clip(t, 300)}" for _, t, _ in news
                ]
                changes.append(head + "\n" + "\n".join(body))
        elif a.type == "ST":
            diff = list(
                difflib.unified_diff(
                    [t.rstrip() for _, t in a.lines],
                    [t.rstrip() for _, t in b.lines],
                    lineterm="",
                    n=0,
                )
            )
            if diff:
                cats["st"] += 1
                changes.append(
                    f"[st] {k[0]}/{k[1]}\n" + "\n".join(f"      {d}" for d in diff[2:])
                )
        elif a.type == "FBD":

            def sig(rt):
                return Counter(
                    f"{e.tag}:{e.get('Type') or e.get('Name') or ''}:{e.get('Operand', '')}"
                    for s in rt.sheets
                    for e in s
                    if e.tag != "Wire"
                )

            sa, sb = sig(a), sig(b)
            if sa != sb:
                cats["fbd"] += 1
                changes.append(
                    f"[fbd] {k[0]}/{k[1]} removed {sorted((sa - sb).elements())} "
                    f"added {sorted((sb - sa).elements())}"
                )
    print(
        "  changed rungs by category: "
        + (", ".join(f"{c} {n}" for c, n in cats.most_common()) or "none")
    )
    show(changes, all_items)
    section("Tags")
    ok, nk = set(old.tags), set(new.tags)
    show(
        [
            f"removed {old.tags[k].where} ({old.tags[k].datatype})"
            for k in sorted(ok - nk)
        ],
        all_items,
    )
    show(
        [
            f"added {new.tags[k].where} ({new.tags[k].datatype})"
            for k in sorted(nk - ok)
        ],
        all_items,
    )
    changed = []
    for k in sorted(ok & nk):
        a, b = old.tags[k], new.tags[k]
        for attr in ("datatype", "dims", "access", "alias", "constant"):
            if getattr(a, attr) != getattr(b, attr):
                changed.append(
                    f"{b.where} {attr}: {getattr(a, attr)} -> {getattr(b, attr)}"
                )
    show(changed, all_items)
    section("AOIs")
    for k in sorted(set(old.aois) | set(new.aois)):
        a, b = old.aois.get(k), new.aois.get(k)
        if not a or not b or a.revision != b.revision or a.params != b.params:
            print(
                f"  {k}: {a.revision if a else 'absent'} -> {b.revision if b else 'absent'}"
                f"{' (parameters changed)' if a and b and a.params != b.params else ''}"
            )
    section("Alarm instances")
    oa, na = alarm_sig(old), alarm_sig(new)
    rows = [f"removed {k}" for k in sorted(set(oa) - set(na))]
    rows += [f"added {k} @ {na[k]['where']}" for k in sorted(set(na) - set(oa))]
    for k in sorted(set(oa) & set(na)):
        for field_name in ("kind", "trigger", "operands", "settings"):
            if oa[k][field_name] != na[k][field_name]:
                rows.append(
                    f"{k} {field_name}: {oa[k][field_name]} -> {na[k][field_name]}"
                )
    show(rows or ["no change"], all_items)
    section("Messages")
    om, nm = msg_sig(old), msg_sig(new)
    rows = [f"removed {k}" for k in sorted(set(om) - set(nm))]
    rows += [f"added {k}: {nm[k]}" for k in sorted(set(nm) - set(om))]
    for k in sorted(set(om) & set(nm)):
        for attr in sorted(set(om[k]) | set(nm[k])):
            if om[k].get(attr) != nm[k].get(attr):
                rows.append(f"{k} {attr}: {om[k].get(attr)} -> {nm[k].get(attr)}")
    show(rows or ["no change"], all_items)
    section("Module configuration")

    def mods(p):
        out = {}
        for m in p.modules:
            ct = m.find(".//ConfigTag")
            deco = next(
                (
                    d.find("Structure")
                    for d in (ct.iterfind("Data") if ct is not None else [])
                    if d.get("Format") == "Decorated"
                ),
                None,
            )
            out[m.get("Name")] = (
                m.get("CatalogNumber"),
                module_address(m),
                decorated_values(deco),
            )
        return out

    omod, nmod = mods(old), mods(new)
    rows = [f"removed {k}" for k in sorted(set(omod) - set(nmod))]
    rows += [f"added {k} {nmod[k][0]}" for k in sorted(set(nmod) - set(omod))]
    for k in sorted(set(omod) & set(nmod)):
        a, b = omod[k], nmod[k]
        if a[:2] != b[:2]:
            rows.append(f"{k}: {a[:2]} -> {b[:2]}")
        for path in sorted(set(a[2]) | set(b[2])):
            if a[2].get(path, (None, None))[1] != b[2].get(path, (None, None))[1]:
                rows.append(
                    f"{k}.{path}: {a[2].get(path, ('', None))[1]} -> {b[2].get(path, ('', None))[1]}"
                )
    show(rows or ["no change"], all_items)


# xchg --------------------------------------------------------------------


def element(text: str) -> tuple:
    m = re.match(r"^([A-Za-z_]\w*)\[(\d+)\]$", text.strip())
    return (m.group(1), int(m.group(2))) if m else (text.strip(), 0)


def elem_uses(p: Project, base: str, writes: bool) -> dict:
    """Uses of base[i] and base[i].bit keyed by (index, bit), with copies expanded by length."""
    out = defaultdict(list)
    key = base.lower()
    for u in p.uses:
        if u.key != key or u.routine == "(MSG)" or u.write != writes:
            continue
        m = re.match(rf"^{re.escape(key)}\[(\d+)\](?:\.(\d+))?", u.member)
        if not m:
            if u.member.startswith(key + "["):
                out[("indirect", None)].append(describe(p, u, writes))
            continue
        idx, bit = int(m.group(1)), (int(m.group(2)) if m.group(2) else None)
        span = 1
        up = u.instr.upper()
        if up in COPY | {"FLL"} and len(u.args) > 2 and u.args[2].isdigit():
            span = int(u.args[2])
            if u.argi == 0 and up in COPY:
                dest = p.tag(p.split_ref(u.program, u.args[1])[0])
                src = p.tag(key)
                if dest and src and dest.datatype in SIZES and src.datatype in SIZES:
                    span = span * SIZES[dest.datatype] // SIZES[src.datatype]
        for i in range(idx, idx + span):
            note = describe(p, u, writes) + (
                f" (+{i - idx} of {span})" if span > 1 else ""
            )
            out[(i, bit)].append(note)
    return out


def describe(p: Project, u: Use, writes: bool) -> str:
    """One line for what packs (writes) or unpacks (reads) an exchange element."""
    up = u.instr.upper()

    def typed(operand: str) -> str:
        tag = p.tag(p.split_ref(u.program, operand)[0])
        return f"{operand} ({tag.datatype})" if tag else operand

    if writes:
        if up in MOVES | COPY and u.args:
            return f"{u.instr} from {typed(u.args[0])} @ {u.routine} {u.where}"
        if up in ("OTE", "OTL", "OTU"):
            return (
                f"{u.instr} when {clip(u.cond, 60) or 'always'} @ {u.routine} {u.where}"
            )
        return f"{u.instr} @ {u.routine} {u.where}"
    if up in MOVES | COPY and len(u.args) > 1:
        return f"{u.instr} to {typed(u.args[1])} @ {u.routine} {u.where}"
    if up in INPUT_INSTR:
        return f"{u.instr} -> {u.feeds or '?'} @ {u.routine} {u.where}"
    return f"{u.instr}{'.' + u.param if u.param else ''} @ {u.routine} {u.where}"


def cmd_xchg(master_path: str, remote_path: str, link: str, all_items: bool) -> None:
    m, r = Project(master_path), Project(remote_path)
    msgs = []
    for t in m.tags.values():
        if t.datatype != "MESSAGE":
            continue
        mp = t.elem.find(".//MessageParameters")
        a = mp.attrib if mp is not None else {}
        if "Data Table" not in a.get("MessageType", ""):
            continue
        hay = " ".join(
            [t.name, a.get("LocalElement", ""), a.get("RemoteElement", "")]
        ).lower()
        if link and link.lower() not in hay:
            continue
        msgs.append((t, a))
    if not msgs:
        sys.exit(f"no CIP Data Table MSG in {m.path.name} matches '{link}'")
    remote_msgs = [t.where for t in r.tags.values() if t.datatype == "MESSAGE"]
    if remote_msgs:
        print(
            f"{r.path.name} also runs MSGs ({len(remote_msgs)}); a star topology has only the "
            f"master messaging: {', '.join(remote_msgs[:8])}"
        )
    for t, a in msgs:
        is_read = "Read" in a.get("MessageType", "")
        local = a.get("LocalElement") or a.get("DestinationTag") or ""
        length = int(a.get("RequestedLength", "0") or 0)
        sender, s_el, receiver, r_el = (
            (r, a.get("RemoteElement", ""), m, local)
            if is_read
            else (m, local, r, a.get("RemoteElement", ""))
        )
        (sb, ss), (rb, rs) = element(s_el), element(r_el)
        section(
            f"{t.name}: {a.get('MessageType')} length {length}, "
            f"{sender.path.name} {s_el} -> {receiver.path.name} {r_el}"
        )
        for p, base in ((sender, sb), (receiver, rb)):
            tag = p.tag(base.lower())
            if tag is None:
                print(f"  {p.path.name}: array {base} NOT FOUND at controller scope")
            else:
                dims = int(tag.dims.split()[0]) if tag.dims else 1
                need = (ss if p is sender else rs) + length
                print(
                    f"  {p.path.name}: {base} {tag.datatype}[{tag.dims}] access {tag.access}"
                    f"{'  TOO SMALL for the message' if need > dims else ''}"
                )
        sw, rr = elem_uses(sender, sb, True), elem_uses(receiver, rb, False)
        rows, counts = [], Counter()
        keys = {(i - ss, b) for (i, b) in sw if i != "indirect"} | {
            (i - rs, b) for (i, b) in rr if i != "indirect"
        }

        def word_or_bits(uses: dict, idx: int, bit) -> bool:
            """A bit is covered by a whole-word use; a word is covered by any of its bits."""
            if bit is None:
                return any(i == idx and v for (i, b), v in uses.items())
            return bool(uses.get((idx, None)))

        def method(notes: list) -> set:
            return {x.split()[0].upper() for x in notes} & (MOVES | COPY)

        unguarded = 0
        for off, bit in sorted(
            keys, key=lambda k: (k[0], -1 if k[1] is None else k[1])
        ):
            w = sw.get((off + ss, bit), [])
            rd = rr.get((off + rs, bit), [])
            status = "ok"
            if off >= length or off < 0:
                status = "BEYOND LENGTH"
            elif w and not rd and not word_or_bits(rr, off + rs, bit):
                status = "sent, nothing reads it"
            elif rd and not w and not word_or_bits(sw, off + ss, bit):
                status = "read, nothing sends it"
            elif (
                method(w)
                and method(rd)
                and bool(method(w) & COPY) != bool(method(rd) & COPY)
                and any("(REAL)" in x or "(LREAL)" in x for x in w + rd)
            ):
                status = "REAL moved by MOVE at one end, bit-copied at the other"
            counts[status] += 1
            label = f"[{off}]" + (f".{bit}" if bit is not None else "")
            rows.append(
                f"{label:>9} {status:<22} send: {'; '.join(w) or '-'}"
                f" | recv: {'; '.join(rd) or '-'}"
            )
        for u in receiver.uses:
            if (
                u.key == rb.lower()
                and not u.write
                and not u.cond
                and u.routine != "(MSG)"
            ):
                unguarded += 1
        print("  " + ", ".join(f"{k} {n}" for k, n in counts.most_common()))
        show(
            [x for x in rows if not x.split()[1:2] == ["ok"]]
            + [x for x in rows if x.split()[1:2] == ["ok"]],
            all_items,
        )
        for side, uses in (("send", sw), ("recv", rr)):
            if ("indirect", None) in uses:
                print(
                    f"  {side} side has indirect (computed index) uses: {uses[('indirect', None)][:3]}"
                )
        if unguarded:
            print(
                f"  {unguarded} receiver reads have no rung condition; check what the receiving end "
                f"does with stale data on comm loss"
            )


# routine and xref --------------------------------------------------------


def cmd_routine(path: str, name: str) -> None:
    p = Project(path)
    prog, _, rname = name.rpartition("/")
    hits = [
        rt
        for (pr, r), rt in p.routines.items()
        if r.lower() == rname.lower() and (not prog or pr.lower() == prog.lower())
    ]
    if not hits:
        sys.exit(f"no routine {name} in {p.path.name}")
    for rt in hits:
        callers = [
            f"{c.program}/{c.caller} {c.where}{' (conditional)' if c.conditional else ''}"
            for c in p.calls
            if c.program == rt.program and c.target.lower() == rt.name.lower()
        ]
        print(
            f"{rt.program}/{rt.name} [{rt.type}, {rt.size} {rt.unit}] called from: "
            f"{', '.join(callers) or 'nowhere'}"
        )
        if rt.description:
            print(f"  description: {rt.description}")
        for num, text, cmt in rt.rungs:
            if cmt:
                for line in cmt.splitlines():
                    print(f"      // {line.strip()}")
            print(f"  {num:>4}: {text}")
        for num, text in rt.lines:
            print(f"  {num:>4}: {text}")
        for si, sheet in enumerate(rt.sheets, 1):
            print(f"  sheet {si}:")
            els = {e.get("ID"): e for e in sheet}
            for e in sheet:
                if e.tag in ("Block", "AddOnInstruction"):
                    pins = []
                    for w in sheet.iter("Wire"):
                        if w.get("ToID") == e.get("ID"):
                            src = els.get(w.get("FromID"))
                            src_name = (
                                src.get("Operand") if src is not None else "?"
                            ) or "?"
                            if src is not None and w.get("FromParam"):
                                src_name += "." + w.get("FromParam", "")
                            pins.append(f"{w.get('ToParam')}<-{src_name}")
                    print(
                        f"    {e.get('Type') or e.get('Name')} {e.get('Operand', '')}: {', '.join(pins)}"
                    )
                elif e.tag == "ORef":
                    print(f"    ORef {e.get('Operand')}")


def cmd_xref(path: str, query: str) -> None:
    p = Project(path)
    q = norm(query)
    head = re.split(r"[.\[]", q, maxsplit=1)[0]
    keys = {k for k in p.tags if k == head or k.endswith("/" + head)}
    for k in sorted(keys):
        t = p.tags[k]
        print(
            f"{t.where}: {t.datatype}{'[' + t.dims + ']' if t.dims else ''}, {t.tagtype}"
            f"{' alias for ' + t.alias if t.alias else ''}, access {t.access}"
            f"{', constant' if t.constant else ''}"
        )
        if t.description:
            print(f"  description: {clip(t.description, 200)}")
    if not keys:
        print(f"{query}: no tag declaration (module, system or AOI-local reference?)")
        keys = {head}
    tail = q[len(head) :]

    def covers(longer: str, shorter: str) -> bool:
        """True when shorter is longer itself or a whole parent member or element of it."""
        return longer.startswith(shorter) and longer[
            len(shorter) : len(shorter) + 1
        ] in (
            "",
            ".",
            "[",
        )

    hits = [
        u
        for u in p.uses
        if u.key in keys
        and (
            covers(u.member[len(u.key) :], tail) or covers(tail, u.member[len(u.key) :])
        )
    ]
    for label, group in (
        ("Writers", [u for u in hits if u.write]),
        ("Readers", [u for u in hits if not u.write]),
    ):
        print(f"\n{label} ({len(group)}):")
        for u in group:
            param = f" [{u.param}]" if u.param else ""
            print(f"  {u.loc}: {u.instr}{param} {u.text}  | {clip(u.context, 150)}")


def main(argv: list) -> None:
    all_items = "--all" in argv
    args = [a for a in argv if a != "--all"]
    if not args:
        sys.exit(__doc__)
    cmd, rest = args[0], args[1:]
    if cmd == "map" and len(rest) == 1:
        cmd_map(rest[0], all_items)
    elif cmd == "diff" and len(rest) == 2:
        cmd_diff(rest[0], rest[1], all_items)
    elif cmd == "xchg" and len(rest) in (2, 3):
        cmd_xchg(rest[0], rest[1], rest[2] if len(rest) == 3 else "", all_items)
    elif cmd == "routine" and len(rest) == 2:
        cmd_routine(rest[0], rest[1])
    elif cmd == "xref" and len(rest) == 2:
        cmd_xref(rest[0], rest[1])
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv[1:])
