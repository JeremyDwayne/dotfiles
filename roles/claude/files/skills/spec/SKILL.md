---
name: spec
description: Write the branch's spec.md from the current conversation. Decides what it can, asks one round of questions about the rest.
disable-model-invocation: true
---

# Spec

Turn what has been discussed into `.scratch/<branch>/spec.md`. Decide everything you
can and ask only about the rest. The user reviews the spec before planning, so a default
written down is as easy to override as a question, and costs them less.

`.scratch/` is ignored by the global gitignore. The spec lives only as long as the
branch. The permanent record is the PR description, which `file-pr` builds from it.

## Process

1. Confirm the branch. If on `main`, ask for a branch name and create it. Create
   `.scratch/<branch>/` if missing.
2. Read `CONTEXT.md` and any ADRs if the repo has them, so the spec uses the project's
   own vocabulary. Read the code the feature touches.
3. List every open decision, then sort each one:
   - A fact about the code, data, or tools. Look it up. Never ask.
   - A question that running or sketching something would answer: behavior, layout,
     timing, output. Try it, or decide and name it in Behavior so the plan proves it.
   - Cheap to reverse, and you have a recommendation you would defend. Decide it and
     mark it `(default)` under Decisions.
   - A product or preference call you cannot make with confidence, or one that is
     expensive to reverse: schema, public API, data written for users. Ask.
4. Ask the remaining questions in one round, numbered, each with your recommendation.
   Skip the round if nothing is left. Ask a second round only when an answer opened a
   new expensive-to-reverse fork.
5. Name the seams the feature will be tested at. Prefer existing seams. Use the highest
   seam possible; the fewer seams the better, and one is ideal. If a new seam is needed,
   propose it at the highest point you can.
6. Write the file using the template below. Keep it under a page. Every sentence should
   change what gets built; cut the ones that do not.
7. Report the path, the seams, and the two or three defaults the user is most likely to
   override. Stop. The user reviews and edits the file, then starts a new session for
   the `plan` skill.

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
Implementation decisions: modules touched, interface changes, schema changes, API
contracts. Mark the ones you made without asking `(default)`. No file paths and no code,
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
