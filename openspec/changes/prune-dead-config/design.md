## Context

See proposal.md. chezmoi ignores dot-prefixed *source* entries automatically; `.chezmoiignore` patterns are matched against *target* paths, and a directory pattern covers everything beneath it.

## Goals / Non-Goals

**Goals:** no prompt without a consumer; no ignore line without a target.

**Non-Goals:** removing `.zshrc.local`, `.oh-my-zsh/cache`, `.oh-my-zsh/custom/**` entries (they protect real targets).

## Decisions

- **Remove the prompt rather than find a consumer for `.github`**: nothing in the workflow needs it (`gh auth` stores its own identity).
- **One `.claude` line**: identical behaviour for `add`/`unmanaged`; 14 lines fewer to read.

## Risks / Trade-offs

- [Some tool reads `github.user` from git config] → `inferred` risk; re-adding is two lines and the value is in `gh auth status`.
