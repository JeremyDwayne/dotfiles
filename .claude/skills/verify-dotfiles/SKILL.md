---
name: verify-dotfiles
description: Verify the dotfiles Ansible playbook by running roles the way `dotfiles -t <role>` does, in check mode against the real home or for real into a throwaway home. Use to prove a role change (symlinks, Claude config, git config, Homebrew packages, role selection) works before committing or filing a PR.
---

# Verify dotfiles

The surface is the Ansible playbook `main.yml`, which a user runs through `dotfiles [ansible args]`. That wrapper also runs `git pull` on this checkout and upgrades Galaxy collections, so verification drives `ansible-playbook main.yml` from the repo root with the same arguments. Every command goes through `verify.sh` in this folder.

There are two modes. Pick the strongest one the role allows.

- `check` runs `--check --diff` against the real home. It is read-only and works for every role. It proves what *would* change, and it skips every `shell` and `command` task.
- `sandbox` runs the role for real, twice, into a fresh home under `$TMPDIR/verify-dotfiles/`. It overrides the `user_dir` fact and `HOME`, so links, `git config --global`, `claude mcp add`, and `npx` all land in the sandbox. It is the only mode that proves a role converges and is idempotent. It refuses roles with Homebrew tasks, because those install on the real machine.

## Launch

There is no server. The playbook is short-lived and each run is its own process.

```sh
.claude/skills/verify-dotfiles/verify.sh doctor
```

Ready means the last line is `doctor: ready`. The script needs ansible-playbook (Homebrew), the `community.general` collection in `~/.ansible/collections`, and `~/.ansible-vault/vault.secret` for the git and ssh roles.

## Doctor

`verify.sh doctor` is read-only. It checks ansible-playbook, the collection, the vault secret, and `main.yml --syntax-check`. It reports the branch, HEAD, dirty path count, default roles, whether mise is outdated, the `~/.local/bin/claude` binary, and leftover sandboxes. Run it first, and again whenever a run fails unexpectedly.

## Drive

```sh
V=.claude/skills/verify-dotfiles/verify.sh
$V check <role>                                 # one role, read-only
$V check all                                    # default role list, read-only
$V check all -e '{"exclude_roles":["go"]}'      # extra args pass to ansible-playbook
$V sandbox <role>                               # real run into a throwaway home, twice
ALLOW_BREW=1 $V sandbox <role>                  # Homebrew roles, only after the user agrees
```

Each run prints one `exit=<code> localhost : ok=.. changed=.. failed=..` line per playbook run and the evidence path. A sandbox run prints the sandbox path too. Inspect it before cleanup: `ls -la`, `readlink`, `HOME=<sandbox> git config --global --list`.

Sandbox mechanics, so a failure is readable. The run uses `--start-at-task "Run roles"` with `-e` setting `ansible_facts.user_dir` and `run_roles`. That skips main.yml's pre_tasks, which install mise with Homebrew and create `~/.config`. The script creates `<sandbox>/.config` and links the real claude binary into `<sandbox>/.local/bin/claude` as verification scaffolding, and cleanup removes both with the sandbox. Ansible itself keeps `ANSIBLE_HOME` and the collections path on the real home so it can load `community.general`.

The feature recipes live in [`features/README.md`](features/README.md). Read the index, then follow the file for the feature you are proving.

## Evidence

Every run writes `.scratch/<branch>/verify-dotfiles/<UTC timestamp>-<mode>-<role>/`:

- `commands.txt` holds the exact ansible-playbook invocations.
- `summary.txt` holds the exit code and recap line per run.
- `check.log`, or `run1.log` and `run2.log`, hold the full default-callback output with diffs.
- `tree.txt` (sandbox) lists every path in the sandbox home with symlink targets.
- `extra-vars.json` and `sandbox.path` (sandbox) record how the run was isolated.

Proof standards:

- Drive the role through `main.yml` with `-t <role>`, the same path `dotfiles -t <role>` takes. Running a task file directly skips role selection and is not proof.
- A sandbox proof needs run 1 `failed=0`, run 2 `changed=0 failed=0`, and `tree.txt` showing each expected link pointing into `roles/<role>/files/`.
- A check proof names every `changed` task and explains each one. An unexplained `changed` is a finding.
- Prove side effects outside the playbook output as well: the sandbox `.claude.json` has `mcpServers`, `git config --global` in the sandbox has the values, links resolve.
- Prove isolation by observing the real home: compare `readlink` targets or file contents before and after. `~/.claude.json` is rewritten constantly by any running Claude session, so its mtime proves nothing; compare its `mcpServers` with `jq` instead.
- Never copy sandbox file contents into evidence. The ssh role writes private keys there, and the git role writes the vault-decrypted email.

## Cleanup

```sh
.claude/skills/verify-dotfiles/verify.sh cleanup
```

It removes `$TMPDIR/verify-dotfiles/`, which holds only sandboxes this script created, and leaves `.scratch/<branch>/verify-dotfiles/` intact. Check mode creates nothing to clean. Run cleanup after every sandbox run, failed ones included, and once more before reporting.

## Gotchas

- Ansible exits with `requires blocking IO` when its stdio is a pipe in some harnesses. `verify.sh` redirects stdin from `/dev/null` and output to log files; do the same for any ad hoc ansible command.
- `/usr/bin/env bash` here is bash 3.2. An empty array expanded under `set -u` aborts the script.
- Check mode reports `Install mise` and Homebrew tasks as `changed` whenever the package is outdated. That is a pending upgrade, not a role bug.
- Any `brew` call auto-updates Homebrew taps unless `HOMEBREW_NO_AUTO_UPDATE=1`, which `verify.sh` sets.
