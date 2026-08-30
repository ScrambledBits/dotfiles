## 1. Template

- [ ] 1.1 Add `{{ else }}` with `[credential]\n    helper = cache --timeout=3600` to the darwin credential block in `dot_gitconfig.tmpl`; verify the CI linux render (`chezmoi execute-template` on ubuntu) contains `helper = cache` and the darwin render still contains `osxkeychain`.

## 2. Docs

- [ ] 2.1 README "Personalización por Máquina": add a short Spanish paragraph "Credenciales de GitHub en Linux" with `gh auth login` + `gh auth setup-git`; verify `grep -n 'setup-git' README.md`.

## 3. Verification

- [ ] 3.1 On a Linux box after apply: `git config --get credential.helper` → `cache --timeout=3600`; an HTTPS `git fetch` prompts once, then not again within the hour.
