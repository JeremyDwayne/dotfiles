# Global preferences (all projects)

Personal defaults that apply across every repo. Each project's own CLAUDE.md owns its
stack-specific commands and standards and wins on any conflict.

These rules encode a working discipline, not suggestions. Follow them regardless of
which model is running — when in doubt, take the slower path that includes the
verification step.

## Judgment and autonomy

- Never edit code you haven't read. Before changing anything, read the file and the
  code that calls it, and match the existing pattern unless you have a stated reason
  not to.
- For bugs: reproduce first, diagnose until you can explain *why* it happens, then fix
  the root cause. If you can't reproduce it, report that instead of fixing blind.
- Before any multi-step task, write a short plan: the steps, the files you'll touch,
  and how you'll verify the result. For design choices with several defensible
  options, name the alternatives and why you picked yours — one recommendation with
  reasons, never an options menu with no opinion.
- When you have enough information to act, act. Stop to ask only for destructive or
  hard-to-reverse actions, or genuine scope decisions that are mine to make — not for
  permission to do what I already asked for.
- When I describe a problem or ask a question, the deliverable is your assessment.
  Don't apply a fix until I ask for one.
- Never end a turn on a promise ("I'll now…", "next I would…"). Either do the work or
  state exactly what blocks you.

## Feature flow

Every feature follows the same five skills, in this order — one flow, every time,
in every repo. Each is a slash command; drive the flow yourself, invoking each in
turn as the work is ready for it — you don't need me to type them. Still stop at the
flow's own decision gates (design approval, review findings that need my judgement).

1. **Design** — `/grill-with-docs` for a bounded design: a relentless interview
   that sharpens the plan and lays down ADRs + glossary as it goes. Use
   `/wayfinder` instead when the work is too big for one agent session and the
   route to the destination is still foggy — it charts a shared map of
   investigation tickets and resolves them one at a time until the way is clear.
2. **Spec** — `/to-spec` synthesizes the conversation so far into a spec and
   publishes it to the project tracker with the `ready-for-agent` label. No fresh
   interview — it captures what we already decided.
3. **Tickets** — `/to-tickets` breaks the spec into tracer-bullet vertical slices,
   each declaring its blocking edges, published to the tracker. Independently
   implementable, single-context-sized pieces, never one mega PR.
4. **Implement** — `/implement` builds the spec/tickets, using `/tdd` at the
   pre-agreed seams, typechecking and running single test files as it goes and the
   full suite at the end, then runs `/code-review` and commits. Run each ticket's
   `/implement` in its own git worktree so several agents can build in parallel
   without disturbing each other or the main checkout — one worktree per
   independent ticket, branched off the tracker's blocking edges.
5. **Review** — `/code-review` gives a two-axis read of the diff (Standards + Spec)
   in parallel sub-agents. `/implement` invokes it. Fix anything benign you find automatically, ask me for anything that requires closer judgement.

## Coding

- Make the smallest change that solves the problem properly. No drive-by refactors or
  style fixes outside the task unless I ask.
- Match the surrounding code: naming, idiom, formatting, comment density.
- Comments state constraints the code can't express — never narrate what changed or
  argue that the change is correct.
- Give public/exported functions and modules a docstring (or JSDoc); skip trivial
  private helpers.
- Edit files one at a time. Don't bulk-edit with sed/awk or scripted find-and-replace.

## Tests

- Write tests for new features and bugfixes unless I say otherwise; cover the happy
  path and the edge cases.
- For a bugfix, write the failing test first and watch it fail — a test that never
  failed proves nothing about the fix.
- All tests must pass before committing — including after a refactor.
- Never change a test just to make it pass. Fix the code under test; only edit a test
  when I explicitly ask.

## Verification before claiming done

- "Done", "fixed", and "passing" are claims that require evidence. Run the check and
  read its output before saying any of them. If verification failed or was skipped,
  report that plainly instead — never soften a failure.
- Run the checks the project actually defines — its test command, plus lint/type-check
  only if the repo configures them (check package.json scripts, Makefile,
  pyproject.toml, etc.). Don't invent commands a project doesn't have.
- Tests alone aren't proof for a change with a runtime surface: exercise the affected
  code path at least once (run the CLI, hit the endpoint, drive the flow).

## Self-review

- Before presenting or committing, reread the complete diff as a skeptical reviewer:
  hunt for the input or state that breaks it, leftover debug code, and changed files
  that shouldn't be in the diff.
- When I give review feedback, verify it's technically right before implementing. If
  it's wrong, push back with evidence. Never implement feedback you believe is
  incorrect just to agree with me.

## Communication

- Lead with the outcome. The first sentence of any report answers "what happened" or
  "what did you find"; supporting detail comes after.
- Write complete sentences in plain terms. No invented shorthand, codenames, or
  arrow-chain fragments (`A → B → fails`).
- Match the response to the question: a simple question gets a direct prose answer,
  not headers and sections.
- Everything I need from a turn must be in its final message — never buried in
  mid-turn status notes.
- Anything I must read and react to (a design, findings, options) must END its turn —
  text emitted before a tool call in the same turn (including AskUserQuestion) is not
  shown to me. Ask structured questions in a turn of their own, with all needed
  context inside the question and options text.

## Instruction files

- When editing any CLAUDE.md (this file or a project's): keep it lean, no redundancy
  or platitudes, only high-signal facts that would cause a mistake if removed; hard
  "must happen every time" gates belong in hooks, not prose.
- This file stays stack-agnostic: my ~50 repos are mostly Next/TS (~30), Ruby (~12),
  and Go (~10). Stack-specific commands and conventions live in project files.

## Delegating to agents

- Delegate broad searches and multi-file reconnaissance to subagents and keep only the
  conclusion; look up single known targets yourself.
- Launch independent subtasks as parallel agents in one batch.
- On a top-tier model, orchestrate: hand mechanical or heavy-lifting work to subagents
  on cheaper models (sonnet/haiku) and spend the main context on judgment and
  integration.
- Once work is delegated, don't also do it yourself — wait for the result.

## Workspace isolation

- Assume other Claude sessions may be working in this repo at the same time.
  Before touching code for any feature or bugfix, use the `EnterWorktree` tool to
  create a dedicated worktree and **switch this session into it** — then work and
  commit only there, never in the shared main checkout. Entering (not just
  `git worktree add`) moves the session's cwd into the worktree, so the statusline,
  memory, and every relative path reflect the branch you're actually on. It branches
  off an up-to-date `origin/<default>` by default. Call `ExitWorktree` only when I ask
  (or accept the keep/remove prompt at session end).
- Skip the worktree only for changes that intentionally land on the main checkout —
  small docs/spec/plan edits I've said can go straight to main, or one-off inspection
  with no code edits.

## Git

- Stage with `git add -A`, after a quick `git status` to confirm nothing unintended is
  included.
- You may commit once a unit of work is complete AND verified (tests pass) — but never
  commit a half-reviewed change or a mid-revision iteration.
- Squash fix-ups: a logical change is one clean commit. If you already committed and I
  ask for changes, amend it (while it's unpushed) rather than stacking "fix" commits.

## UI changes

- Before presenting or committing any change to templates/views, CSS, or frontend JS,
  use the verifying-ui-changes skill: screenshot the affected pages at desktop and
  mobile widths and actually look at them. Passing tests don't count as looking.
- In-app copy for AI-backed features never says "AI" (or names a model/vendor):
  describe the help and its source ("Generate from datasheet"), not the mechanism —
  users should see the value, not magic. We disclose AI, we just don't lead with it:
  marketing and legal pages may name it. Applies to any string a user can see,
  including stored errors that surface in tooltips.

## Business copy

- Any user-facing business copy — landing/marketing pages, lifecycle or
  sales emails, onboarding, pricing, sales collateral — follows the
  business-copy skill (`~/.claude/skills/business-copy/SKILL.md`). Invoke
  it before writing or reviewing such copy.

## Running things

- Assume the dev server is already running. If one is needed and isn't up, ask me to
  start it — don't launch it yourself.
- Env vars are loaded from `.env` by the framework, not exported to the shell. When a
  command needs one, source `.env` or pass it inline for that command. Never paste
  secret values into files or committed code.

## graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) — any input to knowledge graph.
  Trigger: `/graphify`. When I type `/graphify`, or a tool wants to explore the
  codebase, use the installed graphify skill or instructions before doing anything
  else.
