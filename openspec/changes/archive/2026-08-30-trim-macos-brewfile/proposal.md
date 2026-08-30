## Why

`Brewfile.MacOS` carries entries with no recorded use and no stated reason. Shell history over 20 months: `ollama` 37, `watson` 6, `llmfit` 2, `openai-whisper` 1, `rabbitmq` 0, `cocoapods`/`pod` 0, `tectonic` 0, `aws-vault` 0 (README:98 still advertises it); `poppler` has no installed dependents; three DB GUIs and 14 Nerd Font casks (Ghostty uses one, `config.ghostty:1`) are GUI-side and invisible to history (audit 2026-08-30: R-10; Checkpoint 2 2026-08-28: trim candidates may be listed for per-item review).

## What Changes

- Per-line keep/cut decision recorded in `CHANGELOG.md`; cut lines deleted from `Brewfile.MacOS`.
- If `aws-vault` is cut, remove it from README:98.
- `cocoapods` moves to the flutter machine's local setup (documented in README "Herramientas de mise locales" as an example, or simply removed).
- Removing a line never uninstalls anything (no `brew bundle cleanup` runs).

## Capabilities

### New Capabilities
- (none — package selection is owner preference, not behaviour; `skip_specs: true`)

### Modified Capabilities
- (none)

## Impact

`Brewfile.MacOS`, `README.md:98`, `CHANGELOG.md`. The darwin packages script re-runs on the next apply (embedded content changes) — expected, fast.
