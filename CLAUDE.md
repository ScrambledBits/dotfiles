# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository managed with [chezmoi](https://chezmoi.io), for a Cloud/DevOps engineering workflow: AWS, Kubernetes, Terraform, and teaching tools. Targets both macOS and Linux — Linux support is deliberate, do not remove it. `README.md` is written in Spanish; keep it that way.

## Chezmoi Conventions (source name → target)

- `dot_` prefix → leading dot: `dot_zshrc.tmpl` → `~/.zshrc`; `dot_config/` → `~/.config/`
- `.tmpl` suffix → Go template rendered with `[data]` variables from `.chezmoi.toml.tmpl`: `name`, `email`, `gitSigningKey`
- `private_` prefix → restrictive permissions on the target (not currently used by any file in this repo — reach for it again if a future file needs to live under `~/.claude` or `~/Library` without loosening their permissions)
- `executable_` prefix → target is executable (`dot_config/git/hooks/executable_pre-commit`)
- `symlink_` prefix → target is a symlink; file content is the link destination
- `run_once_*` scripts run once per machine; `run_onchange_*` scripts re-run whenever their rendered content changes
- `.chezmoiexternal.toml` declares externally-fetched content not stored in this repo (Oh My Zsh)
- `.chezmoiignore` excludes: `~/.zshrc.local`, Oh My Zsh runtime/customization dirs (`.oh-my-zsh/cache`, `.oh-my-zsh/custom/**` — must stay untouched by the exact external above), Claude runtime files (everything under `~/.claude` — nothing under `~/.claude` is chezmoi-managed today), the Brewfiles (source-side inputs for scripts, not deployed files), and repo metadata/docs (`CHANGELOG.md`, `TODO.md`, `README.md`, `CLAUDE.md`, `openspec/**`)

## Key Commands

```bash
chezmoi diff                 # preview what would change
chezmoi apply                # apply dotfiles (auto-commits source dir, see below)
chezmoi edit ~/.zshrc        # edit a managed file in nvim
chezmoi edit-config          # change [data] values (name, email, gitSigningKey) for this machine
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
| `dot_config/nvim/init.lua` | Neovim config, bootstraps lazy.nvim |
| `dot_config/ghostty/config.ghostty` | Terminal config, single source read via the XDG path on both OSes |
| `dot_config/shell/paths.tmpl` | Templates `BREW_PREFIX` per OS/arch and sets `PATH` — deliberate central place, do not inline into `.zshrc` |
| `dot_config/git/hooks/executable_pre-commit` | Runs `gitleaks protect --staged` if gitleaks is installed, then chains to a repo-local `.git/hooks/pre-commit` if one exists |
| `.chezmoiexternal.toml` | Fetches Oh My Zsh as an archive (nothing installs it otherwise) |
| `Brewfile`, `Brewfile.MacOS` | Package lists consumed by the darwin install script |
| `run_once_before_install-homebrew-{darwin,linux}.sh.tmpl` | Bootstrap Homebrew/Linuxbrew |
| `run_onchange_before_install-packages-{darwin,linux}.sh.tmpl` | Install packages (Brewfile on macOS); darwin bundles `mas` entries separately after `mas` itself is installed |
| `run_onchange_after_install-mise-tools.sh.tmpl` | Runs `mise install` when mise config changes |
| `run_once_after_setup-ssh-sockets.sh` | Creates `~/.ssh/sockets` for SSH multiplexing |
| `.github/workflows/chezmoi-dry-run.yml` | CI: dry-run apply on ubuntu + macos, shellcheck on rendered scripts, Starship config check |
| `openspec/` | [OpenSpec](https://openspec.dev) planning: `changes/<name>/{proposal,design,tasks}.md` + spec deltas; `specs/` fills in as changes are archived. Run `npx @fission-ai/openspec list` / `/opsx:apply <name>` / `/opsx:archive <name>` |

## Architecture

**Shell (`dot_zshrc.tmpl`)**: Oh My Zsh with theme disabled — Starship is the prompt (OS icon via Starship's own `[os]` module, no shell-side plumbing). Loads `BREW_PREFIX`/`PATH` from the managed `paths.tmpl` file, then integrates mise (via the OMZ `mise` plugin — do not also `eval mise activate` in `.zshrc`), direnv, zoxide (`z` replaces `cd`), fzf (ripgrep-backed), and git-extras completion; the starship/direnv/zoxide evals are `command -v`-guarded so a missing tool doesn't break the shell. Sources `~/.config/shell/.env` and `api_keys.env` (machine-local, created manually). Sources `zsh-autosuggestions` and `fast-syntax-highlighting` from Homebrew if installed. `~/.zshrc.local` is sourced last for machine overrides.

**Version management (`dot_config/mise/config.toml`)**: mise manages Python, uv, Node, Go, Rust, Terraform 1.15.9 (pinned), Terragrunt, TFLint, fd, lazygit, and delta. Sets `PIP_REQUIRE_VIRTUALENV=true`. Defines the `tg` → `terragrunt` alias under `[shell_alias]` (a valid mise key — do not flag it) and the `tf-check`/`tf-docs`/`k8s-check`/`secrets-check` tasks. OpenTofu is a commented-out alternative to Terraform. Machine-local tools (e.g. one machine's `flutter`) belong in an untracked `~/.config/mise/config.local.toml`, which mise loads automatically alongside `config.toml` — never add a machine-only tool to the tracked file.

**Per-directory environments (`dot_config/direnv/direnvrc`)**: Helper functions for `.envrc` files — `use_aws_profile()`, `use_tf_workspace()`. `use_mise()` was removed as deprecated; mise loading happens via shell activation.

**Prompt (`dot_config/starship.toml`)**: OS icon (`[os]` module), git status, Kubernetes context/namespace (only in k8s project directories), AWS profile, Terraform workspace, command duration. `command_timeout = 1000` prevents slow prompts. Verify module keys against the Starship schema before editing — invalid keys have been introduced here before.

**Ghostty (`dot_config/ghostty/config`)**: Single config at the XDG path `~/.config/ghostty/config`. Ghostty reads **both** `config` and `config.ghostty` from each config directory and loads `config.ghostty` **last**, so a stray `~/.config/ghostty/config.ghostty` silently overrides the managed file — verified empirically against Ghostty 1.3.1, which is exactly how the pre-`a35ef2c` leftover shadowed this config on Rivendell until 2026-09-15. `.chezmoiremove` now deletes that leftover on every machine. On macOS the `~/Library/Application Support/com.mitchellh.ghostty/` files load after the XDG ones; nothing is tracked there, so the XDG file is the only source of truth.

**Git (`dot_gitconfig.tmpl`)**: delta for diffs (side-by-side), rebase on pull, auto-prunes remote refs, `zdiff3` conflict style, `rerere` enabled, branches sorted by recency, LFS filters, `osxkeychain` credential helper (darwin only). `core.hooksPath = ~/.config/git/hooks` wires in the global gitleaks pre-commit hook, which then chains to a repo-local `.git/hooks/pre-commit` (via `git rev-parse --git-dir`, resolving the *actual* `.git` directory — **never** `git rev-parse --git-path hooks`, which returns this global hooksPath itself and would make the hook call itself). `pre-commit install` still refuses to run per-repo while `core.hooksPath` is set globally (this is pre-commit's own installer check, independent of what the hook does); use `pre-commit install -f` to force-install into `.git/hooks/pre-commit`, which the global hook then picks up. SSH commit/tag signing is opt-in: the whole `[gpg]`/`[commit]` block only renders when `gitSigningKey` is set (prompted at `chezmoi init`, changeable later via `chezmoi edit-config`).

**SSH (`dot_ssh/config.tmpl`)**: Hardened `Host *` defaults (modern ciphers, no `KexAlgorithms` pin — inherits the client's default post-quantum-capable list, `StrictHostKeyChecking accept-new`, multiplexing via `~/.ssh/sockets`), minimal GitHub/GitLab host entries (just `User`/`PreferredAuthentications`; identity settings come from `Host *`), OrbStack include on macOS only, and an `Include ~/.ssh/config.local` for untracked machine-local hosts.

## Aliases Reference

Custom aliases are minimal; `g*`, `tf*`, and `k*` families come from the enabled OMZ plugins (git, terraform, kubectl):
- `vim` → nvim
- `cat` → bat, `grep` → `batgrep --terminal-width=200 --no-snip`, `find` → fd
- `ls`/`ll`/`la` → eza variants, `l` → `la`
- `kctx` → kubectx, `projects` → `cd ~/Projects`, `rec` → `asciinema rec`

## Chezmoi Auto-commit

`git.autoCommit = true` in `.chezmoi.toml.tmpl`: `chezmoi apply` auto-commits changes to the source directory. Auto-push is disabled (`git.autoPush = false`).

## Machine-specific Overrides (all untracked, created manually)

- Shell: `~/.zshrc.local` (sourced at end of `.zshrc`)
- Env: `~/.config/shell/.env` (sourced globally in `.zshrc`)
- API keys shared across projects: `~/.config/shell/api_keys.env` — deliberately **not** sourced globally (would put every key into every shell process); opted into a project via `dotenv_if_exists ~/.config/shell/api_keys.env` in that project's `.envrc`. Never add a global `source` of this file back to `.zshrc`.
- SSH hosts: `~/.ssh/config.local`
- Chezmoi data: run `chezmoi edit-config` on the machine to change `[data]` values (e.g. `gitSigningKey`, a work `email`) without editing tracked files
- mise tools: `~/.config/mise/config.local.toml` for machine-only tools (mise loads it automatically alongside the tracked `config.toml`)
