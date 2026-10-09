# Config links

Most roles link a config file or folder from `roles/<role>/files/` into the home directory, so an edit in the repo applies on the next shell or app launch.

## Sub-features

- `links-zsh` links `~/.zshrc`, `~/.zprofile`, and `~/.config/zsh`.
- `links-starship` links `~/.config/starship`.
- `links-ghostty` links `~/.config/ghostty/config`.
- `links-neovim` links `~/.config/nvim`.
- `links-postgresql` links `~/.psqlrc`.
- `links-ruby` links `~/.config/rubocop/rubocop.yml`, `~/.config/rspec/options`, `~/.gemrc`, and `~/.solargraph.yml`, and runs `mise use -g ruby@latest`.
- `links-karabiner` moves a real `~/.config/karabiner` folder to `.bak` and links the folder.

## How to get to it (user POV)

- Run `dotfiles -t <role>` for any role above.

## Driving it with verify.sh

Preconditions:

- `verify.sh doctor` reports `ready`.

- **Check a role.** Run `$V check <role>`. Each link task reports `ok` when the real home already matches, or `changed` with a diff naming the path when it does not.
- **Real link state.** Run `readlink <path>` for each path in the sub-feature. Each target is inside `~/.dotfiles/roles/<role>/files/`.
- **Sandbox ruby.** Run `$V sandbox ruby`. `tree.txt` shows the four ruby links. Expect a long run 1 while mise installs Ruby into the sandbox.
- **Sandbox a Homebrew role.** Only with user agreement, run `ALLOW_BREW=1 $V sandbox <role>`. `tree.txt` shows the links and run 2 is `changed=0`.
- **Proof.** Quote the recap line and the `readlink` output, or the `tree.txt` lines for a sandbox run.

## Gotchas

- Every role here except ruby has Homebrew tasks, so `sandbox` refuses it without `ALLOW_BREW=1`.
- Karabiner ignores a symlinked `karabiner.json`, so the role links the whole folder. Only `karabiner.json` is tracked; Karabiner writes other files into `roles/karabiner/files/`.
- `ruby` writes `~/.config/mise/config.toml` and installs Ruby under the sandbox home, which takes minutes.
