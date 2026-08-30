## Why

`~/.zsh_history` (7 054 lines, 2024-12 → 2026-08) shows zero uses of the commands provided by 7 of the 15 Oh My Zsh plugins (`ansible`, `docker-compose`, `gitignore`, `aliases`, `history`, `brew`, `macos`) and of 14 of the 16 git aliases in `dot_gitconfig.tmpl` (`undo`, `amend` once each); `DISABLE_UNTRACKED_FILES_DIRTY` only affects OMZ themes and the theme is disabled; `{{ end -}}` after the darwin-only `macos` plugin eats the indentation of the next line in the rendered file (audit 2026-08-30: R-7, R-8, R-9, R-11; assumption A-2 — counts are lower bounds because `hist_ignore_all_dups` is on).

## What Changes

- `dot_zshrc.tmpl`: remove the 7 plugins (list becomes `alias-finder colored-man-pages docker git git-extras kubectl man mise terraform`); delete `DISABLE_UNTRACKED_FILES_DIRTY`; use `{{- if … }}`/`{{- end }}` around `macos` so both OS renders keep the indent.
- `dot_gitconfig.tmpl`: delete the `[alias]` block, keeping `undo` and `amend`.
- CLAUDE.md Aliases Reference and README "Neovim y git" pointer updated to match.

## Capabilities

### New Capabilities
- `zsh-configuration`: the plugin set the shell loads and the rule that every plugin earns its place.

### Modified Capabilities
- (none)

## Impact

`dot_zshrc.tmpl:36,44-61`, `dot_gitconfig.tmpl:67-90`, `CLAUDE.md`, `README.md:142`. Startup already ≈ 0.23 s; expect a small reduction (14 fewer sourced files). `gst`/`k`/`tf` families are unaffected.
