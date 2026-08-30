## Context

See proposal.md. The existing workflow already writes a CI chezmoi config (`chezmoi.toml` with `[data]`) and uses `--source "$GITHUB_WORKSPACE"`. chezmoi accepts `--destination`, `--cache`, and `--persistent-state` flags, so the scratch apply touches nothing outside `$TMP`. The OMZ external downloads `master.tar.gz` (~10 MB).

## Goals / Non-Goals

**Goals:** catch shell-level regressions on both OSes with no new tooling.

**Non-Goals:** running `run_*` scripts in CI (Homebrew installs); testing mise tool installs; measuring startup time.

## Decisions

- **Scratch `$HOME` + `zsh -ic`** over `zsh -n` alone: `-n` proves syntax, not that OMZ loads or aliases exist. Both are used, `-n` first for a cheaper failure.
- **`--exclude scripts`** so Homebrew is never invoked on the runner; externals stay included because the OMZ fetch is the thing most likely to break silently.
- **stderr must be empty** rather than "exit 0": `command not found` from an unguarded eval exits 0 in `.zshrc`.

## Risks / Trade-offs

- [pty vs. non-tty: `zsh -ic` without a tty prints `can't change option: zle`] → run under `script -q /dev/null zsh -ic …` on macOS and `script -qc … /dev/null` on Linux, or filter that one known line; pick whichever keeps the step readable.
- [OMZ master moves] → same exposure the real machines have; a red CI here is information.
