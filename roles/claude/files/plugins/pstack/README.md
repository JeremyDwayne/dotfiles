# pstack for Claude Code

A Claude Code port of [poteto](https://x.com/poteto)'s pstack, from [cursor/plugins@ccb5507](https://github.com/cursor/plugins/tree/ccb5507cec1546dc88135c1139c811e6c59115ba/pstack). The method is poteto's: go deep before going fast, write less code, prove it works, and parallelize only once one agent can be trusted. The port changes the mechanics so the skills run on Claude Code's tools.

## Install

`settings.json` in the `claude` role declares `roles/claude/files/plugins` as the `dotfiles` marketplace and enables `pstack@dotfiles`. The marketplace loads the plugin in place, so an edit here applies on the next session or after `/reload-plugins`.

## Use

Type `/pstack:poteto-mode` at the start of a task that needs rigor. It matches the task to a playbook, copies the playbook's steps into the todo list, and reads the other skills and principles as the steps need them. Once loaded it stays in context for the rest of the session.

```
/pstack:poteto-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro first, then fix and verify.
/pstack:poteto-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by morning.
/pstack:how do we cancel runs? do we have an n+1 when we look up every run to cancel?
/pstack:interrogate review this pr.
```

Unsure which skill fits? Ask `/pstack:poteto-help`.

Every skill sets `disable-model-invocation: true`. Their descriptions stay out of context, Claude never loads one on its own, and poteto-mode reaches them by reading their files. You reach them with `/pstack:<name>`.

## Layout

- `skills/poteto-mode/` holds the router, 23 playbooks in `playbooks/`, the review-bot triage rubric in `references/`, and `scripts/check-plan.mjs` and `scripts/worktree-audit.sh`.
- `skills/` holds the other skills: `how`, `why`, `teach`, `recall`, `blast-radius`, `architect`, `arena`, `swarm`, `interrogate`, `reflect`, `correct`, `automate-me`, `figure-it-out`, `show-me-your-work`, `benchmark-checklist`, `no-comments`, `tdd`, `typescript-best-practices`, `technical-writing`, `unslop`, `bro`, `create-verification-skill`, `maintain-verification-skill`, and `poteto-help`.
- `principles/` holds the 24 principles, one file each. poteto-mode indexes them inline and reads a file when it applies that principle.
- `agents/` holds `pstack:poteto-agent`, the subagent poteto-mode spawns for playbook work, and `pstack:comment-sicko`, the read-only reviewer behind `no-comments`.
- `models.md` maps each role to a Claude model. Edit a line to change a role.

## Differences from the Cursor version

- Panels run on Claude models only. `models.md` replaces `/setup-pstack` and its per-role rule file. The default puts code delegates and workers on `sonnet`, and judgment, prose, and the hardest changes on `opus`. Arena, architect, and interrogate panels run one `opus` and one `sonnet`.
- Principles moved from 24 skills to plain files in `principles/`.
- Subagents run through the Agent tool. Cloud workers use `isolation: "remote"`, and writers get `isolation: "worktree"`. A finished subagent cannot be resumed, so follow-up work always goes to a fresh agent with consolidated scope.
- `gh` is the only forge. The `watch-pr` and `orch` TypeScript tools are gone. Babysit and Shipping watch PRs with `gh pr checks --watch` under the Monitor tool, and Orchestrate keeps its store as plain files.
- Cursor team-kit skills map to Claude Code ones: `deslop` to `/simplify`, `control-ui` to `claude-in-chrome`, `control-cli` to `run` and tmux, `create-skill` to `writing-for-agents`.
- Transcript mining reads `~/.claude/projects/<slug>/<session>.jsonl`.
- Not ported: `make-bot-ui`, the benny automation pack, and the Cursor guide.

## License

MIT, copyright Lauren Tan. See `LICENSE`.
