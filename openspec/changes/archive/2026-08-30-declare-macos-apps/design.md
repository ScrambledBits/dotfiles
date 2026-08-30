## Context

See proposal.md. Homebrew's bundle `vscode` handler (`bundle/extensions/vscode_extension.rb`) installs the `visual-studio-code` cask itself when `code` is missing and casks are available, and raises otherwise. Linux targets are headless (Checkpoint 2, 2026-08-30).

## Goals / Non-Goals

**Goals:** every Brewfile line is honest about the platform it can succeed on; no implicit app installs.

**Non-Goals:** installing VS Code on Linux (no cask support in Linuxbrew; headless targets); reviewing which extensions to keep (see `trim-macos-brewfile`).

## Decisions

- **Move, don't filter**: moving the lines to `Brewfile.MacOS` is one cut/paste; filtering `^vscode ` in the Linux script would keep a second copy of the "what is macOS-only" rule (the darwin script already filters `^mas ` for a different reason — ordering — not platform).
- **Declare the cask rather than rely on bundle's auto-install**: a reader of `Brewfile.MacOS` should see every app the machine gets; `brew bundle dump` on the current machine lists both casks.

## Risks / Trade-offs

- [Cask entry order vs. extension install] → `brew bundle` installs casks before running `vscode` handlers only if listed first; keep the cask line above the extension block.
