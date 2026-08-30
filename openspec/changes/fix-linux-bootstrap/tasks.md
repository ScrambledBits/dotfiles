## 1. Shared Homebrew prologue

- [x] 1.1 Create `.chezmoitemplates/brew-path.sh` containing the prefix-detection block from `run_onchange_before_install-packages-darwin.sh.tmpl:6-14` generalised for both OSes (`/opt/homebrew`, `/usr/local`, `/home/linuxbrew/.linuxbrew`, `$HOME/.linuxbrew`); verify with `chezmoi execute-template '{{ template "brew-path.sh" . }}'` printing the block.
- [x] 1.2 Replace the inline prologue in `run_onchange_before_install-packages-darwin.sh.tmpl` and `…-linux.sh.tmpl` with `{{ template "brew-path.sh" . }}`; verify `chezmoi execute-template < <file>` renders the same block as before and `shellcheck` passes on the rendered output.
- [x] 1.3 Add `{{ template "brew-path.sh" . }}` to `run_onchange_after_install-mise-tools.sh.tmpl` before `command -v mise`; verify by rendering with `PATH=/usr/bin:/bin` that the rendered script finds `mise` under the Homebrew prefix.

## 2. Linux bootstrap script

- [x] 2.1 Add `zsh` to the apt, dnf, and pacman install lines in `run_once_before_install-homebrew-linux.sh.tmpl`; verify the rendered script contains `zsh` on all three lines and shellcheck is clean.

## 3. README (Spanish)

- [x] 3.1 Rewrite §"Máquina nueva — Linux" step 1 to `curl git zsh` per distro and step 2 to `sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"` followed by `export PATH="$HOME/.local/bin:$PATH"`; verify by copy-pasting the block into a fresh `ubuntu:24.04` container and reaching `chezmoi init --apply`.
- [x] 3.2 Add a step after `chezmoi init --apply`: `chsh -s "$(command -v zsh)"` with a one-line note that it is manual; verify the README renders and `README.md` stays in Spanish.

## 4. Verification

- [ ] 4.1 CI (`.github/workflows/chezmoi-dry-run.yml`) green on ubuntu-latest and macos-latest after the change (`gh run list --limit 1`).
- [ ] 4.2 Fresh `ubuntu:24.04` container walkthrough of README §Linux ends with `zsh` installed and `mise ls` listing every tool from `config.toml`; record the result in the CHANGELOG entry.
