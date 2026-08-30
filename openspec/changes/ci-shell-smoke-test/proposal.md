## Why

CI renders every template and shellchecks the scripts, but never executes the rendered `.zshrc`; shellcheck cannot read zsh, so a broken alias line, a missing Oh My Zsh plugin, or a PATH regression would pass green. The audit reproduced a fresh-machine shell locally with a scratch `$HOME` in ~10 lines (audit 2026-08-30: F-4, P-1).

## What Changes

- New CI step after the dry-run: apply the source into a scratch destination (`chezmoi --config ci.toml --destination "$TMP" apply --exclude scripts`), then `zsh -n` on the rendered `.zshrc` and `paths`, then `HOME="$TMP" zsh -ic 'type gst kctx tf k'` must exit 0 with empty stderr.
- Ensure `zsh` exists on `ubuntu-latest` (`apt-get install -y zsh` if missing).

## Capabilities

### New Capabilities
- `ci-validation`: what every push/PR must prove about the rendered dotfiles on both OSes.

### Modified Capabilities
- (none)

## Impact

`.github/workflows/chezmoi-dry-run.yml` only. Adds one network fetch (the OMZ archive external) per runner. Runtime ≈ +30 s.
