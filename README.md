# Dotfiles

Here's my collection of dotfiles I use on MacOS.

## vault.secret

The vault.secret file allows you to encrypt values with Ansible vault and store them securely in source control. Create a file located at ~/.config/dotfiles/vault.secret with a secure password in it.

```sh
vim ~/.ansible-vault/vault.secret
```

To then encrypt values with your vault password use the following:

```sh
ansible-vault encrypt_string --vault-password-file $HOME/.ansible-vault/vault.secret "mynewsecret" --name "MY_SECRET_VAR"
cat myfile.conf | ansible-vault encrypt_string --vault-password-file $HOME/.ansible-vault/vault.secret --stdin-name "myfile"
```

> NOTE: This file will automatically be detected by the playbook when running dotfiles command to decrypt values. Read more on Ansible Vault here.

## Usage

### Install

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JeremyDwayne/dotfiles/main/local/bin/dotfiles)"
```

### Update

This repository is continuously updated with new features and settings which become available to you when updating.

To update your environment run the dotfiles command in your shell:

```sh
dotfiles
```

This will handle the following tasks:

- Verify Ansible is up-to-date
- Generate SSH keys and add to ~/.ssh/authorized_keys
- Clone this repository locally to ~/.dotfiles
- Verify any ansible-galaxy plugins are updated
- Run this playbook with the values in ~/.config/dotfiles/group_vars/all.yaml

This dotfiles command is available to you after the first use of this repo, as it adds this repo's bin directory to your path, allowing you to call dotfiles from anywhere.

Any flags or arguments you pass to the dotfiles command are passed as-is to the ansible-playbook command.

For Example: Running the tmux tag with verbosity

```sh
dotfiles -t tmux -vvv
```
