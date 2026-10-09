#!/usr/bin/env bash
# Drive the dotfiles playbook for verification.
#   verify.sh doctor                            read-only health check
#   verify.sh check <role|all> [ansible args]   check-mode diff against the real home
#   verify.sh sandbox <role>                    real run into a throwaway home, twice
#   verify.sh cleanup                           remove throwaway homes this script made
# Evidence lands in .scratch/<branch>/verify-dotfiles/<run-id>/ and survives cleanup.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
VAULT="$HOME/.ansible-vault/vault.secret"
SANDBOX_ROOT="${TMPDIR:-/tmp}"
SANDBOX_ROOT="${SANDBOX_ROOT%/}/verify-dotfiles"
BRANCH="$(git -C "$REPO" rev-parse --abbrev-ref HEAD)"
EVIDENCE_ROOT="$REPO/.scratch/$BRANCH/verify-dotfiles"

export ANSIBLE_STDOUT_CALLBACK=ansible.builtin.default
export ANSIBLE_NOCOLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1

die() { echo "verify.sh: $*" >&2; exit 2; }

new_run() {
  RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$1-$2"
  EVIDENCE="$EVIDENCE_ROOT/$RUN_ID"
  mkdir -p "$EVIDENCE"
}

vault_args() { [[ -f "$VAULT" ]] && echo "--vault-password-file $VAULT"; }

# Runs ansible-playbook from the repo root with stdio detached; ansible refuses non-blocking stdio.
playbook() {
  local log="$1"; shift
  echo "ansible-playbook $(vault_args) main.yml $*" >>"$EVIDENCE/commands.txt"
  (cd "$REPO" && env "${RUN_ENV[@]}" ansible-playbook $(vault_args) main.yml "$@" </dev/null >"$log" 2>&1)
  local code=$?
  echo "exit=$code $(grep -E '^localhost +:' "$log")" | tee -a "$EVIDENCE/summary.txt"
  return $code
}

doctor() {
  local ok=1
  command -v ansible-playbook >/dev/null && ansible-playbook --version </dev/null 2>&1 | head -1 || { echo "FAIL ansible-playbook missing"; ok=0; }
  ansible-galaxy collection list community.general </dev/null 2>/dev/null | grep -q community.general \
    && echo "ok   community.general installed" || { echo "FAIL community.general missing"; ok=0; }
  [[ -f "$VAULT" ]] && echo "ok   vault secret present" || echo "warn vault secret missing: git and ssh roles cannot decrypt"
  (cd "$REPO" && ansible-playbook main.yml --syntax-check </dev/null >/dev/null 2>&1) \
    && echo "ok   main.yml syntax" || { echo "FAIL main.yml syntax-check"; ok=0; }
  echo "info repo $BRANCH @ $(git -C "$REPO" rev-parse --short HEAD), $(git -C "$REPO" status --porcelain | wc -l | tr -d ' ') dirty paths"
  echo "info default roles: $(sed -n '/^default_roles:/,/^$/p' "$REPO/group_vars/all.yml" | sed -n 's/^  - //p' | tr '\n' ' ')"
  brew outdated --formula --quiet mise </dev/null >/dev/null 2>&1 \
    && echo "info mise current" || echo "info mise outdated: a full run's pre_task would upgrade it"
  [[ -x "$HOME/.local/bin/claude" ]] && echo "ok   claude binary at ~/.local/bin/claude" || echo "warn ~/.local/bin/claude missing: claude role MCP task fails"
  ls -d "$SANDBOX_ROOT"/* 2>/dev/null | sed 's/^/info leftover sandbox: /'
  [[ $ok == 1 ]] && echo "doctor: ready" || { echo "doctor: not ready"; return 1; }
}

check() {
  local role="${1:-}"; [[ -n "$role" ]] || die "usage: check <role|all> [ansible args]"
  shift
  new_run check "$role"
  RUN_ENV=(PATH="$PATH")
  playbook "$EVIDENCE/check.log" --check --diff -t "$role" ${@+"$@"}
  local code=$?
  echo "evidence: $EVIDENCE"
  return $code
}

sandbox() {
  local role="${1:-}"; [[ -n "$role" ]] || die "usage: sandbox <role>"
  [[ -d "$REPO/roles/$role" ]] || die "no role $role"
  if grep -q 'community.general.homebrew' "$REPO/roles/$role/tasks/main.yml" && [[ "${ALLOW_BREW:-}" != 1 ]]; then
    die "$role installs with Homebrew on the real machine; use 'check $role', or ALLOW_BREW=1 after the user agrees"
  fi
  new_run sandbox "$role"
  local home; home="$(mkdir -p "$SANDBOX_ROOT" && mktemp -d "$SANDBOX_ROOT/$RUN_ID.XXXX")"
  echo "$home" >"$EVIDENCE/sandbox.path"
  # Scaffolding: main.yml's skipped pre_task makes ~/.config, and the claude role calls ~/.local/bin/claude.
  mkdir -p "$home/.config" "$home/.local/bin"
  [[ -x "$HOME/.local/bin/claude" ]] && ln -s "$(readlink -f "$HOME/.local/bin/claude")" "$home/.local/bin/claude"
  printf '{"ansible_facts":{"user_dir":"%s"},"run_roles":["%s"]}\n' "$home" "$role" >"$EVIDENCE/extra-vars.json"
  RUN_ENV=(HOME="$home" PATH="$PATH" ANSIBLE_HOME="$HOME/.ansible" ANSIBLE_COLLECTIONS_PATH="$HOME/.ansible/collections")
  local args=(--start-at-task "Run roles" -e "@$EVIDENCE/extra-vars.json" -t "$role" --diff)
  playbook "$EVIDENCE/run1.log" "${args[@]}"; local c1=$?
  playbook "$EVIDENCE/run2.log" "${args[@]}"; local c2=$?
  (cd "$home" && find . -path ./.npm -prune -o -path ./.cache -prune -o \( -type l -o -type f -o -type d \) -print \
    | sort | while read -r p; do
        if [[ -L "$p" ]]; then echo "$p -> $(readlink "$p")"; elif [[ -d "$p" ]]; then echo "$p/"; else echo "$p"; fi
      done) >"$EVIDENCE/tree.txt"
  echo "sandbox: $home"
  echo "evidence: $EVIDENCE"
  [[ $c1 == 0 && $c2 == 0 ]]
}

cleanup() {
  [[ -d "$SANDBOX_ROOT" ]] || { echo "nothing to clean"; return 0; }
  ls -d "$SANDBOX_ROOT"/* 2>/dev/null | sed 's/^/removing /'
  rm -rf "$SANDBOX_ROOT"
  echo "evidence kept in $EVIDENCE_ROOT"
}

case "${1:-}" in
  doctor) doctor ;;
  check) shift; check "$@" ;;
  sandbox) sandbox "${2:-}" ;;
  cleanup) cleanup ;;
  *) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
