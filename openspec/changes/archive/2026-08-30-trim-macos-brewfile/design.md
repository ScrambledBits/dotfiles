## Context

See proposal.md. `cairo` is handled in `consolidate-package-ownership` (dependency of `librsvg`). History counts are lower bounds (`hist_ignore_all_dups`); GUI apps (casks) leave no shell trace, so their decisions rest on the owner's memory.

## Goals / Non-Goals

**Goals:** every `Brewfile.MacOS` line has either recorded use or a recorded reason.

**Non-Goals:** uninstalling anything from the current machine; touching the shared `Brewfile` (its entries are all CLI tools with a DevOps rationale).

## Decisions

- **Recommendations, not cuts, for GUI casks**: the audit has no signal on them.
- **Fonts**: keep `font-hurmit-nerd-font` (in use); the other 13 are candidates — keeping a second font "just in case" is fine if named.

## Risks / Trade-offs

- [Cutting a formula another workflow needs on a *different* machine] → history is from this machine only; the owner review is the mitigation.
