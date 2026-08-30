## Context

See proposal.md. Starship 1.26 drops unknown colour names without warning (`starship module character` with `(bold orange)` emits no escape codes). Nerd Fonts v3 moved icons out of the CJK block; the Ghostty font is Hurmit Nerd Font (v3 cask). `rec`, `asciinema`, `vhs`, `agg` have zero history uses too, but the owner chose to keep them.

## Goals / Non-Goals

**Goals:** every prompt entry does what it looks like it does; no alias into a missing directory.

**Non-Goals:** restyling the prompt; adding new modules; re-litigating `rec`/`agg`.

## Decisions

- **`"bold 208"`** for rust: closest 256-colour orange; a hex value would also work but the file uses named/indexed colours elsewhere.
- **`"» "` for renamed** over hunting the exact NF v3 glyph: renders in every font; swap for a glyph later if wanted.
- **Delete the `~/Projects/dotfiles` substitution** rather than repoint it: no single path is right on every machine (assumption A-1, audit 2026-08-30).

## Risks / Trade-offs

- [Removing README §Docencia loses the `agg` usage example] → keep the one-line "Docencia" bullet in §"Qué Incluye"; the example was three commands.
