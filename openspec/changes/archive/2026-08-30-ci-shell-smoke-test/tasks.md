## 1. Workflow

- [x] 1.1 Add a step "Apply into scratch HOME" using `chezmoi --config "$HOME/.config/chezmoi/chezmoi.toml" --source "$GITHUB_WORKSPACE" --destination "$RUNNER_TEMP/home" --cache "$RUNNER_TEMP/cache" --persistent-state "$RUNNER_TEMP/state.boltdb" --no-tty apply --exclude scripts`; verify `ls "$RUNNER_TEMP/home"` shows `.zshrc`, `.oh-my-zsh`, `.config`.
- [x] 1.2 Add `zsh -n "$RUNNER_TEMP/home/.zshrc" && zsh -n "$RUNNER_TEMP/home/.config/shell/paths"`; verify by temporarily injecting a syntax error in a branch that the step fails.
- [x] 1.3 Add the interactive check under a real pty (Python `pty.fork`), asserting exit 0 and no unresolved alias for `type gst kctx tf rec projects` (`k` excluded: the OMZ `kubectl` plugin no-ops without the `kubectl` binary, which this scriptless scratch apply never installs — found live on the macOS CI run, fixed here); verify the step passes on both runners.
- [x] 1.4 Add `if ! command -v zsh; then sudo apt-get install -y zsh; fi` guarded by `runner.os == 'Linux'`; verify the ubuntu job passes.

## 2. Verification

- [x] 2.1 `gh run list --limit 2` shows both matrix jobs green; total job time under 2 minutes.
