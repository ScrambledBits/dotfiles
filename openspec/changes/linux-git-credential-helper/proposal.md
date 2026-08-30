## Why

`dot_gitconfig.tmpl` sets `credential.helper = osxkeychain` inside a darwin guard and nothing in the `else` case, so on a headless Linux box every HTTPS `git push`/`fetch` prompts for credentials, although `gh` is already installed by the shared `Brewfile` (audit 2026-08-30: P-9; Linux targets are headless per Checkpoint 2).

## What Changes

- `dot_gitconfig.tmpl`: add an `{{ else }}` branch to the credential block with `helper = cache --timeout=3600` (built into git, no daemon beyond git's own), and a README note that `gh auth login && gh auth setup-git` is the recommended way to store GitHub credentials on Linux.

## Capabilities

### New Capabilities
- `git-config`: platform-dependent git behaviour the managed `.gitconfig` guarantees.

### Modified Capabilities
- (none)

## Impact

`dot_gitconfig.tmpl:92-95`, README "Personalización por Máquina" (one paragraph). macOS unchanged.
