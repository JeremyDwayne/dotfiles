# Custom Claude skills

Drop your own skill folders here — one directory per skill, each containing a
`SKILL.md` (plus any supporting files). The `claude` role symlinks every
top-level folder in here into `~/.claude/skills/<folder-name>`, so anything you
add is picked up on the next `dotfiles` run.

Only put skills *you wrote* here. Third-party skill packs (e.g.
`mattpocock/skills`) are installed and kept up to date separately by the role
via the `skills` CLI, so they don't belong in this repo.
