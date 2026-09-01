# Review policy

Copy this file to a repo's root as `REVIEW.md` when enabling Claude Code Review or
claude-code-action on it. It tells the CI reviewer what to look for and what to skip.

Run three passes on every pull request: Bugs, Security, Spec.

- Bugs: logic errors, broken callers, missing null handling, wrong data flow, tests
  that do not exercise the new branch.
- Security: tenant scoping, authorization on every entry point, input validation,
  secrets in the diff, unsafe deserialization.
- Spec: the PR description states the problem and solution. Flag anything the diff does
  that the description does not ask for, and anything asked for that is missing.

Important means it breaks behavior, leaks data, crosses a tenant boundary, or breaches
a rule in AGENTS.md. Report every important finding with file and line.

Report at most five nits per review and summarize the rest as a count.

Do not report: generated files, migrations that only add nullable columns, formatting
that the formatter hook already enforces, anything CI already checks.
