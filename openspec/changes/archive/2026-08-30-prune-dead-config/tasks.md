## 1. Prompt and consumer

- [x] 1.1 Delete the `github = {{ promptStringOnce … }}` line from `.chezmoi.toml.tmpl` and `[github] user` (two lines) from `dot_gitconfig.tmpl`; verify `grep -rn '\.github' --include='*.tmpl' .` → nothing and `chezmoi execute-template < dot_gitconfig.tmpl` renders without error.
- [x] 1.2 Update CLAUDE.md's `[data]` variable list (Chezmoi Conventions) to `name`, `email`, `gitSigningKey`; verify `grep -n github CLAUDE.md` shows no data-variable claim.

## 2. Ignore list

- [x] 2.1 Replace `.chezmoiignore:12-27` with a single `.claude` line (keep the comment); verify `chezmoi unmanaged | grep -c '^\.claude'` → 0 and `chezmoi managed` is unchanged.

## 3. Verification

- [x] 3.1 CI green (the CI config already omits `github`, so its `[data]` block just loses a dead key — remove it there too, verify the dry-run step passes).
