---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR.
metadata:
  harness: [claude, codex]
  platform: [darwin, linux]
  scope: fleet
---

# File PR

Before anything else, read the `Reviewed:` line in `.scratch/<branch>/review.md`, the ledger `deep-review` leaves. If the file is missing or its SHA is not `HEAD`, run `deep-review` first and file only once it reports the branch ready. Then check whether a PR for this branch already exists, and rebase onto latest `origin/main`; stale branches conflict and waste a review round.

PR titles usually become commit messages, so follow the repository's title conventions. Look at recently merged PRs and Git history for examples. Prefer a concise human readable title that explains why the change matters.

BAD
> perf(server): negotiate permessage-deflate on the websocket

GOOD
> perf(server): cut websocket frame size by 70%+ with gzipping

Open the description with a simple explanation of the problem, then briefly explain the solution. If `.scratch/<branch>/spec.md` exists, build both from its Problem and Solution sections; the spec is gitignored, so the PR body is its permanent record. Otherwise use the user's original prompt. Lead with the problem, not an implementation inventory:

BAD
> Removed implicit workspace carry-over from every "new thread" entry point (cmd+n / cmd+shift+o, sidebar v1/v2 buttons, command palette). New threads inherit only the project from context; branch, worktree, and env mode always come from the configured defaults. Deleted buildContextualThreadOptions, startNewThreadInProjectFromContext, and the v1 sidebar's seed-context machinery.

GOOD
> My "new worktree" default was ignored when starting new threads on existing worktrees. Super unintuitive. Now your preferences always apply.

When the diff changes what a user sees, close the description with a `## Screenshots` section that shows the result. Take after shots only, unless the user asked for a before. Use the PNGs the repo's `verify-*` skill left for `HEAD` in its evidence folder; if there are none, run that skill first. Pick the few that show the change, on desktop, and on mobile where the layout differs. Reference each by its path in the body, `![Register page with the new filter](.scratch/verify/runs/<run>/03-filter.png)`, and pass the same path to `gh pr create --attach`. gh uploads the file and rewrites the reference to the uploaded URL, so no image is committed. If an upload fails, gh still creates the PR and exits non-zero; run `gh pr edit --body-file <body> --attach <path>` with the same body and paths. In a repo with no way to drive the UI, write one line saying no screenshots were taken.

Open a real PR rather than a draft; drafts do not get review-bot coverage. If the user also asked to babysit it, continue with the `babysit-pr` skill.

The description ends with its own content: no model or harness blurb, session link, or co-author line.
