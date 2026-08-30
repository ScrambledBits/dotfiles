# macos-packages Specification

## Purpose
Defines which macOS-only applications a fresh Mac receives from `Brewfile.MacOS`, and keeps the shared `Brewfile` free of entries that can only succeed on macOS.

## Requirements

### Requirement: Shared Brewfile contains only cross-platform entries
The shared `Brewfile` SHALL contain no `cask`, `mas`, or `vscode` entries; every entry in it MUST be installable by Linuxbrew.

#### Scenario: Linux bundle runs clean
- **WHEN** `brew bundle install --file=-` is fed the shared `Brewfile` on a Linux box with no `code` binary
- **THEN** no entry fails with "VSCode is not installed" or "cask is unavailable on Linux"

### Requirement: VS Code and its extensions are declared on macOS
`Brewfile.MacOS` SHALL declare `cask "visual-studio-code"` before its `vscode` extension entries so the editor install is explicit rather than a side effect of `brew bundle`.

#### Scenario: Fresh Mac bundle
- **WHEN** `brew bundle` runs on a Mac without VS Code
- **THEN** VS Code is installed because of the declared cask, and every `vscode` extension entry installs afterwards

### Requirement: OrbStack is installed on macOS
`Brewfile.MacOS` SHALL declare `cask "orbstack"` so that README's "macOS exclusivo" list and the `Include ~/.orbstack/ssh/config` line in the SSH config refer to something the bootstrap installs.

#### Scenario: Fresh Mac has OrbStack
- **WHEN** `chezmoi init --apply` completes on a fresh Mac
- **THEN** `/Applications/OrbStack.app` exists and `~/.orbstack/ssh/config` is created on first launch, satisfying the SSH `Include`
