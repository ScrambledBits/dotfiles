# zsh-configuration Specification

## Purpose
Defines which Oh My Zsh plugins the managed shell loads and the evidence rule for adding or keeping one, so the plugin list stays tied to actual use.

## Requirements

### Requirement: Plugin set
The managed `.zshrc` SHALL enable exactly these Oh My Zsh plugins: `alias-finder`, `colored-man-pages`, `docker`, `git`, `git-extras`, `kubectl`, `man`, `mise`, `terraform`, plus `macos` on darwin only.

#### Scenario: Fresh shell on macOS
- **WHEN** an interactive zsh starts after `chezmoi apply` on macOS
- **THEN** `echo $plugins` lists exactly the ten names above and `type gst k tf` resolve

#### Scenario: Fresh shell on Linux
- **WHEN** an interactive zsh starts after `chezmoi apply` on Linux
- **THEN** `echo $plugins` lists the nine cross-platform names and does not include `macos`

### Requirement: Plugins earn their place
A plugin SHALL be kept or added only if a command or completion it provides has been used, as evidenced by `~/.zsh_history` or a stated need in the change that adds it.

#### Scenario: Plugin with no observed use
- **WHEN** an audit finds a plugin whose commands have zero history entries over the retained history window
- **THEN** the plugin is removed unless the owner records a reason to keep it in the change proposal

### Requirement: Rendered plugin list is well-formed
The rendered `plugins=(…)` block SHALL keep uniform four-space indentation on every OS.

#### Scenario: Render for darwin and linux
- **WHEN** `dot_zshrc.tmpl` is rendered for each OS
- **THEN** every plugin line inside `plugins=(` starts with four spaces
