# Claude Code config

The claude role links the global Claude Code config from `roles/claude/files/` into `~/.claude/`, links each custom skill folder and hook script, registers the user-scoped MCP servers, and updates third-party skills with the `skills` CLI.

## Sub-features

- `claude-core` links `CLAUDE.md`, `settings.json`, `statusline.sh`, and `claude-app-preferences.md` into `~/.claude/`.
- `claude-skills` links every folder in `roles/claude/files/skills/` into `~/.claude/skills/`.
- `claude-hooks` links every `*.sh` in `roles/claude/files/hooks/` into `~/.claude/hooks/`.
- `claude-mcp` adds `submittalkit` and `submittalkit-admin` with `claude mcp add --scope user` when `claude mcp get` finds them missing.
- `claude-skills-update` runs `npx --yes skills update --global --yes`.

## How to get to it (user POV)

- Run `dotfiles -t claude`.
- Run `dotfiles` with no tags, since `claude` is in `default_roles`.

## Driving it with verify.sh

Preconditions:

- `verify.sh doctor` reports `ok   claude binary at ~/.local/bin/claude`.
- Network access, for `claude mcp get` health checks and `npx`.

- **Converge.** Run `$V sandbox claude`. Run 1 prints `failed=0` with `changed` above zero. Run 2 prints `changed=0 failed=0`.
- **Core links.** `grep '^./.claude/[^/]* ->' <evidence>/tree.txt` shows the four core files pointing into `roles/claude/files/`.
- **Skills and hooks.** `tree.txt` has one `./.claude/skills/<name> ->` line per folder in `ls roles/claude/files/skills` and one `./.claude/hooks/<name>.sh ->` line per hook script.
- **MCP registration.** `run1.log` shows `changed` for both items under `Register user-scoped MCP servers`, and `run2.log` shows `ok`. `jq '.mcpServers' <sandbox>/.claude.json` lists both servers with their `https://submittalkit.com` URLs.
- **Real home untouched.** `jq -r '.mcpServers|keys[]' ~/.claude.json` and `readlink ~/.claude/settings.json` match their values from before the run.
- **Check mode.** Run `$V check claude`. Every link task reports `ok` on a synced machine, and both MCP and skills-update tasks report `skipping`.
- **Proof.** Keep the sandbox evidence directory and quote both recap lines from `summary.txt`.

## Gotchas

- Check mode skips `claude-mcp` and `claude-skills-update` because they are `shell` and `command` tasks. Only `sandbox` proves them.
- The sandbox starts with no `.claude.json`, so run 1 always takes the `mcp add` branch. The real home normally takes the `present` branch.
- In the sandbox, `skills update --global` finds no installed skills and reports `ok`. That proves the command runs, not that real skills update.
- `~/.claude.json` mtime moves during the run because this Claude session writes it. Compare `mcpServers`, not mtime.
- A skill folder added to `roles/claude/files/skills/` is picked up by the `find` task with no playbook edit. A removed folder leaves a dangling link in the real `~/.claude/skills/`, which the role does not prune.
