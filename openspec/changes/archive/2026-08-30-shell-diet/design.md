## Context

See proposal.md. History counts were taken with `grep -aE '^: [0-9]+:[0-9]+;CMD( |$)' ~/.zsh_history`; `hist_ignore_all_dups` collapses repeats, so zero means "never typed", not "rarely". The `docker` plugin already completes `docker compose`, which is the only thing the `docker-compose` plugin's absence could cost.

## Goals / Non-Goals

**Goals:** a plugin list and alias set that reflect use.

**Non-Goals:** removing `alias-finder` (3 manual uses); removing custom aliases (`kctx`, `rec`, `projects` — see `fix-prompt-config`); startup-time work.

## Decisions

- **Keep `undo` and `amend`**: the only git aliases with any use; two lines.
- **Delete rather than comment out**: git history is the archive.
- **`{{- if eq .chezmoi.os "darwin" }}` / `{{- end }}`**: trims the preceding newline instead of the following indent; renders identically to today on macOS minus the glitch.

## Risks / Trade-offs

- [A plugin was used in a shell whose history wasn't retained] → all reverts are one line; the spec's evidence rule lets the owner re-add with a reason.
