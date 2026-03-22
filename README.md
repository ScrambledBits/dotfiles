# Emilio Castro's Dotfiles

Senior Cloud & DevOps Engineer configuration managed by [chezmoi](https://www.chezmoi.io/).

## Quick Start

```bash
# Install chezmoi
brew install chezmoi

# Initialize from this repo
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git

# Or apply changes after editing
chezmoi apply
```

## What's Included

- **Shell:** zsh with Oh My Zsh, Starship prompt, mise, direnv
- **Cloud:** GCP, AWS, Azure tooling with context-aware prompts
- **Kubernetes:** k9s, kubectx, stern, kube-ps1 integration
- **IaC:** Terraform, Terragrunt, TFLint, Checkov, Trivy
- **Development:** Neovim, delta (git diffs), lazygit
- **Teaching:** asciinema, vhs, slides, d2 (diagrams)

## Key Aliases

| Alias | Command |
|-------|---------|
| `tf` | terraform |
| `k` | kubectl |
| `kctx` | kubectx |
| `projects` | cd ~/Projects |
| `teaching` | cd ~/Projects/teaching |
| `rec` | asciinema rec |

## Local Overrides

Create `~/.zshrc.local` for machine-specific settings (not in git).

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
