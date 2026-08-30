## Why

`chezmoi init` prompts for a `github` username whose only consumer is `[github] user` in `.gitconfig`, a key read by `hub` (not installed; `gh` uses its own `hosts.yml`); `.chezmoiignore` carries 15 `.claude/*` entries although nothing under `~/.claude` is in the source, so a single `.claude` line is equivalent (audit 2026-08-30: R-3, R-4).

## What Changes

- `.chezmoi.toml.tmpl`: remove the `github` prompt. `dot_gitconfig.tmpl`: remove `[github] user`. CLAUDE.md: drop `github` from the `[data]` variable list.
- `.chezmoiignore:12-27`: replace with one line `.claude`.

## Capabilities

### New Capabilities
- `chezmoi-init`: which values `chezmoi init` prompts for and what each must feed.

### Modified Capabilities
- (none)

## Impact

`.chezmoi.toml.tmpl:13`, `dot_gitconfig.tmpl:10-11`, `.chezmoiignore:12-27`, `CLAUDE.md`. Existing machines keep a stale `github` key in their untracked `chezmoi.toml` (harmless; `promptStringOnce` never re-reads it once the template stops referencing it).
