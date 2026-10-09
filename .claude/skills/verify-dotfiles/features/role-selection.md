# Role selection

The playbook runs `default_roles` from `group_vars/all.yml` minus `exclude_roles` when no tag is given, or exactly the tagged roles when `-t` is given. The chosen list is printed by the `Display roles` task.

## Sub-features

- `roles-default` runs every role in `default_roles` when tags are empty or `all`.
- `roles-tagged` runs only the roles named by `-t`, comma separated.
- `roles-exclude` drops roles listed in `exclude_roles` from the default run.

## How to get to it (user POV)

- Run `dotfiles`.
- Run `dotfiles -t zsh,git`.
- Run `dotfiles -e '{"exclude_roles":["go"]}'`.

## Driving it with verify.sh

Preconditions:

- `verify.sh doctor` reports `ready`.

- **Default list.** Run `$V check all`. In `check.log`, `Display roles` prints a `run_roles` list with every role from `default_roles`, and `Run roles` shows one `included:` line per role.
- **Tagged roles.** Run `$V check zsh,git`. `run_roles` is `["zsh", "git"]` and no other role's tasks appear.
- **Exclusion.** Run `$V check all -e '{"exclude_roles":["go","ruby"]}'`. `run_roles` has every default role except `go` and `ruby`, and no `go :` or `ruby :` task lines appear.
- **Proof.** Quote the `run_roles` block and the recap line from each `check.log`.

## Gotchas

- With no tags, `run_roles` order is not `default_roles` order, because the `difference` filter does not keep order. Compare as sets.
- `exclude_roles` has no effect when `-t` is given.
- A full `check all` takes about 25 seconds. The karabiner role prompts for a sudo password when `/Applications/Karabiner-Elements.app` is missing, which hangs a run with stdin on `/dev/null`.
