## Context

See proposal.md — Why. Constraints: chezmoi runs scripts with its own environment and never sources login profiles; the README macOS path is already correct; the panel rejected merging the OS-split package scripts (2026-08-28, refactor-002), so deduplication must not merge them.

## Goals / Non-Goals

**Goals:**
- Every README Linux command works in the order written on Debian/Ubuntu, Fedora, Arch.
- One copy of the Homebrew-prefix detection logic.

**Non-Goals:**
- Automating `chsh` (needs a password / interactive session).
- Supporting Linux without sudo (the bootstrap already assumes `sudo`).
- Merging the darwin/linux package scripts.

## Decisions

- **`.chezmoitemplates/brew-path.sh` + `{{ template "brew-path.sh" . }}`** over copy-pasting the prologue a third time: chezmoi's built-in include mechanism, works with `--source` in CI, zero new tooling. Alternative considered: keep three copies (rejected — the mise script already drifted once).
- **`-b "$HOME/.local/bin"` for the chezmoi installer** over `./bin/chezmoi …`: matches the CI workflow and `dot_config/shell/paths.tmpl`, which already puts `~/.local/bin` on `PATH`.
- **`zsh` via the distro package manager, not Linuxbrew**: it must exist before Homebrew does anything, and `chsh` needs a path listed in `/etc/shells`.

## Risks / Trade-offs

- [`run_once_` scripts re-run when their content changes] → both are idempotent (`command -v brew` early exit); the darwin one is already listed as `R` by `chezmoi status`.
- [Template include path typo renders an empty prologue] → CI renders every script and shellchecks it; an empty prologue makes `brew` unresolvable and the packages script exits 1 in the `else` branch.
