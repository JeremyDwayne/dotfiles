---
name: poteto-help
description: Guides users through pstack setup, /pstack:poteto-mode, and picking the skill, playbook, or principle for a task. Type /pstack:poteto-help with a question.
disable-model-invocation: true
---

# Poteto help

Answer the user's question about pstack, hand them a prompt they can send, and link the file the answer came from. For a help question, don't start the work. The user asked how, and a pstack run spends real tokens, so let them send the prompt.

A message that asks for work, such as "use pstack to fix this bug", is not a help question. Read `${CLAUDE_PLUGIN_ROOT}/skills/poteto-mode/SKILL.md`, do the work under it, and mention once that typing `/pstack:poteto-mode` loads it for the rest of the session.

This file maps questions to the skills and playbooks that hold the answers. Those files own the details. Each skill is at `${CLAUDE_PLUGIN_ROOT}/skills/<name>/SKILL.md`, each playbook at `${CLAUDE_PLUGIN_ROOT}/skills/poteto-mode/playbooks/<name>.md`, and each principle at `${CLAUDE_PLUGIN_ROOT}/principles/<name>.md`. Read the file you route to before you quote it, and trust it when it disagrees with this map. The plugin loads in place from the user's dotfiles, so give the user the file's path under `~/.dotfiles/roles/claude/files/plugins/pstack/`.

## Find out what they need

Infer the need from the message and the conversation. A named situation, such as "which skill reviews a PR?", goes straight to its section. If the need is still unclear, ask one multiple-choice question with these options, then answer only the section they pick:

- Get set up
- Start a task with `/pstack:poteto-mode`
- Pick a skill for a situation
- Fix a run that went wrong
- Make pstack my own

Check the state that changes the answer, and mention it only when it does:

- `${CLAUDE_PLUGIN_ROOT}/models.md` sets the model for each role. Quote its rows when the question is about setup, cost, or which models run.
- No `verify-*` skill or other app harness in the project means agents have no scripted way to drive the app. Mention `/pstack:create-verification-skill` when the question is about proving a change works.

## Get set up

1. pstack ships in the user's dotfiles. The `claude` role's `settings.json` declares the `dotfiles` plugin marketplace and enables `pstack@dotfiles`, and `dotfiles -t claude` symlinks that file into `~/.claude/`. The plugin loads in place, so an edit applies on the next session or after `/reload-plugins`.
2. Pick models by editing `models.md` in the plugin. It has one line per role, and each value is `opus`, `sonnet`, `haiku`, `fable`, or `inherit`. A panel role takes a list. Skills read the file when they spawn a subagent.
3. Start a real task with `/pstack:poteto-mode`, a goal, and a check that can pass or fail.

Installing changes nothing until the user invokes a skill. Every pstack skill sets `disable-model-invocation`, so none loads on its own. Offer to word their first prompt with them, per [`references/prompting.md`](references/prompting.md).

If cost is the worry, say where the tokens go and how to spend fewer. pstack spends extra tokens on subagents and review panels. Edit `models.md` to move roles to cheaper models. A role set to `inherit` runs on the session's model. A shorter panel list runs fewer subagents, one for each entry. Save `/pstack:poteto-mode` for work that needs rigor.

## Start a task with `/pstack:poteto-mode`

`/pstack:poteto-mode` matches the task to a playbook, copies the playbook's steps into the todo list, and runs the other skills as the steps need them. A step it skips stays in the list as `skip: <reason>`. A good prompt states the goal and how to tell it's done. It doesn't list skills, because a hand-written sequence tends to drop or reorder steps the playbook would keep. Read [`references/prompting.md`](references/prompting.md) before you help word one. [`references/recipes.md`](references/recipes.md) has examples.

Once loaded, `/pstack:poteto-mode` stays in context for the rest of the session. A new session starts without it, so start each new session's task with `/pstack:poteto-mode`.

Mid-session, "new task" makes the mode match a fresh playbook. `/pstack:poteto-mode` already uses `poteto-agent` for the subagents its playbook steps spawn. To get the same style from a subagent of your own, spawn it with `subagent_type: "pstack:poteto-agent"`.

## Pick a skill

The default answer is `/pstack:poteto-mode`, which runs most of the others when its steps need them. Name a skill directly when the user wants more or less of something than the playbook gives. Read the skill before you recommend it, and give one example prompt.

| The user wants to | Skill |
|---|---|
| Do any non-trivial task with rigor | `/pstack:poteto-mode` |
| Know how code works now, or where new code should live | `/pstack:how` |
| Know why code is shaped this way, or where a number came from | `/pstack:why` |
| Understand a change or subsystem, explained plainly | `/pstack:teach` |
| Catch up on their own recent work on a topic | `/pstack:recall` |
| Know what a small diff could break outside itself | `/pstack:blast-radius` |
| Settle types and module shape before code that crosses a function boundary | `/pstack:architect` |
| Get several attempts at one brief, merged into the best one | `/pstack:arena` |
| Run parallel checks over slices, or race workers, as remote or worktree agents | `/pstack:swarm` |
| Have different models review a diff and try to break it | `/pstack:interrogate` |
| Fix a bug test-first when a cheap local test exists | `/pstack:tdd` |
| Apply TypeScript rules to `.ts` or `.tsx` work | `/pstack:typescript-best-practices` |
| Strip comments before review, using a reviewer that didn't write them | `/pstack:no-comments` |
| Clean AI tells out of prose | `/pstack:unslop` |
| Write docs, an RFC, a README, a PR description, or a commit message to a standard | `/pstack:technical-writing` |
| Hear the last reply again in plain words | `/pstack:bro` |
| Give agents a scripted way to drive the app and prove behavior | `/pstack:create-verification-skill` |
| Bring a verification skill and its feature map back in line with the app | `/pstack:maintain-verification-skill` |
| Vet a performance number before reporting or acting on it | `/pstack:benchmark-checklist` |
| Run a large or cross-cutting change, or one to review after stepping away | `/pstack:figure-it-out` |
| Keep a decision log during a run, and review it afterward | `/pstack:show-me-your-work` |
| Pick a model for each role | Edit `models.md` in the plugin |
| Turn their own working habits into a personal mode skill | `/pstack:automate-me` |
| Turn what a finished task taught into skill edits | `/pstack:reflect` |
| Stop agents from repeating the same mistakes in this repo | `/pstack:correct` |
| Find their way around pstack | `/pstack:poteto-help` |

If a skill directory under `${CLAUDE_PLUGIN_ROOT}/skills/` is missing from the table, read its frontmatter and route by its description. Principles live in `${CLAUDE_PLUGIN_ROOT}/principles/` and are covered below.

Close calls:

- `/pstack:how` explains what the code does. `/pstack:why` explains the reasons. `/pstack:teach` runs one or both and explains the result plainly.
- `/pstack:arena` gives every worker the same brief and merges the best parts. `/pstack:swarm` splits work into slices or a race and returns one report.
- `/pstack:architect` implements right after it settles the design. Add "with checkpoint" to review the design before it writes code.
- `/pstack:interrogate` reviews the diff. `/pstack:blast-radius` looks for breakage outside the diff and proves the one fact that makes the change safe.
- `/pstack:recall` rebuilds context across recent chats. Resuming one specific chat or branch is the Session pickup playbook.
- `/pstack:figure-it-out` designs one rigorous run. The Orchestrate playbook runs a program that spans days and many PRs. The Autonomous run playbook drives one task to a finish condition.

Not in pstack:

- `/simplify` is a Claude Code built-in. The `claude-in-chrome` skill drives a browser, and the `run` skill launches and drives an app.
- `/loop` is a Claude Code built-in. The `writing-for-agents` skill authors skills.
- pstack has no `/orchestrate` skill. Orchestrate is a `/pstack:poteto-mode` playbook. If the slash menu shows `/orchestrate`, another plugin provides it.

## Playbooks and principles

Playbooks are step lists inside `/pstack:poteto-mode`, not skills, so they have no slash command. Inside `/pstack:poteto-mode`, describing the task picks one, and these phrases name one directly:

- "babysit this pr" or "check on pr 123" runs Babysit. It drives the PR to merge-ready and stops there. It doesn't merge unless the user asks to merge, land, or ship.
- "land the stack" runs Shipping.
- "take over this branch" runs Session pickup.
- "pause safely" runs Pause safely.
- "full autopilot on this queue" runs Autopilot-full. "stack them, don't ship" runs Autopilot-stack.
- "run the eval playbook" runs Eval.

Without `/pstack:poteto-mode`, a phrase such as "babysit this pr" can start the `babysit-pr` skill for the same job instead. The Playbooks section of `poteto-mode` lists every playbook and when it applies. The Opening a PR, Babysit, and Shipping playbooks cover opening, babysitting, and landing a PR.

pstack has no planning skill. Claude Code's plan mode works alongside it. For work that spans phases or stacked PRs, asking `/pstack:poteto-mode` for a plan runs the Multi-phase plan playbook, which writes the plan and doesn't implement it. For a design question, the Prototype playbook or `/pstack:architect` settles it in code first.

Principles are one-rule files that `/pstack:poteto-mode` reads and cites in its replies. The user rarely opens one. They steer with the names instead, as in "apply prove it works. show me the real output." Asking the agent to read a principle by name loads it on demand. `${CLAUDE_PLUGIN_ROOT}/principles/` lists them.

## Fix a run that went wrong

| Symptom | Fix |
|---|---|
| The mode stopped applying | Start the task again with `/pstack:poteto-mode`, or start a new session with it. |
| A question got treated as the next step of the last task | Say "new task", or say the turn doesn't need the mode. |
| A new model choice had no effect | Skills read `models.md` when they spawn a subagent, so a subagent already running keeps its model. Check that the role name matches its row and the value is one `models.md` lists. |
| Runs cost more than expected | See the cost paragraph under Get set up. |
| A skill didn't load on its own | pstack skills never load on their own. They load when the user types them or when `/pstack:poteto-mode` runs them, and it doesn't run every skill. |
| Parallel agents overwrote each other | Spawn each agent with `isolation: "worktree"` so it gets its own checkout, or run them as remote sessions, which each get their own machine. |
| An overnight run moved but finished nothing | `/loop` needs a check that can pass or fail, not a duration. See the Autonomous run playbook. |
| The reply claims success from a green build | Ask for the real command, flow, stored value, or profile. That's the **prove-it-works** principle. |

For a run that drifts, [`references/prompting.md`](references/prompting.md) has one-line steers. [`references/recipes.md`](references/recipes.md) has the recipes worth copying.

## Make pstack my own

- `/pstack:automate-me` drafts a personal mode skill from the user's own history, to use alongside `/pstack:poteto-mode`.
- `/pstack:reflect` after a session turns its lessons into skill edits the user approves.
- `/pstack:poteto-mode write a skill for <workflow>` runs the authoring playbook. The eval playbook tests a skill change blind.
- Fix a misbehaving skill in its own PR, not inside the feature work where it went wrong.

## Reply

Lead with the answer. Give at most one example prompt in a code block, adapted from [`references/recipes.md`](references/recipes.md) when one fits, then the link to that file. Keep it short unless the user asked for the whole map.
