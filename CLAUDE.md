# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles repository using Ansible for automated configuration management. The repository provides a complete development environment setup including shell configuration, terminal emulators, text editors, and development tools.

## Common Commands

### Installation and Updates
- **Initial install**: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/JeremyDwayne/dotfiles/main/local/bin/dotfiles)"`
- **Update environment**: `dotfiles` (runs full playbook)
- **Run specific role**: `dotfiles -t <role_name>` (e.g., `dotfiles -t zsh`)
- **Verbose output**: `dotfiles -vvv`

### Development Commands
- **Run playbook directly**: `ansible-playbook main.yml` (from repository root)
- **Run with vault**: `ansible-playbook --vault-password-file ~/.ansible-vault/vault.secret main.yml`
- **Update Galaxy dependencies**: `ansible-galaxy collection install --upgrade -r requirements/common.yml`

## Architecture

The default role list and dependencies live in `group_vars/all.yml`; each role under
`roles/` is standard Ansible (`tasks/main.yml` + `files/`).

### Secrets Management
Uses Ansible Vault for encrypted values (git email, SSH keys). Vault password file location: `~/.ansible-vault/vault.secret`

### Version Management
Uses mise for runtime versions (installed in `main.yml` pre_tasks, activated in the zsh config; Ruby pinned via `mise use -g`). Node.js and Go are installed via Homebrew.

### Claude Code Configuration
- The `claude` role symlinks global Claude Code config into `~/.claude/` (CLAUDE.md, settings.json, statusline.sh, claude-app-preferences.md); it also registers user-scoped MCP servers with `claude mcp add` since `~/.claude.json` holds secrets and runtime state and is not tracked
- Custom skills live in `roles/claude/files/skills/` (each folder symlinked into `~/.claude/skills/`); third-party skill packs are installed and updated via the `skills` CLI (`npx skills add mattpocock/skills`, `npx skills update`)
- Plugins live in `roles/claude/files/plugins/`, a local marketplace named `dotfiles` declared in settings.json (`extraKnownMarketplaces`, `enabledPlugins`); plugins load in place, so edits apply after `/reload-plugins`
- Hook scripts live in `roles/claude/files/hooks/` (each symlinked into `~/.claude/hooks/`, wired up in settings.json); `roles/claude/files/templates/REVIEW.md` is the CI review policy to copy into a repo
- The engineering loop (spec, plan, implement, ship) is documented in `roles/claude/files/skills/README.md`; `.scratch/` is gitignored globally via the git role

## File Locations
- Dotfiles repo: `~/.dotfiles`
- Config directory: `~/.config/dotfiles`
- Vault secret: `~/.ansible-vault/vault.secret`
- Custom scripts: `~/.local/bin` (symlinked from `local/bin/`)