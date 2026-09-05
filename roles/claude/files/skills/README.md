# Custom Claude skills

Drop your own skill folders here, one directory per skill, each containing a
`SKILL.md` (plus any supporting files). The `claude` role symlinks every
top-level folder in here into `~/.claude/skills/<folder-name>`, so anything you
add is picked up on the next `dotfiles` run.

Only put skills *you wrote* here. Third-party skill packs (e.g.
`mattpocock/skills`) are installed and kept up to date separately by the role
via the `skills` CLI, so they don't belong in this repo.

## The engineering loop

Stage by stage, with the skill that runs it and the file it leaves behind:

| Stage | Skill | Output |
|---|---|---|
| Spec | `grilling` (Matt Pocock), then `/spec` | `.scratch/<branch>/spec.md` |
| Plan | `/plan` | `.scratch/<branch>/plan.md` |
| Implement | `tdd` (Matt Pocock), Artifact tool for mocks | commits on the branch |
| Ship | `deep-review`, `/file-pr`, `/babysit-pr` | fix commits, PR |

`.scratch/` is in the global gitignore (see the git role). Hooks live in `../hooks/`
and a `REVIEW.md` template for CI review lives in `../templates/`.
