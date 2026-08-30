## 1. Brewfiles

- [ ] 1.1 Cut `vscode "…"` lines (`Brewfile:59-86`) and paste them into `Brewfile.MacOS` under a `cask "visual-studio-code"` line; verify `grep -c '^vscode ' Brewfile` → 0 and `grep -c '^vscode ' Brewfile.MacOS` → 28.
- [ ] 1.2 Add `cask "orbstack"` to `Brewfile.MacOS` next to the other casks; verify `brew bundle check --file=Brewfile.MacOS` reports both casks as satisfied on this machine.

## 2. Docs

- [ ] 2.1 Update README §"Estructura de Paquetes" so `Brewfile` = "CLI DevOps" and `Brewfile.MacOS` = "casks (incl. VS Code + extensiones, OrbStack), Mac App Store, fuentes"; verify the table matches `grep -E '^(cask|vscode|mas) '` counts per file.

## 3. Verification

- [ ] 3.1 `printf '%s\n' "$(cat Brewfile)" | brew bundle check --file=-` on macOS lists no `vscode` entries; CI green on both runners.
