# linux-bootstrap Specification

## Purpose
Defines what a fresh Linux machine must end up with after a user follows README §"Máquina nueva — Linux" verbatim and `chezmoi init --apply` completes.

## Requirements

### Requirement: chezmoi is runnable after the documented install step
The README Linux instructions SHALL install `chezmoi` to a directory that is on `PATH` for the rest of the session, so the very next documented command (`chezmoi init --apply …`) resolves.

#### Scenario: Fresh Ubuntu container follows the README verbatim
- **WHEN** a user runs README §Linux steps 1-3 in order on a fresh Debian/Ubuntu, Fedora, or Arch box
- **THEN** step 3 executes `chezmoi init --apply` without a "command not found" error

### Requirement: mise tools are installed on the first apply without Homebrew on the caller's PATH
The `run_onchange` mise-tools script SHALL locate `mise` under the standard Homebrew prefixes (`/opt/homebrew`, `/usr/local`, `/home/linuxbrew/.linuxbrew`, `$HOME/.linuxbrew`) even when the invoking shell has not put Homebrew on `PATH`.

#### Scenario: First apply on Linux
- **WHEN** `chezmoi init --apply` runs on a fresh Linux box where Homebrew was installed by the preceding `run_once` script and the user's shell has not sourced `brew shellenv`
- **THEN** the mise-tools script runs `mise install` and every tool in `dot_config/mise/config.toml` is installed
- **AND** the script does not print the "mise not found" warning

#### Scenario: mise genuinely absent
- **WHEN** `mise` is not installed under any standard prefix nor on `PATH`
- **THEN** the script prints the warning naming `brew install mise` and exits 0 (apply continues)

### Requirement: zsh is present after bootstrap
The Linux Homebrew bootstrap SHALL install `zsh` alongside its build dependencies on apt, dnf, and pacman systems, and the README SHALL document the login-shell switch as a manual step.

#### Scenario: Fresh Debian without zsh
- **WHEN** the bootstrap script runs on a box whose package manager is apt/dnf/pacman and `zsh` is not installed
- **THEN** `command -v zsh` succeeds after the script finishes

#### Scenario: Login shell switch is documented, not automated
- **WHEN** a user reads README §Linux
- **THEN** it shows `chsh -s "$(command -v zsh)"` as an explicit manual step after `chezmoi init --apply`

### Requirement: Homebrew PATH prologue exists once in the source
All `run_*` scripts that invoke Homebrew-installed binaries SHALL obtain the Homebrew prefix from a single shared chezmoi template rather than per-script copies.

#### Scenario: Rendered scripts agree
- **WHEN** the darwin packages, linux packages, and mise-tools scripts are rendered with `chezmoi execute-template`
- **THEN** each contains the same prefix-detection block and the source tree contains that block in exactly one file under `.chezmoitemplates/`
