# Claude Code mods

Each folder is a plugin of function hooks that Claude Code loads into its own process.
`settings.json` lists every folder in `CLAUDE_CODE_PLUGIN_DIRS`, so a new session loads them
and an edit to one reloads it live.

| Mod | What it does |
|---|---|
| `plan-progress` | Pane listing what's left in `.scratch/<branch>/plan.md`, the live task list under the current step, then what's done. `/progress` opens it. |
| `verify-status` | Counts files edited since the last passing test run and shows `! N edits untested` in the status line. |
| `prod-guard` | Holds `kamal deploy`, prod `psql` and destructive `make` targets in a dialog that shows what would ship. |
| `diff-colors` | Draws Edit and Write diffs in blue (added) and orange (removed), each line marked `+` or `−`. |
| `worktrees` | `/worktrees` pane: prune worktrees whose folder is gone, remove merged ones with no changes. |

## Working on a mod

- `claude plugin validate <folder>` lists what the mod hooks and calls, and what the engine would refuse.
- `claude plugin test <folder>` runs its `tests/*.test.ts`.
- Once a session has loaded a mod, `.claude-plugin/types/` holds the API types (gitignored) and
  `tsc -p <folder>` type-checks it.
- To turn one off, drop its folder from `CLAUDE_CODE_PLUGIN_DIRS`.
