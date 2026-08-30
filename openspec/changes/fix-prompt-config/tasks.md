## 1. Starship

- [x] 1.1 Set `[rust] style = "bold 208"` in `dot_config/starship.toml`; verify `cd "$(mktemp -d)" && touch Cargo.toml && STARSHIP_CONFIG=<repo>/dot_config/starship.toml starship module rust | od -c` shows an `033 [` sequence.
- [x] 1.2 Replace `renamed = "襁 "` with `renamed = "» "`; verify `python3 -c` scan of the file finds no codepoint in U+4E00–U+9FFF.
- [x] 1.3 Delete the `"~/Projects/dotfiles"` and `"~/Projects/teaching"` lines under `[directory.substitutions]`; verify `STARSHIP_CONFIG=… starship print-config` emits no warnings.

## 2. Shell and docs

- [x] 2.1 Delete `alias teaching='cd ~/Projects/teaching'` from `dot_zshrc.tmpl`; verify a fresh `zsh -ic 'type teaching'` prints "not found" and `type kctx rec projects` still resolve.
- [x] 2.2 README: remove the `teaching` row from "Alias Principales" and the whole §"Flujo de Trabajo de Docencia"; verify `grep -n teaching README.md` → nothing and the file stays in Spanish.
- [x] 2.3 CLAUDE.md Aliases Reference: drop `teaching`; verify `grep -n teaching CLAUDE.md` → nothing.

## 3. Verification

- [ ] 3.1 CI green (Starship validation step) and `chezmoi diff` shows only the intended lines.
