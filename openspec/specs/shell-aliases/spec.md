# shell-aliases Specification

## Purpose
Defines the custom aliases the managed shell provides beyond Oh My Zsh plugins, and requires that each alias targets a command or directory that exists after bootstrap.

## Requirements

### Requirement: Custom alias set
The managed `.zshrc` SHALL define exactly these custom aliases: `vim`→`nvim`, `cat`→`bat`, `grep`→`batgrep --terminal-width=200 --no-snip`, `find`→`fd`, `ls`/`ll`/`la`/`l` (eza variants), `kctx`→`kubectx`, `projects`→`cd ~/Projects`, `rec`→`asciinema rec`. The `g*`, `k*`, and `tf*` families come from Oh My Zsh plugins.

#### Scenario: Aliases resolve in a fresh shell
- **WHEN** an interactive zsh starts on a machine after `chezmoi init --apply`
- **THEN** `type kctx rec projects` report aliases and `type teaching` reports "not found"

### Requirement: No alias targets a nonexistent location
A `cd`-style alias SHALL NOT be added unless the target directory exists on every machine the repo targets, or the README documents creating it.

#### Scenario: Directory alias
- **WHEN** a new `alias name='cd <path>'` is proposed
- **THEN** `<path>` exists on the maintainer's machine or the README's bootstrap section creates it
