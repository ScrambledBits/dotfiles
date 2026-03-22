# Emilio Castro's Dotfiles

Senior Cloud & DevOps Engineer configuration managed by [chezmoi](https://www.chezmoi.io/).

## Quick Start

```bash
# Install chezmoi
brew install chezmoi

# Initialize from this repo
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git

# Install all managed tool versions
mise install

# Or apply changes after editing
chezmoi apply
```

## What's Included

- **Shell:** zsh with Oh My Zsh, Starship prompt, mise, direnv, zsh-autosuggestions, fast-syntax-highlighting
- **Cloud:** GCP, AWS, Azure tooling with context-aware prompts
- **Kubernetes:** k9s, kubectx, stern integration
- **IaC:** Terraform 1.14 (or OpenTofu as alternative), Terragrunt, TFLint, Checkov, Trivy
- **Development:** Neovim, delta (git diffs), lazygit, fd, bat, eza, ripgrep, fzf, zoxide
- **Teaching:** asciinema, vhs, slides, d2 (diagrams)

## Managed Tool Versions (mise)

| Tool | Version |
|------|---------|
| Python | 3.13 |
| Node.js | 24 (Active LTS) |
| Go | 1.26 |
| Terraform | 1.14.7 |
| Terragrunt | 0.99 |
| TFLint | 0.61 |
| Poetry | 2.3 |
| Ruff | 0.15 |

> **Note:** Terraform uses HashiCorp's BSL license. [OpenTofu](https://opentofu.org/) (MPL 2.0) is a compatible alternative — see `dot_config/mise/config.toml` for the commented-out switch.

## Key Aliases

| Alias | Command |
|-------|---------|
| `tf` | terraform |
| `k` | kubectl |
| `kctx` | kubectx |
| `cat` | bat |
| `find` | fd |
| `projects` | cd ~/Projects |
| `teaching` | cd ~/Projects/teaching |
| `rec` | asciinema rec |

## Local Overrides

Create `~/.zshrc.local` for machine-specific settings (not in git).

For machine-specific chezmoi data (e.g. SSH signing key), create `~/.chezmoidata/local.toml`:
```toml
[data]
gitSigningKey = "key::ssh-ed25519 AAAA..."
```

## Git Commit Signing (optional)

To enable SSH-based commit signing (no GPG needed):

1. Set `gitSigningKey` in `~/.chezmoidata/local.toml` with your Ed25519 public key
2. Run `chezmoi apply` to regenerate `~/.gitconfig`
3. Create `~/.ssh/allowed_signers`:
   ```
   your@email.com ssh-ed25519 AAAA...
   ```

## Teaching Workflow

```bash
# Navigate to teaching materials
teaching

# Start recording terminal session for students
rec workshop-demo.cast

# Convert to GIF for documentation
agg workshop-demo.cast workshop-demo.gif
```

## Credits

- [chezmoi](https://www.chezmoi.io/) for dotfile management
- [mise](https://mise.jdx.dev/) for version management
- [Starship](https://starship.rs/) for the prompt
