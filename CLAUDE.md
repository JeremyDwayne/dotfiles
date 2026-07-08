# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository using Ansible for automated configuration management. The repository provides a complete development environment setup including shell configuration, terminal emulators, text editors, and development tools.

## Common Commands

### Installation and Updates
- **Initial install**: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/JeremyDwayne/dotfiles/main/local/bin/dotfiles)"`
- **Update environment**: `dotfiles` (runs full playbook)
- **Run specific role**: `dotfiles -t <role_name>` (e.g., `dotfiles -t tmux`)
- **Verbose output**: `dotfiles -vvv`

### Development Commands
- **Run playbook directly**: `ansible-playbook main.yml` (from repository root)
- **Run with vault**: `ansible-playbook --vault-password-file ~/.ansible-vault/vault.secret main.yml`
- **Update Galaxy dependencies**: `ansible-galaxy install -r requirements/common.yml`

## Architecture

### Repository Structure
- **`main.yml`**: Primary Ansible playbook that orchestrates all roles
- **`group_vars/all.yml`**: Configuration variables including default roles, dependencies, and encrypted secrets
- **`roles/`**: Individual component configurations (zsh, neovim, tmux, etc.)
- **`local/bin/`**: Custom scripts symlinked to `~/.local/bin`
- **`requirements/`**: Ansible Galaxy role dependencies

### Role-Based Configuration
Each role in `roles/` follows Ansible structure:
- **`tasks/main.yml`**: Installation and configuration tasks
- **`files/`**: Static configuration files copied to target locations

### Default Roles (from group_vars/all.yml:1-16)
- zsh (shell configuration)
- starship (prompt)
- wezterm (terminal emulator)
- ghostty (terminal emulator)
- ssh (SSH configuration)
- git (Git configuration)
- kitty (alternative terminal)
- karabiner (keyboard customization)
- neovim (text editor with LazyVim)
- tmux (terminal multiplexer)
- fzf (fuzzy finder)
- ruby (Ruby development tools)
- go (Go development tools)
- postgresql (database)
- claude (global Claude Code config + skills)

### Key Dependencies
The system automatically installs core tools including ripgrep, zsh enhancements, jq, the mise version manager, Node.js, and various CLI utilities (fd, gh, lazygit, just, zoxide, bat, git-delta, and more).

### Secrets Management
Uses Ansible Vault for encrypted values (git email, SSH keys). Vault password file location: `~/.ansible-vault/vault.secret`

### Neovim Configuration
- Uses LazyVim as the configuration framework
- Configuration files in `roles/neovim/files/`
- Custom plugins in `lua/plugins/` including augment.lua, commitai.lua, and snacks.lua
- Recent additions include snacks.nvim for LazyGit integration

### Terminal Setup
- Terminals: WezTerm (Lua config), Ghostty, and Kitty (theme support)
- Shell: Zsh with custom aliases, plugins, and environment setup
- Prompt: Starship with TOML configuration

### Version Management
Uses mise for runtime versions (installed in `main.yml` pre_tasks, activated in the zsh config; Ruby pinned via `mise use -g`). Node.js and Go are installed via Homebrew.

### Claude Code Configuration
- The `claude` role symlinks global Claude Code config into `~/.claude/` (CLAUDE.md, settings.json, statusline.sh, claude-app-preferences.md)
- Custom skills live in `roles/claude/files/skills/` (each folder symlinked into `~/.claude/skills/`); third-party skill packs are installed and updated via the `skills` CLI (`npx skills add mattpocock/skills`, `npx skills update`)

## File Locations
- Dotfiles repo: `~/.dotfiles`
- Config directory: `~/.config/dotfiles`
- Vault secret: `~/.ansible-vault/vault.secret`
- Custom scripts: `~/.local/bin` (symlinked from `local/bin/`)