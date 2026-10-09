# Dotfiles verification map

This directory is the maintained source for verifying what the dotfiles playbook does to a Mac. Read the index, then use the matching feature file as the recipe.

## Baseline preconditions

- Work from the repo root, `~/.dotfiles` or a worktree of it.
- `verify.sh doctor` ends with `doctor: ready`.
- No leftover sandbox under `$TMPDIR/verify-dotfiles/`, or run `verify.sh cleanup` first.
- Drive only sandboxes this run created. The real home is touched only by `check`, which is read-only.

## Driving conventions

- Every command is `verify.sh <mode> <role>`, where `V=.claude/skills/verify-dotfiles/verify.sh`.
- Use `sandbox` for roles without Homebrew tasks (`claude`, `ssh`, `ruby`) and `check` for the rest. `ALLOW_BREW=1` needs the user's agreement first, because it installs and upgrades real packages.
- Pass extra ansible arguments after the role in `check`, for example `-e '{"exclude_roles":["go"]}'`.
- Treat every command as literal.

## Proof and skip reporting

- A proof names the mode, role, evidence directory, and the recap line of each run.
- A sandbox proof includes run 2 at `changed=0` and the relevant `tree.txt` lines.
- A check proof accounts for every `changed` task.
- Report a path verified only in check mode as "check mode only". It does not prove `shell` or `command` tasks, which check mode skips.
- Do not report a skipped role as verified through a different role.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify.sh` starts with `Preconditions:` and uses labeled bullets that pair each user action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

## Features

- [Role selection](./role-selection.md) covers the default role list, `-t` tags, and `exclude_roles`.
- [Claude Code config](./claude-config.md) covers `~/.claude` links, skills, hooks, MCP registration, and the skills update.
- [Config links](./config-links.md) covers the symlinked configs for zsh, starship, ghostty, neovim, postgresql, ruby, and karabiner.
- [Git config](./git-config.md) covers global git settings, aliases, signing, and the ignore and message files.
- [Homebrew packages](./homebrew-packages.md) covers the `dependencies` list and per-role installs.

Not mapped: the ssh role writes vault-decrypted private keys, so prove it with `sandbox ssh` and `tree.txt` names only. The `dotfiles` wrapper runs `git pull` and a Galaxy upgrade, so it is never driven during verification.
