---
name: spec
description: Write the branch's spec.md from the current conversation. Short, no tracker, no interview.
disable-model-invocation: true
---

# Spec

Turn what has already been discussed into `.scratch/<branch>/spec.md`. Do not interview
the user; the `grilling` skill exists for that and should have run already if the idea
was not settled. Synthesize what you know.

`.scratch/` is ignored by the global gitignore. The spec lives only as long as the
branch. The permanent record is the PR description, which `file-pr` builds from it.

## Process

1. Confirm the branch. If on `main`, ask for a branch name and create it. Create
   `.scratch/<branch>/` if missing.
2. Read `CONTEXT.md` and any ADRs if the repo has them, so the spec uses the project's
   own vocabulary.
3. Name the seams the feature will be tested at. Prefer existing seams. Use the highest
   seam possible; the fewer seams the better, and one is ideal. If a new seam is needed,
   propose it at the highest point you can. List them in the spec and say in the report
   that the user should confirm them before planning.
4. Write the file using the template below. Keep it under a page. Every sentence should
   change what gets built; cut the ones that do not.
5. Report the path and the seams. Stop. The user reviews and edits the file, then starts
   a new session for the `plan` skill.

## Template

```md
# <feature name>

## Problem
What the user runs into today, from the user's point of view. Two to four sentences.

## Solution
What changes for the user. Two to four sentences. No implementation detail.

## Behavior
A short numbered list of observable behaviors, each one testable. Write them as
"When <situation>, <outcome>." Cover the main path and the failure paths that matter.
Skip the ones any competent implementation gets for free.

## Decisions
Implementation decisions already made in the conversation: modules touched, interface
changes, schema changes, API contracts. Prose or a short list. No file paths and no code,
except a snippet from a prototype that encodes a decision more precisely than prose.

## Test seams
Where the tests go and why. Name prior art in the repo for the kind of test.

## Out of scope
What this branch will not do, so review can flag scope creep.
```

## What not to write

- User stories in bulk. One behavior list is enough.
- Anything the repo's CLAUDE.md already says.
- Timelines, tickets, or task breakdowns. The plan skill owns the work order.
