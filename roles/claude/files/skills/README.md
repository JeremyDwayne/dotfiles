# Custom Claude skills

Drop your own skill folders here, one directory per skill, each containing a
`SKILL.md` (plus any supporting files). The `claude` role symlinks every
top-level folder in here into `~/.claude/skills/<folder-name>`, so anything you
add is picked up on the next `dotfiles` run.

Only put skills *you wrote* here. Third-party skill packs (e.g.
`mattpocock/skills`) are installed and kept up to date separately by the role
via the `skills` CLI, so they don't belong in this repo.

The desktop app's chat and Cowork modes don't read `~/.claude/skills`. They get these
skills from the `dotfiles` plugin in this repo's marketplace: in Customize > Plugins, add
the marketplace `JeremyDwayne/dotfiles`, install `dotfiles`, and turn on automatic sync.
It reads the default branch on GitHub, so a skill change reaches the app after it's pushed
to `main`. The desktop Code tab and the CLI use the symlinks, so don't install the plugin
there or every skill appears twice.

## The engineering loop

Stage by stage, with the skill that runs it and the file it leaves behind:

| Stage | Skill | Output |
|---|---|---|
| Spec | `/spec` (`grilling` from Matt Pocock only on request) | `.scratch/<branch>/spec.md` |
| Plan | `/plan` | `.scratch/<branch>/plan.md` |
| Implement | `tdd` (Matt Pocock), Artifact tool for mocks | commits on the branch |
| Verify | the repo's `verify-<app>` skill, where one exists | `.scratch/<branch>/verify-<app>/` |
| Review | `deep-review` | local fix commits, `.scratch/<branch>/review.md` |
| Ship | `/file-pr`, `/babysit-pr` | PR |

Review runs locally before anything is pushed. Its ledger records the reviewed SHA and
each finding's status, so a re-run skips dismissed findings and `/file-pr` can tell
whether `HEAD` was reviewed. Verification runs during implement and again in `deep-review`. A branch that changes a
user path updates that feature's file in the verify skill's `features/` in the same commit.

`.scratch/` is in the global gitignore (see the git role). Hooks live in `../hooks/`
and a `REVIEW.md` template for CI review lives in `../templates/`.
