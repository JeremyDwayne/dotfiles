# Git config

The git role sets global git settings and aliases, SSH commit signing, and copies the commit message template, global ignore, and allowed signers files into `~/.config/git/`.

## Sub-features

- `git-files` copies `gitmessage`, `ignore`, and `allowed_signers` into `~/.config/git/`.
- `git-identity` sets `user.name` and the vault-decrypted `user.email`.
- `git-settings` sets merge, fetch, pull, push, and rebase defaults.
- `git-signing` sets `gpg.format ssh`, `user.signingkey`, `commit.gpgsign`, and `tag.gpgsign`.
- `git-aliases` sets the `alias.*` entries.

## How to get to it (user POV)

- Run `dotfiles -t git`.

## Driving it with verify.sh

Preconditions:

- `verify.sh doctor` reports `ok   vault secret present`.

- **Check.** Run `$V check git`. Every `Set global config` and `Set Git Aliases` item reports `ok` on a synced machine. A `changed` item names the key that differs.
- **Real values.** Run `git config --global --get-regexp '^(alias|commit|gpg|pull|push|rebase|fetch|merge|init|diff)\.'`. Each key and value matches the role's `settings` and `aliases` maps.
- **Ignore file.** Run `diff roles/git/files/ignore ~/.config/git/ignore`. No output.
- **Sandbox.** Only with user agreement, run `ALLOW_BREW=1 $V sandbox git`, then `HOME=<sandbox> git config --global --get-regexp '^alias\.'`. The aliases are present and run 2 is `changed=0`.
- **Proof.** Quote the recap line and the `get-regexp` output. Leave `user.email` out of the evidence.

## Gotchas

- `user.email` comes from the vault and the task is `no_log`, so the log shows no value. A missing vault secret fails the run at that task.
- The files are copied, not linked. A repo edit reaches the home only after the role runs.
- `user.signingkey` points at `~/.ssh/id_ed25519.pub`, which the ssh role writes. In a git-only sandbox that key is absent, so signed commits there fail.
