---
name: plan
description: Write the branch's plan.md from its spec, then stop for sign-off.
disable-model-invocation: true
---

# Plan

Read `.scratch/<branch>/spec.md` (or the spec path the user gives) and the code it
touches, then write `.scratch/<branch>/plan.md`. This is the read-only step: no code
changes, no commits. The plan is what implementation follows and what `deep-review`
checks the final diff against.

## Process

1. Read the spec. If there is none and the task is small, write the plan from the
   user's description and say so in the report. If the task is not small, stop and tell
   the user to run the `spec` skill first.
2. Read the code the spec touches. Open the actual files, callers, tests, and any
   migration or config the change reaches. Do not plan from file names.
3. Look for existing code that already does part of the job. Reuse beats new code. Name
   what you found and where it falls short.
4. Write the plan with the template below.
5. Run the risk pass: for each file in the change list, ask what breaks if this change
   is wrong and who else calls it. Anything with a real answer goes under Risks.
6. Report the path and the two or three decisions the user most needs to check. Stop.
   Do not start implementing. The user edits the plan, then runs `/clear` and says
   "implement .scratch/<branch>/plan.md".

## Template

```md
# Plan: <feature name>

Spec: .scratch/<branch>/spec.md

## Files that change
One line per file: path, then what changes in it. New files marked (new). Include
tests and migrations. Keep the list honest; deep-review flags anything outside it.

## Order of work
Numbered steps in the order they should land, each one a vertical slice that leaves
the tests green: test at the seam, then the code that passes it. Say which step
touches the riskiest file so it goes early.

## Reuse
Existing code this builds on, and what it needed to be changed or extracted.

## Risks
Each risk in one line: what could break, where, and how the plan avoids it. Rolling
deploy, data written before the change, and callers outside the diff belong here.

## Proof
What "done" looks like, as commands and artifacts: the test target and the tests that
must pass, the type check, and for UI work the screenshot or mock the result must match.
```

## Size

A plan for a medium feature fits on one screen. If yours does not, the spec is too big
for one branch; say so and propose the split.
