---
name: deep-review
description: Review a branch, pull request, or diff the way a senior engineer who knows the whole repository would, then fix what the review confirms. Traces every changed symbol to its callers, data flow, tests and git history, checks the diff against the branch's plan and spec, and implements confirmed fixes in their own commits. Use whenever the user asks for a code review, PR review, "look over this diff", "what did I miss", "review before I merge", or "review this branch", even for a quick look. Also use for a second opinion after another reviewer already commented. Do not use for writing new code with no review intent.
---

# Deep review

The bugs that survive a normal review are almost never visible in the diff. They live in
the code the diff touches indirectly: the caller three files away that assumed the old
return type, the migration that runs after the model change deploys, the background job
that still calls the deleted method, the second code path that was supposed to get the same
fix. A diff-only reader cannot see any of that. This skill forces the investigation that
finds it, then fixes what it confirms, so the branch leaves review ready to ship.

Three rules govern everything below:

1. **Never report a finding you have not verified in the code.** Open the file, read the
   caller, run the test. A plausible guess that turns out wrong costs more credibility
   than a real bug found. Confirm it or drop it; do not hedge it into the report.
2. **Notable findings only.** Style nits, formatting, and things a linter would catch do
   not belong unless the user asked for them. A finding is something that would change
   the author's decision to merge.
3. **Fix what you confirm.** The review is not done when the list is written. BLOCKER and
   MAJOR findings get fixed on the branch, each in its own commit. MINOR findings get
   fixed when the fix is local and obvious, otherwise reported. Anything you cannot fix
   safely is reported with the reason.

## Workflow

### 1. Establish scope and intent

Get the diff and the intent side by side. For a GitHub PR use `gh pr view <n>` and
`gh pr diff <n>`; for a branch use `git diff <base>...HEAD`; for a pasted diff, use it as
given and say plainly that you could not trace beyond it. Read the PR title, description,
linked issues and existing review comments. Read the branch's commit messages
(`git log <base>..HEAD --oneline`).

Look for the branch's working artifacts in `.scratch/<branch>/`: `spec.md` and
`plan.md`. If they exist, they are the claim the code is measured against. If they do
not, write down in one or two sentences what the change claims to do from the PR
description and commits. Every later step compares the code against that claim.

If the repo has a `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `REVIEW.md`, lint
config, or a docs folder describing conventions, read the relevant parts. Reviewers who
know the house rules find violations that generic reviewers cannot.

### 2. Build the change map

Run `scripts/change_map.py <base-ref>` from the repo root (or feed it a diff file with
`--diff`). It lists every changed file, every added, removed, or modified identifier it
can extract, and for each identifier every place in the repo that references it, with
file and line. That output is your investigation queue, not your review.

If the script cannot parse something (unusual language, generated files), do the same
work by hand with `git diff -U0` and `rg`. Do not skip identifiers because the list is
long. The length of the list is a signal about blast radius and belongs in the summary.

### 3. Trace every changed symbol

For each changed function, method, class, constant, schema field, route, config key,
environment variable, or query, do all of the following. This step produces the findings
that matter, and it is the step that gets skipped under time pressure. Do not skip it.

- **Callers.** Open every reference the change map found. Does this caller still get
  what it expects? Changed signature, return shape, nullability, exceptions, side
  effects, ordering. Callers include tests, background jobs, scripts, templates,
  serializers, and other services in the repo.
- **Callees.** What does the new code call, and does it use those callees correctly?
  Read the callee's definition, not its name. Names lie about nullability, laziness,
  and error behavior.
- **Siblings.** Search for the pattern the change fixes or introduces elsewhere. If the
  PR fixes a bug in one place, is the same bug in three other places copied from it? If
  it adds a check on one entry point, do the other entry points need it?
- **Data flow.** Follow each new or changed input from where it enters (params, API
  payload, file, env, DB) to where it is used. At each hop: validated? sanitized?
  authorized? Could it be nil, empty, huge, negative, non-ASCII, or attacker-controlled?
- **State and persistence.** Migrations, schema changes, cache keys, serialized formats,
  queue payloads, feature flags. What happens to data written before this change? What
  happens during a rolling deploy when old and new code run at once?
- **History.** `git log -p --follow` on the changed lines and `git blame` on anything the
  PR deletes or reverses. If a line was added in a commit titled "fix race condition"
  and this PR removes it, that is a finding until proven otherwise.
- **Tests.** Which tests cover the changed behavior? Read them. Do they exercise the new
  branch, or the old happy path with new names? If the PR claims a fix, is there a test
  that would have failed before? A missing test for a non-trivial behavior change is a
  finding.

Keep working notes (a scratch file is fine): symbol, what you checked, what you found.

### 4. Check plan and spec compliance

With `.scratch/<branch>/plan.md` and `spec.md` open, answer each of these and record any
mismatch as a finding:

- **Missing.** Which items in the spec's solution or the plan's file list are not in the
  diff? Partial implementations count.
- **Unasked.** What does the diff change that neither document asked for? Scope creep is
  a finding unless it is a bounded refactor the branch commits label as such.
- **Wrong.** Which requirements look implemented but do not match the spec's wording?
  Quote the spec line next to the code.
- **Proof.** The plan names its proof (tests, screenshots, commands). Was each one
  produced? Run the ones you can.

Without a plan or spec, compare against the claim you wrote in step 1 and say in the
report that the compliance pass ran against the PR description only.

### 5. Run the adversarial checklist

Read `references/bug-classes.md` and walk it against the change. It groups concrete
failure modes by category (correctness, concurrency, security, data, performance, API
contract, error handling, operability). For each category, spend real effort trying to
break the change, not confirming it looks fine.

Then read the stack file that matches the repo: `references/django-stack.md` for
Django, DRF, Celery, and Stripe-in-Django; `references/rails-stack.md` for Rails,
Hotwire, Solid Queue, and Stripe-in-Rails. If the repo is neither, skip both. If it uses
Stripe with any framework, read the Stripe section of whichever file is closer.

### 6. Execute what you can

- Run the test suite, or at least the tests touching changed files, and report the
  actual result. Do not say "tests should pass".
- Run the type checker, linter, and any static analysis the repo already uses.
- If a finding depends on a runtime claim (raises on nil, N+1 query, regex backtracks),
  reproduce it in a console, scratch script, or targeted test before reporting it.
- If you cannot run anything (no environment, pasted diff), say so and mark
  runtime-dependent findings as unverified.

### 7. Triage

Before fixing anything, filter every candidate:

- **Confirmed?** You have a file:line and a concrete reason, or you ran it. Otherwise
  confirm it now or drop it.
- **Notable?** Would a competent author want to know this before merging?
- **Not already handled?** Check existing PR comments, follow-up commits, and code
  elsewhere.
- **Severity honest?** Do not inflate to seem thorough or deflate to seem polite.

Then ask, in the voice of the most experienced engineer on this repo: "What will
actually break in production from this change?" If your list does not contain the
answer, go back to step 3 for the symbols with the widest blast radius.

### 8. Fix

Work the confirmed list from highest severity down. For each finding you fix:

- Make the smallest change that resolves it. Do not redesign around it.
- Add or adjust the test that would have caught it, at the seam the spec named.
- Commit it alone, with a message that names the finding: `fix: guard nil company on
  revision export (review)`.
- Re-run the tests and type check after each fix, and again once at the end.

Do not fix a finding when the fix needs a decision the author has not made, when it
touches files outside the branch's scope, or when it would change the spec. Report those
with the reason and a suggested fix instead.

If the branch has a PR, push the fix commits so the bots re-run.

### 9. Write the report

Prose inside sections; no bullets in the summary.

```
## Summary
Two to four sentences: what the change does, whether it does what the plan and spec
claim, and the single most important thing the author should look at. State whether
the branch is ready to merge now that fixes are in, and why.

## Fixed
One entry per fix. Severity, short title, where, what was wrong, the commit that fixes
it, and the test that now covers it.

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
Missing, unasked, and wrong items, or "matches" if the diff does what both documents
asked. Say which proof items from the plan were produced.

## Verified
What you ran and the results. What you could not run and why.

## Not covered
Anything skipped or untraceable, so the author knows the review's boundary.
```

Severity levels:

- **BLOCKER**: incorrect behavior, data loss, security exposure, or an outage in a
  realistic path. Fixed before merge, no exceptions.
- **MAJOR**: a real defect, a missing safeguard with a plausible trigger, or a
  claim mismatch. Fixed before merge.
- **MINOR**: correct today but fragile, misleading, or a trap for the next change. Fixed
  when local, otherwise reported.
- **NOTE**: worth knowing, no action. Use sparingly.

Do not pad. A review that fixed two BLOCKERs and has nothing open is a good review. A
review with zero findings after a full trace is also a good review; say so plainly, and
the Verified section carries the weight.

## Lessons

If a finding is one you have seen before on this repo (same class of mistake, second
occurrence), propose a one-line addition to the repo's `CLAUDE.md` or `AGENTS.md` in the
report. Do not add it yourself unless the user says to.

## When the user pushes back

If the author disagrees with a finding, re-open the code and re-check rather than
defending from memory. If they are right, say so, withdraw it, and revert the fix commit
if one was made. If they are wrong, point at the specific line that shows it. If it is a
judgment call, say so and give your reasoning once.
