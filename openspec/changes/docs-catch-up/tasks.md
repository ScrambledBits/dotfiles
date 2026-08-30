## 1. CHANGELOG

- [ ] 1.1 Add `## 2026-08-29` with bullets for: `paths.tmpl` BREW_PREFIX/PATH, OMZ via `.chezmoiexternal.toml`, `[os]` module, `gitSigningKey` via `promptStringOnce`, darwin-guarded osxkeychain/macos plugin, `clipboard = unnamedplus`, hooks chaining via `git rev-parse --git-dir`, SSH kex pin removed, mas ordering + `entryState`, treesitter `main`, CI workflow, docs no longer deployed to `$HOME`; verify `head -20 CHANGELOG.md` shows the entry above 2026-07-09.

## 2. README / CLAUDE.md

- [ ] 2.1 README: add a short "Verificación (CI)" note (one paragraph, Spanish) describing the dry-run + shellcheck + Starship check on push/PR; verify `grep -n chezmoi-dry-run README.md` finds it.
- [ ] 2.2 README §"Estructura de Paquetes": change the `Brewfile.MacOS` row to "formulas macOS-específicas, apps gráficas (casks), Mac App Store, fuentes"; verify no README line claims taps in `Brewfile.MacOS`.
- [ ] 2.3 CLAUDE.md Repository Map: add `.github/workflows/chezmoi-dry-run.yml` row; verify the table renders.

## 3. Verification

- [ ] 3.1 `git diff --stat` touches only the three doc files.
