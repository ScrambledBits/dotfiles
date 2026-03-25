# Dotfiles de Emilio Castro

Configuración de Senior Cloud & DevOps Engineer gestionada por [chezmoi](https://www.chezmoi.io/).

## Inicio Rápido

### Máquina nueva

```bash
# 1. Instalar chezmoi (única dependencia inicial)
brew install chezmoi

# 2. Inicializar y aplicar todo en un solo paso
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git

# Durante la inicialización se te pedirá:
# - Nombre completo
# - Correo electrónico
# - Usuario de GitHub
# - Zona horaria (ej. America/Mexico_City)
# ¡Esto mantiene tu información personal fuera del repositorio!
```

Esto hará automáticamente:
1. Instala Homebrew si no está presente
2. Ejecuta `brew bundle` para instalar todos los paquetes del `Brewfile`
3. Aplica todos los dotfiles en `~`

> **Nota sobre App Store:** Si las apps de `mas` no se instalan, inicia sesión en la App Store y vuelve a ejecutar `chezmoi apply`.

### Máquina existente (ya inicializada)

```bash
# Aplicar cambios (incluyendo nuevos paquetes en Brewfile)
chezmoi apply

# Instalar versiones de herramientas definidas en mise
mise install
```

Cada vez que modifiques el `Brewfile` y ejecutes `chezmoi apply`, se correrá `brew bundle` automáticamente.

## Qué Incluye

- **Shell:** zsh con Oh My Zsh, prompt de Starship, mise, direnv, zsh-autosuggestions, fast-syntax-highlighting
- **Cloud:** Herramientas para GCP, AWS, Azure con prompts conscientes del contexto
- **Kubernetes:** k9s, kubectx, integración con stern
- **IaC:** Terraform 1.14 (u OpenTofu como alternativa), Terragrunt, TFLint, Checkov, Trivy
- **Desarrollo:** Neovim, delta (para diffs de git), lazygit, fd, bat, eza, ripgrep, fzf, zoxide
- **Docencia:** asciinema, vhs, slides, d2 (diagramas)

## Versiones de Herramientas Gestionadas (mise)

| Herramienta | Versión |
|------|---------|
| Python | 3.13 |
| Node.js | 24 (Active LTS) |
| Go | 1.26 |
| Terraform | 1.14.7 |
| Terragrunt | 0.99 |
| TFLint | 0.61 |
| Poetry | 2.3 |
| Ruff | 0.15 |

> **Nota:** Terraform utiliza la licencia BSL de HashiCorp. [OpenTofu](https://opentofu.org/) (MPL 2.0) es una alternativa compatible — revisa `dot_config/mise/config.toml` para ver cómo alternar (comentado).

## Alias Principales

| Alias | Comando |
|-------|---------|
| `tf` | terraform |
| `k` | kubectl |
| `kctx` | kubectx |
| `cat` | bat |
| `find` | fd |
| `projects` | cd ~/Projects |
| `teaching` | cd ~/Projects/teaching |
| `rec` | asciinema rec |

## Sobrescrituras Locales

Crea `~/.zshrc.local` para configuraciones específicas de la máquina (no versionadas en git).

Para datos específicos de chezmoi (como un correo diferente para una computadora de trabajo, o una llave de firma SSH), crea `~/.chezmoidata/local.toml` ANTES o DESPUÉS de ejecutar `chezmoi init`:
```toml
email = "trabajo@empresa.com"
gitSigningKey = "key::ssh-ed25519 AAAA..."
```
Este archivo local tiene prioridad sobre la configuración global y nunca será rastreado por git.

## Firma de Commits de Git (opcional)

Para habilitar la firma de commits basada en SSH (sin necesidad de GPG):

1. Configura `gitSigningKey` en `~/.chezmoidata/local.toml` con tu llave pública Ed25519
2. Ejecuta `chezmoi apply` para regenerar `~/.gitconfig`
3. Crea `~/.ssh/allowed_signers`:
   ```
   tu@correo.com ssh-ed25519 AAAA...
   ```

## Flujo de Trabajo de Docencia

```bash
# Navegar a los materiales de clase
teaching

# Comenzar a grabar la sesión de terminal para los alumnos
rec workshop-demo.cast

# Convertir a GIF para la documentación
agg workshop-demo.cast workshop-demo.gif
```

## Créditos

- [chezmoi](https://www.chezmoi.io/) para la gestión de dotfiles
- [mise](https://mise.jdx.dev/) para la gestión de versiones
- [Starship](https://starship.rs/) para el prompt