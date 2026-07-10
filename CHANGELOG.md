# Changelog

## 2026-08-30 (2)

- `Brewfile.MacOS`: dropped `dbeaver-community`, `raycast`, `slack`, `tabby` (owner decision, post-apply) — uninstalled from the machine, no longer reinstalled by `chezmoi apply`.

## 2026-08-30

OpenSpec-driven remediation (`openspec/changes/`, all archived after implementation):

- Linux quick start actually works: chezmoi installs to `~/.local/bin` (was `./bin`, unreachable on `PATH`), `zsh` is installed by the bootstrap script, and the mise-tools script finds Homebrew via a shared `.chezmoitemplates/brew-path.sh` prologue (also used by both package scripts).
- `vscode "…"` extension lines and OrbStack moved/added to `Brewfile.MacOS` — the shared `Brewfile` no longer errors on Linux or silently installs the VS Code cask on macOS.
- Package ownership: deleted the dead `cloudflare/cloudflare` tap, the three `uv "…"` Brewfile lines (they were reinstalling `uv` via brew next to mise's), and the redundant `brew "cairo"` (already a `librsvg` dependency); `ruff`, `mdformat`, `nano-pdf` now install via mise.
- Prompt fixes: `[rust]` had an invalid Starship colour (`bold orange`, silently unstyled) → `bold 208`; the `renamed` git-status glyph was a stray CJK character → `»`; two `[directory.substitutions]` entries that could never match on any machine were removed.
- Dropped the `teaching` alias, its prompt substitution, and the README teaching-flow section (`~/Projects/teaching` doesn't exist on any target machine).
- Shell diet: removed 7 Oh My Zsh plugins and 14 git aliases with zero uses across 20 months of shell history; fixed a template-whitespace bug that mis-indented the rendered plugin list on Linux.
- Removed the unused `github` chezmoi-init prompt and its `[github]` gitconfig consumer; collapsed 15 `.chezmoiignore` lines for `.claude/*` into one `.claude` line.
- Linux gets a `credential.helper = cache --timeout=3600` (was darwin-only); README documents `gh auth setup-git` for GitHub specifically.
- CI now applies the rendered dotfiles into a scratch `$HOME` on both runners and runs a real interactive `zsh` smoke test (aliases resolve, no syntax errors), not just a template dry-run.
- `Brewfile.MacOS` owner review: cut `rabbitmq`, `cocoapods`, `tectonic` (zero use, no connection to the stated workflow), `mysqlworkbench` and `pgadmin4` (redundant with `dbeaver-community`), and 13 of 14 Nerd Font casks (only `font-hurmit-nerd-font` is referenced by Ghostty). Kept `aws-vault` (pairs with the `use_aws_profile` direnv helper), `llmfit`, `openai-whisper`, `poppler`, `watson`, `ollama`.

## 2026-08-29

- `dot_config/shell/paths.tmpl` now templates `BREW_PREFIX` per OS/arch and prepends it to `PATH` — fixes a fresh machine where Homebrew was never on `PATH` from any managed file.
- Oh My Zsh installs automatically via a `.chezmoiexternal.toml` archive entry instead of requiring a manual clone.
- Starship's built-in `[os]` module replaces the broken `STARSHIP_DISTRO` export (it had rendered empty since it was introduced).
- `gitSigningKey` is now a real `promptStringOnce` prompt (was hardcoded empty); SSH commit signing is reachable for the first time.
- `credential.helper = osxkeychain` and the OMZ `macos` plugin are darwin-guarded; `clipboard = "unnamedplus"` fixes the Neovim system clipboard on Linux.
- The global gitleaks pre-commit hook chains to a repo-local hook via `git rev-parse --git-dir` (the previous `--git-path hooks` form would have called itself).
- Removed the `KexAlgorithms` pin in the SSH config so the client's own default (post-quantum-capable) list applies.
- Mac App Store apps install in the correct order relative to `mas` itself; the documented recovery command now targets the correct `entryState` bucket.
- `nvim-treesitter` moved from the locked `master` branch to `main`.
- Added `.github/workflows/chezmoi-dry-run.yml`: renders and dry-run applies on ubuntu-latest and macos-latest, shellchecks every rendered script, validates the Starship config.
- `README.md`, `CLAUDE.md`, and the audit outputs no longer deploy into `$HOME` (added to `.chezmoiignore`).

## 2026-07-10

- Ghostty consolidado a un solo archivo `~/.config/ghostty/config` (apariencia real de la máquina: Hack Nerd Font Mono 20, tema Nocturnal Winter). Eliminados `config.ghostty` y el symlink en Application Support: en Ghostty ≥1.3 ese par sobreescribía la config del usuario (App Support carga al final y gana).
- Firma de commits: eliminado `gpg.format = ssh`; `gitSigningKey` es un key ID de OpenPGP, con `format = ssh` git lo trata como ruta de llave SSH y la firma falla.
- Docs: README (tema robbyrussell, tabla de versiones mise, aliases) y CLAUDE.md actualizados; comentario de `gitSigningKey` corregido en `.chezmoi.toml.tmpl`.

## 2026-07-09

- Corregido: config de Starship se desplegaba a `~/.config/.starship.toml` (ruta muerta); ahora `dot_config/starship.toml` → `~/.config/starship.toml`.
- Corregido: `dot_library/` desplegaba a `~/.library/` en vez de `~/Library/`; Ghostty ahora usa un solo archivo en `~/.config/ghostty/config.ghostty` con symlink en Application Support (macOS).
- Ghostty: apariencia reconciliada desde la máquina (Hurmit Nerd Font Mono 18, tema Afterglow) + comportamiento del repo.
- Eliminado `dot_vimrc` (vim = nvim en todo el flujo).
- Aliases podados según uso real del historial; `tf*`/`k*` vienen de los plugins de OMZ.
- `STARSHIP_DISTRO` exportado en `.zshrc` (ícono de OS en el prompt).
- Git: eliminados defaults redundantes (`push.default`, `color.ui`); agregado `git-lfs` al Brewfile.
- SSH: `SetEnv TERM=xterm-256color` agregado al repo (fix para Ghostty en hosts remotos).
- mise: terraform 1.15.7 (reconciliado), sin `experimental`, `shell_alias` solo `tg`.
- Brewfiles: sin `uv` duplicado (lo gestiona mise), sin líneas comentadas de mdbook/gnupg; agregada fuente Hurmit.
