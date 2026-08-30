## 1. Brewfiles

- [x] 1.1 Delete `tap "cloudflare/cloudflare"` from `Brewfile`; verify `brew bundle check --file=Brewfile` still resolves `cloudflared` (`brew info cloudflared` → `homebrew/core`).
- [x] 1.2 Delete the three `uv "…"` lines from `Brewfile` and `Brewfile.MacOS`; verify `grep -c '^uv ' Brewfile Brewfile.MacOS` → 0 for both.
- [x] 1.3 Delete `brew "cairo"` from `Brewfile.MacOS`; verify `brew deps librsvg | grep -x cairo` prints `cairo`.
- [x] 1.4 Add the ownership rule as the first comment line of `Brewfile`, `Brewfile.MacOS`, and `dot_config/mise/config.toml` ("mise owns registry/dev tools; brew owns system packages, casks, fonts"); verify with `head -2` on each file.

## 2. mise

- [x] 2.1 Add `ruff = "latest"`, `"pipx:mdformat" = "latest"`, `"pipx:nano-pdf" = "latest"` under `[tools]` in `dot_config/mise/config.toml`; verify `mise install` succeeds and `mise ls` attributes all three to `config.toml`.
- [x] 2.2 Confirm `command -v ruff mdformat nano-pdf` resolve to mise-managed paths after `chezmoi apply` (the mise-tools script re-runs on the config hash change).

## 3. Machine cleanup (not tracked)

- [x] 3.1 `brew uninstall uv` on this machine; verify `brew list uv` fails and `uv --version` still works (mise's uv).

## 4. Verification

- [x] 4.1 CI green; CHANGELOG entry lists the removed lines and the ownership rule.
