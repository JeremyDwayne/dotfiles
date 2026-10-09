---
name: deep-review
description: Review a branch, PR, or diff by tracing every changed symbol to its callers, tests, and history, then fix confirmed findings in their own commits. Use for any code review request, including a quick look or a second opinion.
---

# Deep review

The bugs that survive a normal review are not in the diff. They are in the caller three
files away that assumed the old return type, the job that still calls the deleted method,
the second code path that needed the same fix. This skill traces the blast radius, then
fixes what it confirms, so the branch leaves review ready to ship.

Three rules:

1. **Verify every finding in the code.** Open the file, read the caller, run the test.
   A wrong guess costs more credibility than a real bug found. Confirm it or drop it.
2. **Notable findings only.** A finding is something that would change the author's
   decision to merge. Style and lint output stay out unless the user asked.
3. **Fix what you confirm.** BLOCKER and MAJOR findings get fixed on the branch, each in
   its own commit. MINOR findings get fixed when the fix is local and obvious. Anything
   you cannot fix safely is reported with the reason.

## Workflow

### 1. Establish scope and intent

Get the diff and the intent side by side. For a GitHub PR use `gh pr view <n>` and
`gh pr diff <n>`; for a branch use `git diff <base>...HEAD`; for a pasted diff, use it as
given and say plainly that you could not trace beyond it. Read the PR description, linked
issues, existing review comments, and `git log <base>..HEAD --oneline`.

Look for `.scratch/<branch>/spec.md` and `plan.md`. If they exist, they are the claim the
code is measured against. If not, write the claim in one or two sentences from the PR
description and commits. Every later step compares the code against that claim.

Read the repo's `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `REVIEW.md`, and lint config
where they exist. Reviewers who know the house rules find violations generic reviewers miss.

Size the review. A small diff is under about 150 changed lines with no migration, schema,
public API, auth, or config change. For a small diff, skip steps 2 and 5: find references
with `rg` and trace only the symbols whose signature or behavior changed. Everything else
gets the full workflow. Name the size you picked in the summary.

### 2. Build the change map

Run `scripts/change_map.py <base-ref>` from the repo root (or `--diff <file>` for a diff
file). It lists every changed file, every added, removed, or modified identifier, and every
place in the repo that references each one. That output is your investigation queue.

Where the script cannot parse something, do the same work by hand with `git diff -U0` and
`rg`. Work the whole list. Its length is a signal about blast radius and belongs in the
summary.

### 3. Trace every changed symbol

For each changed function, class, constant, schema field, route, config key, env var, or
query, check all of the following. This step produces the findings that matter.

- **Callers.** Open every reference the change map found. Does each caller still get what
  it expects? Signature, return shape, nullability, exceptions, side effects, ordering.
  Callers include tests, jobs, scripts, templates, serializers, and other services.
- **Callees.** Read the definition of what the new code calls, not its name. Names lie
  about nullability, laziness, and error behavior.
- **Siblings.** Search for the pattern the change fixes or introduces elsewhere. A bug
  fixed in one place is often copied in three others.
- **Data flow.** Follow each changed input from where it enters (params, payload, file,
  env, DB) to where it is used. At each hop: validated, sanitized, authorized? Could it be
  nil, empty, huge, negative, non-ASCII, or attacker-controlled?
- **State and persistence.** Migrations, cache keys, serialized formats, queue payloads,
  feature flags. What happens to data written before this change, and during a rolling
  deploy when old and new code run at once?
- **History.** `git log -p --follow` on the changed lines and `git blame` on anything the
  PR deletes. A removed line from a commit titled "fix race condition" is a finding until
  proven otherwise.
- **Tests.** Read the tests covering the changed behavior. Do they exercise the new branch
  or the old happy path with new names? A claimed fix needs a test that would have failed
  before. A missing test for a non-trivial behavior change is a finding.

Keep working notes: symbol, what you checked, what you found.

### 4. Check plan and spec compliance

With the plan and spec open, record each mismatch as a finding:

- **Missing.** Spec solution items or plan file-list entries absent from the diff.
  Partial implementations count.
- **Unasked.** Changes neither document asked for. Scope creep is a finding unless it is a
  bounded refactor the branch commits label as such.
- **Wrong.** Requirements that look implemented but do not match the spec's wording.
  Quote the spec line next to the code.
- **Proof.** Each proof the plan names (tests, screenshots, commands). Run the ones you can.
- **Feature map.** If the repo has a `.claude/skills/verify-*` skill, a change to how a
  user reaches or sees a feature needs its feature file updated in the diff. A stale or
  missing feature file is a MINOR finding; fix it.

Without a plan or spec, compare against the claim from step 1 and say so in the report.

### 5. Run the adversarial checklist

Read `references/bug-classes.md` and walk it against the change. For each category, try
to break the change rather than confirm it looks fine.

Then read every stack file the changed files match: `references/django-stack.md`,
`references/rails-stack.md`, `references/typescript-react-stack.md`. A Django API with a
React frontend reads both. If the repo uses Stripe with any framework, read the Stripe
section of whichever file is closer.

### 6. Execute what you can

- Run the tests touching changed files, the type checker, and the linter. Report the
  actual result.
- If the repo has a `.claude/skills/verify-*` skill and the change is user-facing, drive
  each changed feature through it and report the evidence path. A failed drive is a
  finding.
- Reproduce any runtime claim (raises on nil, N+1 query, regex backtracks) in a console,
  scratch script, or targeted test before reporting it.
- If you cannot run anything, say so and mark runtime-dependent findings as unverified.

### 7. Triage

Filter every candidate before fixing:

- **Confirmed?** You have a file:line and a concrete reason, or you ran it.
- **Notable?** Would a competent author want to know before merging?
- **Already handled?** Check existing PR comments, follow-up commits, and code elsewhere.
- **Severity honest?** Neither inflated to seem thorough nor deflated to seem polite.

Then ask, as the most experienced engineer on this repo: what will actually break in
production from this change? If the list lacks the answer, return to step 3 for the
symbols with the widest blast radius.

### 8. Fix

Work the confirmed list from highest severity down. For each fix:

- Make the smallest change that resolves it.
- Add or adjust the test that would have caught it, at the seam the spec named.
- Commit it alone, with a message naming the finding: `fix: guard nil company on
  revision export (review)`.
- Re-run the tests and type check after each fix, and again at the end.

Report instead of fixing when the fix needs a decision the author has not made, touches
files outside the branch's scope, or would change the spec. Include a suggested fix.

If the branch has a PR, push the fix commits so the bots re-run.

### 9. Write the report

Prose inside sections. No bullets in the summary.

```
## Summary
Two to four sentences: what the change does, whether it does what the plan and spec
claim, the single most important thing to look at, and whether the branch is ready to
merge now that fixes are in.

## Fixed
One entry per fix: severity, short title, where, what was wrong, the commit, and the
test that now covers it.

## Open findings
One entry per unfixed finding, highest severity first:

### [SEVERITY] Short title
**Where:** path/to/file.py:123
**What:** One or two sentences describing the defect concretely.
**Why it matters:** The consequence, with evidence: the caller that breaks (path:line),
the test that fails, the command you ran and its output.
**Why not fixed:** The decision the author needs to make, or the scope reason.
**Suggested fix:** Concrete. A diff snippet if short.

## Plan and spec
Missing, unasked, and wrong items, or "matches". Which proof items were produced.

## Verified
What you ran and the results. What you could not run and why.

## Not covered
Anything skipped or untraceable, so the author knows the review's boundary.
```

Severity levels:

- **BLOCKER**: incorrect behavior, data loss, security exposure, or an outage in a
  realistic path. Fixed before merge, no exceptions.
- **MAJOR**: a real defect, a missing safeguard with a plausible trigger, or a claim
  mismatch. Fixed before merge.
- **MINOR**: correct today but fragile, misleading, or a trap for the next change. Fixed
  when local, otherwise reported.
- **NOTE**: worth knowing, no action. Use sparingly.

A review with zero findings after a full trace is a good review. Say so plainly; the
Verified section carries the weight.

## When the user pushes back

Re-open the code and re-check rather than defending from memory. If they are right,
withdraw the finding and revert its fix commit. If they are wrong, point at the specific
line that shows it. If it is a judgment call, say so and give your reasoning once.
