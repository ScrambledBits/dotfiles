# git-config Specification

## Purpose
Defines the platform-dependent behaviour the managed `~/.gitconfig` guarantees on macOS and Linux.

## Requirements

### Requirement: A credential helper is configured on every OS
The rendered `.gitconfig` SHALL configure `credential.helper` on both macOS (`osxkeychain`) and Linux (a helper available without extra packages), so HTTPS operations do not prompt on every call.

#### Scenario: Linux render
- **WHEN** `dot_gitconfig.tmpl` is rendered for Linux
- **THEN** it contains a `[credential]` section whose `helper` is not `osxkeychain` and `git fetch` over HTTPS prints no "is not a git command" error

#### Scenario: macOS render
- **WHEN** `dot_gitconfig.tmpl` is rendered for darwin
- **THEN** `credential.helper` is `osxkeychain`

### Requirement: GitHub credential setup is documented for Linux
The README SHALL document how to store GitHub credentials on a Linux machine using the already-installed `gh` CLI.

#### Scenario: Reader on a fresh Linux box
- **WHEN** a user reads README §"Personalización por Máquina"
- **THEN** they find `gh auth login` followed by `gh auth setup-git` as the recommended step
