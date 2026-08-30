## Why

Four prompt/alias entries are wrong in ways nothing reports: `[rust] style = "bold orange"` is not a Starship colour, so the module renders with no style at all; `git_status.renamed = "襁 "` is U+8941, a CJK ideograph left over from Nerd Fonts v2; the `~/Projects/dotfiles` directory substitution can never match (source is `~/Projects/dotfiles_test` here and `~/.local/share/chezmoi` on a fresh machine); the `teaching` alias and its substitution point at `~/Projects/teaching`, which does not exist (audit 2026-08-30: U-7, R-5, R-6, U-6; Checkpoint 2: drop `teaching`).

## What Changes

- `dot_config/starship.toml`: `[rust] style = "bold 208"`; replace `renamed` glyph with `"» "` (or a Nerd Fonts v3 glyph); delete the `~/Projects/dotfiles` and `~/Projects/teaching` substitutions.
- `dot_zshrc.tmpl`: delete `alias teaching=…`. Keep `rec`, `projects`, `kctx`.
- `README.md`: delete the `teaching` row in "Alias Principales" and the §"Flujo de Trabajo de Docencia" section (its commands `rec`/`agg` remain available and documented in the aliases table / "Docencia" bullet).
- `CLAUDE.md` Aliases Reference: drop `teaching`.

## Capabilities

### New Capabilities
- `starship-prompt`: observable prompt behaviour — every configured style renders, every glyph is a real icon, every directory substitution can match on some machine.
- `shell-aliases`: the set of custom aliases the shell defines and the rule that each targets something that exists.

### Modified Capabilities
- (none)

## Impact

- `dot_config/starship.toml:45-46,67,115`, `dot_zshrc.tmpl:122`, `README.md:126,207-218`, `CLAUDE.md` aliases list.
- No behaviour change for `rec`/`agg` users.
