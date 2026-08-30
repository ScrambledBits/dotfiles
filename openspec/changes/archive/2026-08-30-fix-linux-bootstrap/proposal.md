## Why

README's Linux quick start cannot be followed to the end on a fresh headless box: `get.chezmoi.io` installs to `./bin`, so step 3 (`chezmoi init`) is "command not found"; past that, the first apply leaves no `zsh` and never runs `mise install` because the mise script cannot find `mise` without Homebrew on chezmoi's PATH (audit 2026-08-30: U-1, U-2, U-3, R-12, F-2).

## What Changes

- README §"Máquina nueva — Linux": install chezmoi with `-b "$HOME/.local/bin"` and put that dir on `PATH` (same form the CI workflow already uses); trim step 1 to the packages the bootstrap script does not install itself (`curl git zsh`); document `chsh -s "$(command -v zsh)"`.
- `run_once_before_install-homebrew-linux.sh.tmpl`: add `zsh` to the apt/dnf/pacman dependency lines.
- Extract the "put Homebrew on PATH" prologue duplicated in both package scripts into `.chezmoitemplates/brew-path.sh` and include it from the two package scripts **and** `run_onchange_after_install-mise-tools.sh.tmpl`, which currently lacks it.
- The OS-split package scripts stay separate (panel decision 2026-08-28); only the prologue is shared.

## Capabilities

### New Capabilities
- `linux-bootstrap`: what a fresh Linux machine must end up with after following README §Linux and running `chezmoi init --apply`.

### Modified Capabilities
- (none — no main specs exist yet)

## Impact

- `README.md` (Linux section), `run_once_before_install-homebrew-linux.sh.tmpl`, `run_onchange_before_install-packages-{darwin,linux}.sh.tmpl`, `run_onchange_after_install-mise-tools.sh.tmpl`, new `.chezmoitemplates/brew-path.sh`.
- macOS behaviour unchanged (README macOS steps already `eval "$(brew shellenv)"`).
- CI already renders every `run_*` script with `chezmoi execute-template --source`, which resolves `.chezmoitemplates` includes.
