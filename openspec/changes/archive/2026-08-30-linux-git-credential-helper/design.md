## Context

See proposal.md. Options on Linux: `cache` (built in, in-memory, timed), `store` (plaintext file — no), `libsecret` (needs a package and a desktop keyring — headless targets), `gh auth setup-git` (uses `gh` as the helper; already installed).

## Goals / Non-Goals

**Goals:** no repeated prompts on headless Linux; no plaintext secrets.

**Non-Goals:** keyring integration; changing macOS behaviour.

## Decisions

- **`cache --timeout=3600` as the rendered default** because it needs nothing installed and never writes secrets to disk; **`gh auth setup-git` documented** because it is the better experience for GitHub specifically and `gh` writes `credential.helper` for `github.com` only, coexisting with `cache`.

## Risks / Trade-offs

- [`gh auth setup-git` edits `~/.gitconfig`, which chezmoi manages] → it adds host-scoped `[credential "https://github.com"]` entries; `chezmoi diff` will show them as drift. Alternative: run it with `--hostname` and accept, or add the same block to the template under the linux branch. Decide at implementation; record in the CHANGELOG.
