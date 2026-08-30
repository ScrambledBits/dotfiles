# package-ownership Specification

## Purpose
Guarantees that every tool installed by the tracked files has exactly one installing manager, so adding a line to one file never causes a second manager to appear on the machine.

## Requirements

### Requirement: One installing manager per tool
For any tool, the tracked files (`Brewfile`, `Brewfile.MacOS`, `dot_config/mise/config.toml`) SHALL name at most one manager that installs it. Tools available in the mise registry that are versioned or run as developer tools MUST be declared in mise; system packages, casks, and fonts MUST be declared in a Brewfile.

#### Scenario: uv is installed once
- **WHEN** `chezmoi init --apply` completes on a fresh Mac or Linux box
- **THEN** `mise ls uv` shows uv from `config.toml`
- **AND** `brew list uv` reports it is not installed

#### Scenario: Python CLI tools come from mise
- **WHEN** `mise install` has run
- **THEN** `ruff`, `mdformat`, and `nano-pdf` resolve on `PATH` and `mise ls` attributes each of them to `~/.config/mise/config.toml`
- **AND** no Brewfile contains a `uv "…"` entry

### Requirement: No dead taps
Every `tap` entry in a Brewfile SHALL be the source of at least one `brew` entry in the same set of Brewfiles.

#### Scenario: cloudflared without the vendor tap
- **WHEN** `brew bundle` runs with the shared `Brewfile`
- **THEN** `cloudflared` installs from `homebrew/core` and no `cloudflare/cloudflare` tap is added

### Requirement: No redundant explicit dependencies
A Brewfile SHALL NOT list a formula that is already a mandatory dependency of another listed formula, unless a comment states why it is pinned explicitly.

#### Scenario: cairo via librsvg
- **WHEN** `brew bundle` runs with both Brewfiles on macOS
- **THEN** `cairo` is present as a dependency of `librsvg` without an explicit `brew "cairo"` line
