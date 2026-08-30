## Why

Two macOS apps the repo depends on are installed by accident or not at all: the 28 `vscode` extension lines in the shared `Brewfile` make `brew bundle` silently install the `visual-studio-code` cask on macOS and raise "VSCode is not installed" 28 times on Linux (Linuxbrew has no casks); OrbStack is documented (README:84,98) and referenced by `dot_ssh/config.tmpl:10` but no Brewfile installs it (audit 2026-08-30: U-4, U-5; Checkpoint 2: Linux targets are headless).

## What Changes

- Move `Brewfile:59-86` (`vscode "…"` lines) to `Brewfile.MacOS`.
- Add `cask "visual-studio-code"` and `cask "orbstack"` to `Brewfile.MacOS`.
- README §"Estructura de Paquetes": the shared `Brewfile` no longer claims VS Code extensions.

## Capabilities

### New Capabilities
- `macos-packages`: which GUI applications and editor extensions a fresh Mac gets from `Brewfile.MacOS`, and what the shared `Brewfile` must not contain.

### Modified Capabilities
- (none)

## Impact

- `Brewfile`, `Brewfile.MacOS`, `README.md:81-86`.
- `run_onchange_before_install-packages-darwin.sh.tmpl` re-runs on the next apply (its rendered content embeds both Brewfiles) — expected.
- Linux first-run loses 28 error lines; macOS gains two declared casks that were already present on the current machine.
