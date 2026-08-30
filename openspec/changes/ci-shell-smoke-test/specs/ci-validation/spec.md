## Purpose

Defines what continuous integration must prove about the rendered dotfiles on every push and pull request, on both macOS and Linux runners.

## ADDED Requirements

### Requirement: Rendered shell starts cleanly
CI SHALL apply the source state into a scratch home directory (scripts excluded, externals included) and start an interactive zsh from it; the start MUST exit 0 and print nothing to stderr.

#### Scenario: Interactive start on both runners
- **WHEN** the workflow runs on `ubuntu-latest` and `macos-latest`
- **THEN** `HOME="$TMP" zsh -ic 'true'` exits 0 with empty stderr on each

### Requirement: Managed aliases resolve
CI SHALL assert that the custom aliases the README documents resolve in the scratch shell. Aliases defined by an Oh My Zsh plugin that guards itself behind a binary's presence (e.g. the `kubectl` plugin's `k`, which no-ops without `commands[kubectl]`) are exempt, since this scratch apply deliberately excludes package-install scripts (`--exclude scripts`) and never installs that binary.

#### Scenario: Alias check
- **WHEN** `HOME="$TMP" zsh -ic 'type gst kctx tf rec projects'` runs
- **THEN** every name reports an alias and the command exits 0

### Requirement: Rendered zsh files are syntactically valid
CI SHALL run `zsh -n` on the rendered `.zshrc` and `.config/shell/paths`.

#### Scenario: Syntax error introduced
- **WHEN** a template change renders an unbalanced quote into `.zshrc`
- **THEN** the workflow fails at the `zsh -n` step before the interactive start
