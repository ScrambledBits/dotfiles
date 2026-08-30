## Purpose

Defines observable correctness rules for the Starship prompt configuration so that misconfigurations that Starship ignores silently are caught by review.

## ADDED Requirements

### Requirement: Every module style renders
Every `style` value in `dot_config/starship.toml` SHALL use a colour Starship recognises (the eight named colours, a 0-255 index, or a hex value), so that the styled output contains an SGR escape sequence.

#### Scenario: Rust module in a Cargo project
- **WHEN** `starship module rust` runs in a directory containing `Cargo.toml` with the repo config
- **THEN** the output contains an SGR sequence (`\e[…m`), not bare text

### Requirement: Status glyphs are icons, not CJK text
Every symbol in `[git_status]` SHALL be a glyph from the Nerd Fonts v3 ranges or plain ASCII/Unicode punctuation; no symbol may fall in the CJK Unified Ideographs block (U+4E00–U+9FFF).

#### Scenario: Renamed file indicator
- **WHEN** a repo has a staged rename and the prompt renders `$git_status`
- **THEN** the renamed indicator displays as an icon or `»`, not as the character 襁

### Requirement: Directory substitutions can match
Every entry in `[directory.substitutions]` SHALL name a path that exists on at least one target machine's standard layout.

#### Scenario: Dotfiles source directory
- **WHEN** the prompt renders inside the chezmoi source directory (`chezmoi source-path`) on this machine or a fresh one (`~/.local/share/chezmoi`)
- **THEN** no substitution for a `~/Projects/dotfiles` path is defined, because that path is not where the source lives
