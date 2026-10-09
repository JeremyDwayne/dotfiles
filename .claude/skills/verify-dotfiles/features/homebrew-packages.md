# Homebrew packages

The playbook installs and keeps current the CLI tools and apps the environment needs: mise as a pre_task, the `dependencies` list through the zsh role, and each role's own formula or cask.

## Sub-features

- `brew-mise` installs or upgrades mise before any role runs.
- `brew-dependencies` installs or upgrades every formula in `dependencies` in `group_vars/all.yml`.
- `brew-role` installs or upgrades each role's package, for example `fzf`, `starship`, `postgresql@18`, `neovim`, and the `ghostty` cask.

## How to get to it (user POV)

- Run `dotfiles`, or `dotfiles -t <role>` for a role with a Homebrew task.

## Driving it with verify.sh

Preconditions:

- `verify.sh doctor` reports `ready`.

- **Check a package task.** Run `$V check zsh`. `ZSH | Install Dependencies` reports `ok` when every dependency is installed and current, or `changed` when any is missing or outdated.
- **Explain a change.** Run `HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --formula <names>` and `brew list --versions <names>`. Each `changed` package task maps to a missing or outdated package.
- **New dependency.** After adding a formula to `dependencies`, run `$V check zsh`. The task reports `changed`, and `brew list --versions <formula>` confirms it is not yet installed.
- **Proof.** Quote the recap line, the `changed` task names, and the `brew outdated` output that explains them.

## Gotchas

- Check mode never installs, so it proves the task resolves, not that the install succeeds. A real install needs `ALLOW_BREW=1` and the user's agreement.
- `Install mise` is tagged `always`, so it appears in every `check` run and reports `changed` while mise is outdated.
- The Karabiner cask installs only when the app is missing, and then prompts for a sudo password.
