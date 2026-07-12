# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managed with [chezmoi](https://chezmoi.io), for a Cloud/DevOps engineering workflow: multi-cloud (GCP, AWS, Azure), Kubernetes, Terraform, and teaching tools. Targets both macOS and Linux — Linux support is deliberate, do not remove it. `README.md` is written in Spanish; keep it that way.

## Chezmoi Conventions (source name → target)

- `dot_` prefix → leading dot: `dot_zshrc.tmpl` → `~/.zshrc`; `dot_config/` → `~/.config/`
- `.tmpl` suffix → Go template rendered with `[data]` variables from `.chezmoi.toml.tmpl`: `name`, `email`, `github`, `timezone`, `gitSigningKey`
- `private_` prefix → restrictive permissions on the target. Used on `private_dot_claude/` and `private_Library/` specifically so chezmoi does not loosen `~/.claude` and `~/Library` permissions — never drop this prefix there
- `executable_` prefix → target is executable (`dot_config/git/hooks/executable_pre-commit`)
- `symlink_` prefix → target is a symlink; file content is the link destination
- `run_once_*` scripts run once per machine; `run_onchange_*` scripts re-run whenever their rendered content changes
- `.chezmoiignore` excludes: machine-local overrides (`~/.chezmoidata/local.toml`, `secrets.yml`, `~/.zshrc.local`), Claude runtime files (everything under `~/.claude` except `settings.json`), VS Code runtime dirs, the Brewfiles (source-side inputs for scripts, not deployed files), repo metadata (`CHANGELOG.md`, `TODO.md`, `.gitignore`), and `Library/**` on Linux

## Key Commands

```bash
chezmoi diff                 # preview what would change
chezmoi apply                # apply dotfiles (auto-commits source dir, see below)
chezmoi edit ~/.zshrc        # edit a managed file in nvim
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git   # new machine
mise install                 # install all tool versions from mise config
mise run tf-check            # terraform fmt -check + tflint + validate
mise run k8s-check           # kubeconform manifest validation
mise run secrets-check       # gitleaks repo scan
```

## Repository Map

| Source | Purpose |
|---|---|
| `dot_zshrc.tmpl` | Zsh config (see Architecture) |
| `dot_gitconfig.tmpl` | Git config (see Architecture) |
| `dot_ssh/config.tmpl` | SSH config (see Architecture) |
| `dot_config/mise/config.toml` | Tool versions, env vars, tasks |
| `dot_config/starship.toml` | Prompt |
| `dot_config/direnv/direnvrc` | direnv helper functions |
| `dot_config/nvim/init.lua` | Neovim, single-file config, no plugin manager |
| `dot_config/ghostty/config.ghostty` | Terminal config (single source for both OSes) |
| `dot_config/shell/paths` | Central place for custom PATH entries — deliberate, do not inline into `.zshrc` |
| `dot_config/git/hooks/executable_pre-commit` | Runs `gitleaks protect --staged` if gitleaks is installed |
| `dot_vscode/argv.json` | VS Code runtime args (only file managed under `~/.vscode`) |
| `private_dot_claude/settings.json` | Claude Code settings (only file managed under `~/.claude`) |
| `Brewfile`, `Brewfile.MacOS` | Package lists consumed by the darwin install script |
| `run_once_before_install-homebrew-{darwin,linux}.sh.tmpl` | Bootstrap Homebrew/Linuxbrew |
| `run_onchange_before_install-packages-{darwin,linux}.sh.tmpl` | Install packages (Brewfile on macOS) |
| `run_onchange_after_install-mise-tools.sh.tmpl` | Runs `mise install` when mise config changes |
| `run_once_after_setup-ssh-sockets.sh` | Creates `~/.ssh/sockets` for SSH multiplexing |

## Architecture

**Shell (`dot_zshrc.tmpl`)**: Oh My Zsh with theme disabled — Starship is the prompt (OS icon via `STARSHIP_DISTRO`, exported here per-OS). Integrates mise, direnv, zoxide (`z` replaces `cd`), fzf (ripgrep-backed), GCP SDK, and git-extras completion. Sources `~/.config/shell/.env` and `api_keys.env` (machine-local, created manually) plus the managed `paths` file. Sources `zsh-autosuggestions` and `fast-syntax-highlighting` from Homebrew if installed. `~/.zshrc.local` is sourced last for machine overrides.

**Version management (`dot_config/mise/config.toml`)**: mise manages Python, uv, Node, Go, Rust, Terraform 1.15.7 (pinned), Terragrunt, TFLint, fd, lazygit, and delta. Sets `PIP_REQUIRE_VIRTUALENV=true`. Defines the `tg` → `terragrunt` alias under `[shell_alias]` (a valid mise key — do not flag it) and the `tf-check`/`tf-docs`/`k8s-check`/`secrets-check` tasks. OpenTofu is a commented-out alternative to Terraform.

**Per-directory environments (`dot_config/direnv/direnvrc`)**: Helper functions for `.envrc` files — `use_aws_profile()`, `use_gcp_project()`, `use_tf_workspace()`. `use_mise()` was removed as deprecated; mise loading happens via shell activation.

**Prompt (`dot_config/starship.toml`)**: OS icon, git status, Kubernetes context/namespace (only in k8s project directories), GCP project, AWS profile, Terraform workspace, command duration. `command_timeout = 1000` prevents slow prompts. Verify module keys against the Starship schema before editing — invalid keys have been introduced here before.

**Ghostty (`dot_config/ghostty/config.ghostty`)**: Single config at the XDG path (read on both OSes). On macOS, `Library/Application Support/com.mitchellh.ghostty/config.ghostty` is a chezmoi-managed symlink to it (that path loads last and wins there); `.chezmoiignore` skips `Library/**` on Linux.

**Git (`dot_gitconfig.tmpl`)**: delta for diffs (side-by-side), rebase on pull, auto-prunes remote refs, `zdiff3` conflict style, `rerere` enabled, branches sorted by recency, LFS filters, osxkeychain credential helper. `core.hooksPath = ~/.config/git/hooks` wires in the gitleaks pre-commit hook. SSH commit/tag signing is opt-in: the whole `[gpg]`/`[commit]` block only renders when `gitSigningKey` is set.

**SSH (`dot_ssh/config.tmpl`)**: Hardened `Host *` defaults (modern ciphers, `StrictHostKeyChecking accept-new`, multiplexing via `~/.ssh/sockets`), GitHub/GitLab host entries, OrbStack include on macOS only, and an `Include ~/.ssh/config.local` for untracked machine-local hosts.

## Aliases Reference

Custom aliases are minimal; `g*`, `tf*`, and `k*` families come from the enabled OMZ plugins (git, terraform, kubectl):
- `vim` → nvim
- `cat` → bat, `grep` → `batgrep --terminal-width=200 --no-snip`, `find` → fd
- `ls`/`ll`/`la` → eza variants, `l` → `la`

## Chezmoi Auto-commit

`git.autoCommit = true` in `.chezmoi.toml.tmpl`: `chezmoi apply` auto-commits changes to the source directory. Auto-push is disabled (`git.autoPush = false`).

## Machine-specific Overrides (all untracked, created manually)

- Shell: `~/.zshrc.local` (sourced at end of `.zshrc`)
- Env/secrets: `~/.config/shell/.env`, `~/.config/shell/api_keys.env`
- SSH hosts: `~/.ssh/config.local`
- Chezmoi data: `~/.chezmoidata/local.toml` (overrides `[data]` values like `gitSigningKey`)
