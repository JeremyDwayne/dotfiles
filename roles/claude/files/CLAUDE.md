# Global preferences (all projects)

Personal defaults for every repo. A project's own CLAUDE.md / AGENTS.md wins on stack-specific commands.

## Orchestrating

Use subagents only for parallel, independent workstreams. Keep orchestrator on session model; delegate by size — small→haiku/light, default→sonnet/medium, hard→opus/heavy — escalate when verification fails. ≤3 subagents unless clearly beneficial; each owns non-overlapping files and returns a short summary. Subagents never run the full suite; name their test files, full suite belongs to orchestrator/CI. Always start a todo list for multi-step plans.

Harness note: Muse Code delegates on Muse Spark routing internally — don't apply Claude's `haiku/sonnet/opus/fable` ladder to it (Muse Spark picks by task; never force `fable`). Claude Code uses that ladder (never `fable` unless you ask). Codex uses its own.

## Long runs

Orchestrator coordinates; agents do reading, implementation, tests. Never pull large diffs/logs into orchestrator — ask for the fact. Return compact summaries (`schema` on workflow `agent()` calls). One subagent per ticket, many fresh sessions over one marathon window. Persist progress outside conversation (commits/handoff).

## Coding

- Bugs: reproduce first, explain why, then fix root. If not reproducible, report.
- Smallest change that solves it; one file at a time, no sed/awk mass edits.
- Zero comments by default; comment only a non-obvious constraint/workaround/why.
- Never query in a loop — batch with `IN/JOIN/GROUP BY`.

## Performance

Performance is correctness: fix N+1, blocking on async loops, and unindexed hot filters in-footprint or flag explicitly. Keep responses proportional to what changed; lazy-load hidden content; background queues for expensive work; add the index with the query.

## Tests & verification

- Tests: happy path + realistic edges, extend existing file, never re-test framework, never edit a test to pass.
- All tests pass before commit.
- Run the project's actual gate (e.g. `just django-test`); don't invent checks. Exercise runtime surface once (CLI/endpoint) when tests alone aren't proof. Push back on wrong review feedback with evidence.

## Git & UI

- `git add -A` after `git status`; one clean commit per logical change (amend unpushed fix).
- In-app AI copy never says "AI"; keep designs legible for red-green deficiency.
- Business copy → `business-copy` skill; never use em dashes — use comma/period/colon/parentheses.

## Running things

Reuse a running dev server; env via framework from `.env`, never paste secrets. Instruction files stay lean — high-signal facts only; hard gates belong in hooks, not prose. Stack-specific commands live in project `AGENTS.md`/`CLAUDE.md`.
