## Why

The three highest-churn files (`Brewfile` 10 commits, `Brewfile.MacOS` 8, `dot_config/mise/config.toml` 11) each install tools with no rule about who owns what. Concretely: the `uv "ruff"`/`uv "mdformat"`/`uv "nano-pdf"` lines make `brew bundle` run `brew install --formula uv`, so brew's uv (0.12.5 + 0.12.6 on this machine) sits next to mise's — exactly what CHANGELOG:14 says was removed; `tap "cloudflare/cloudflare"` is dead (`cloudflared` comes from homebrew/core, nothing from the tap is installed); `brew "cairo"` is pulled in by `librsvg` anyway (audit 2026-08-30: R-1, R-2, R-10, F-1, C-1).

## What Changes

- Delete `tap "cloudflare/cloudflare"` (`Brewfile:1`).
- Delete `uv "ruff"` (`Brewfile:87`), `uv "mdformat"`, `uv "nano-pdf"` (`Brewfile.MacOS:47-48`).
- Add to `dot_config/mise/config.toml [tools]`: `ruff = "latest"`, `"pipx:mdformat" = "latest"`, `"pipx:nano-pdf" = "latest"`.
- Delete `brew "cairo"` (`Brewfile.MacOS:2`).
- Add a one-line ownership rule as a header comment in `Brewfile`, `Brewfile.MacOS`, and `dot_config/mise/config.toml`.
- Machine step (not tracked): `brew uninstall uv`.

## Capabilities

### New Capabilities
- `package-ownership`: the rule that every tool has exactly one installing manager, and the observable consequences (no brew `uv`, no dead taps, mise-managed Python tools).

### Modified Capabilities
- (none)

## Impact

- `Brewfile`, `Brewfile.MacOS`, `dot_config/mise/config.toml`, `CHANGELOG.md` (entry).
- `run_onchange_after_install-mise-tools.sh.tmpl` re-runs on the next apply (config hash changes) and installs the three tools.
- Both package scripts re-run (embedded Brewfile content changes).
