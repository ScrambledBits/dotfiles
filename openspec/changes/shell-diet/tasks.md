## 1. .zshrc

- [ ] 1.1 Remove `ansible`, `docker-compose`, `gitignore`, `aliases`, `history`, `brew`, `macos`-unrelated dead entries from `plugins=(…)` in `dot_zshrc.tmpl` (keep `macos` inside its darwin guard); verify the rendered darwin list has 10 entries and linux has 9 (`chezmoi execute-template < dot_zshrc.tmpl | sed -n '/^plugins=(/,/^)/p'`).
- [ ] 1.2 Change the guard to `{{- if eq .chezmoi.os "darwin" }}` … `{{- end }}`; verify every rendered plugin line starts with four spaces on both OS renders (CI renders linux).
- [ ] 1.3 Delete `DISABLE_UNTRACKED_FILES_DIRTY="true"`; verify `zsh -ic true` still prints nothing and `type gst` resolves.

## 2. .gitconfig

- [ ] 2.1 Replace the `[alias]` block in `dot_gitconfig.tmpl` with only `undo = reset --soft HEAD~1` and `amend = commit --amend --no-edit`; verify `git config --get-regexp '^alias\.'` after apply lists exactly two entries.

## 3. Docs

- [ ] 3.1 Update CLAUDE.md Aliases Reference and README "Neovim y git" sentence to name only `undo`/`amend`; verify `grep -n 'review\|files' README.md CLAUDE.md` finds no alias claims.

## 4. Verification

- [ ] 4.1 CI green; `HOME=<scratch> zsh -ic 'type gst k tf kctx'` resolves after a scratch apply.
