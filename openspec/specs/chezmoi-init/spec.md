# chezmoi-init Specification

## Purpose
Defines the per-machine values `chezmoi init` asks for, so every prompt corresponds to something a template renders.

## Requirements

### Requirement: Every prompted value is consumed
`.chezmoi.toml.tmpl` SHALL prompt only for values referenced by at least one template: `name`, `email`, and `gitSigningKey`.

#### Scenario: Fresh init
- **WHEN** `chezmoi init` runs on a new machine
- **THEN** it prompts for Full Name, Email address, and SSH signing key (blank to skip), and nothing else

#### Scenario: Template references
- **WHEN** the source templates are searched for `.name`, `.email`, `.gitSigningKey`
- **THEN** each is found in at least one `*.tmpl`, and no template references a `.github` data key

### Requirement: Ignore list is minimal
`.chezmoiignore` SHALL express "nothing under `~/.claude` is managed" with a single `.claude` entry.

#### Scenario: Claude runtime files stay unmanaged
- **WHEN** `chezmoi add ~/.claude/settings.json` or `chezmoi unmanaged` runs
- **THEN** the path is reported as ignored and does not enter the source
