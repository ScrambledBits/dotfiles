# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed with [chezmoi](https://chezmoi.io). It targets a Cloud/DevOps engineering workflow with multi-cloud (GCP, AWS, Azure), Kubernetes, Terraform, and teaching tools.

## Chezmoi Conventions

- Files prefixed with `dot_` map to dotfiles (e.g., `dot_zshrc` → `~/.zshrc`)
- Files ending in `.tmpl` are Go templates rendered by chezmoi with variables from `.chezmoi.toml.tmpl`
- Template variables are defined in `.chezmoi.toml.tmpl` under `[data]`: `name`, `email`, `github`, `timezone`
- `dot_config/` maps to `~/.config/`

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

**Shell (`dot_zshrc.tmpl`)**: Oh My Zsh with robbyrussell theme. Integrates mise (version manager), direnv, zoxide (`z` replaces `cd`), and Starship prompt. Sources `~/.zshrc.local` for machine-specific overrides not tracked in this repo.

**Version management (`dot_config/mise/config.toml`)**: mise manages Python 3.12, Node 20, Go 1.22, Terraform 1.7.5, Terragrunt, TFLint, Poetry, AWS CLI, and Ruff. Sets `PIP_REQUIRE_VIRTUALENV=true` to prevent global pip installs.

**Per-directory environments (`dot_config/direnv/direnvrc`)**: Defines helper functions for `.envrc` files — `use_mise()`, `use_aws_profile()`, `use_gcp_project()`, `use_tf_workspace()`.

**Prompt (`dot_starship.toml`)**: Shows git status, Kubernetes context/namespace, GCP project, Terraform workspace, and command duration.

**Git (`dot_gitconfig.tmpl`)**: Uses delta for diffs (side-by-side), rebase on pull, auto-prunes remote refs, nvimdiff as merge tool.

## Aliases Reference

The zsh config defines extensive aliases. Key namespaces:
- `g*` — git (gs, gd, gco, gcb, gcm, gcam, gp, gpl, gl, etc.)
- `tf*` — Terraform (tfv=validate, tfp=plan, tfa=apply, tfws=workspace select)
- `k*` — Kubernetes (k=kubectl, kctx, kns, kg, kd, kl, klf, kgp, kgs, kgn, kaf, kdf)
- `rec` / `vhs-rec` — teaching session recording with asciinema/vhs

## Chezmoi Auto-commit

`git.autoCommit = true` is set in `.chezmoi.toml.tmpl`, so `chezmoi apply` will automatically commit changes to the source directory. Auto-push is disabled (`git.autoPush = false`).
