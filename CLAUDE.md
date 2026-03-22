# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed with [chezmoi](https://chezmoi.io). It targets a Cloud/DevOps engineering workflow with multi-cloud (GCP, AWS, Azure), Kubernetes, Terraform, and teaching tools.

## Chezmoi Conventions

- Files prefixed with `dot_` map to dotfiles (e.g., `dot_zshrc` → `~/.zshrc`)
- Files ending in `.tmpl` are Go templates rendered by chezmoi with variables from `.chezmoi.toml.tmpl`
- Template variables are defined in `.chezmoi.toml.tmpl` under `[data]`: `name`, `email`, `github`, `timezone`, `gitSigningKey`
- `dot_config/` maps to `~/.config/`
- `.chezmoiignore` excludes machine-local files (`~/.chezmoidata/local.toml`, `~/.zshrc.local`)

## Key Commands

```bash
# Apply all dotfiles to the home directory
chezmoi apply

# Apply and see what would change first
chezmoi diff

# Edit a managed file (opens in nvim, applies on save)
chezmoi edit ~/.zshrc

# Re-initialize on a new machine
chezmoi init --apply https://github.com/ScrambledBits/dotfiles

# Install all tool versions defined in mise config
mise install
```

## Architecture

**Shell (`dot_zshrc.tmpl`)**: Oh My Zsh with robbyrussell theme. Integrates mise, direnv, zoxide (`z` replaces `cd`), and Starship. Sources `~/.zshrc.local` for machine-specific overrides. Also sources `zsh-autosuggestions` and `fast-syntax-highlighting` from Homebrew if installed.

**Version management (`dot_config/mise/config.toml`)**: mise manages Python 3.13, Node 24, Go 1.26, Terraform 1.14.7, Terragrunt 0.99, TFLint 0.61, Poetry 2.3, Ruff 0.15, AWS CLI, fd, and lazygit. Sets `PIP_REQUIRE_VIRTUALENV=true` to prevent global pip installs. OpenTofu is available as a commented-out alternative to Terraform.

**Per-directory environments (`dot_config/direnv/direnvrc`)**: Defines helper functions for `.envrc` files — `use_aws_profile()`, `use_gcp_project()`, `use_tf_workspace()`. Note: `use_mise()` was removed as it's deprecated; mise tool loading is handled by shell activation.

**Prompt (`dot_starship.toml`)**: Shows git status, Kubernetes context/namespace (only in k8s project directories), GCP project, Terraform workspace, and command duration. Has `scan_timeout` and `command_timeout` set to prevent slow prompts.

**Git (`dot_gitconfig.tmpl`)**: Uses delta for diffs (side-by-side), rebase on pull, auto-prunes remote refs, `zdiff3` conflict style, `rerere` enabled, branches sorted by recency. SSH commit signing is opt-in via `gitSigningKey` data variable.

## Aliases Reference

The zsh config defines extensive aliases. Key namespaces:
- `g*` — git (gs, gd, gco, gcb, gcm, gcam, gp, gpl, gfp, gl, gst, gsp, etc.)
- `tf*` — Terraform (tfv=validate, tfp=plan, tfa=apply, tfws=workspace select)
- `k*` — Kubernetes (k=kubectl, kctx, kns, kg, kd, kl, klf, kgp, kgs, kgn, kaf, kdf)
- `cat` → bat, `find` → fd
- `rec` / `vhs-rec` — teaching session recording with asciinema/vhs

## Chezmoi Auto-commit

`git.autoCommit = true` is set in `.chezmoi.toml.tmpl`, so `chezmoi apply` will automatically commit changes to the source directory. Auto-push is disabled (`git.autoPush = false`).

## Machine-specific Overrides

- Shell: `~/.zshrc.local` (not tracked, sourced at end of `.zshrc`)
- Chezmoi data: `~/.chezmoidata/local.toml` (not tracked, overrides `[data]` values like `gitSigningKey`)
