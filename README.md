# Dotfiles de Emilio Castro

Configuración de Senior Cloud & DevOps Engineer gestionada por [chezmoi](https://www.chezmoi.io/).
Funciona en **macOS** (Apple Silicon e Intel) y **Linux** (Debian/Ubuntu, Fedora, Arch).

---

## Por qué chezmoi no está en el Brewfile

`chezmoi` ejecuta los scripts de instalación de paquetes — incluyendo el propio `Brewfile`. Esto crea un problema circular: necesitas `chezmoi` para poder instalar `chezmoi`. Por eso, `chezmoi` se instala **manualmente como primer paso** antes de ejecutar `chezmoi init`. No aparece en el `Brewfile`.

---

## Inicio Rápido

### Máquina nueva — macOS

```bash
# 1. Instalar Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Instalar chezmoi (única dependencia inicial — no está en el Brewfile)
brew install chezmoi

# 3. Inicializar y aplicar todo en un solo paso
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git
```

### Máquina nueva — Linux (Debian/Ubuntu, Fedora, Arch)

```bash
# 1. Instalar dependencias del sistema
sudo apt-get install -y build-essential curl git          # Debian/Ubuntu
sudo dnf groupinstall -y 'Development Tools' && \
  sudo dnf install -y curl git                            # Fedora
sudo pacman -Sy --noconfirm base-devel curl git           # Arch

# 2. Instalar chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 3. Inicializar y aplicar todo en un solo paso
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git
```

Durante la inicialización se te pedirá:
- Nombre completo
- Correo electrónico
- Usuario de GitHub
- Zona horaria (ej. `America/Mexico_City`)

Esto mantiene tu información personal fuera del repositorio.

El proceso automáticamente:
1. Instala Homebrew (Linuxbrew en Linux) si no está presente
2. Ejecuta `brew bundle` con el `Brewfile` y (en macOS) también con `Brewfile.MacOS`
3. Aplica todos los dotfiles en `~`

> **App Store (macOS):** Si las apps de `mas` no se instalan, inicia sesión en la App Store y vuelve a ejecutar `chezmoi apply`.

### Máquina existente (ya inicializada)

```bash
# Aplicar cambios (incluyendo nuevos paquetes en los Brewfiles)
chezmoi apply

# Instalar versiones de herramientas definidas en mise
mise install
```

---

## Estructura de Paquetes

Los paquetes se gestionan con dos archivos Homebrew que los scripts de instalación embeben automáticamente:

| Archivo | Plataforma | Contenido |
|---------|-----------|-----------|
| `Brewfile` | macOS + Linux | Herramientas CLI de DevOps, casks comunes, extensiones de VS Code, paquetes de uv |
| `Brewfile.MacOS` | macOS únicamente | Taps y formulas macOS-específicos, apps gráficas (casks), Mac App Store, OrbStack, aws-vault, mdbook toolchain |

> **Linux:** El script de Linux usa solo el `Brewfile` compartido. Las líneas `cask` y `mas` se ignoran automáticamente en Linux.

---

## Qué Incluye

- **Shell:** zsh con Oh My Zsh, prompt de Starship, mise, direnv, zsh-autosuggestions, fast-syntax-highlighting
- **Cloud:** Herramientas para GCP, AWS, Azure con módulos conscientes del contexto en Starship
- **Kubernetes:** k9s, kubectx, stern, prompt con contexto/namespace activo
- **IaC:** Terraform (vía mise), Terragrunt, TFLint, Checkov, Trivy
- **Desarrollo:** Neovim, delta (diffs de git), lazygit, fd, bat, eza, ripgrep, fzf, zoxide
- **Docencia:** asciinema, vhs, mdbook (con plugins para PDF, EPUB, D2, alertas)
- **macOS exclusivo:** OrbStack (Docker Desktop), aws-vault (credenciales seguras), Proxyman (proxy HTTP), Raycast (lanzador)

---

## Arquitectura

**Shell (`dot_zshrc.tmpl`):** Oh My Zsh con tema robbyrussell. Integra mise, direnv, zoxide (`z` reemplaza `cd`), y Starship. Sources `~/.zshrc.local` para sobreescrituras locales. También carga `zsh-autosuggestions` y `fast-syntax-highlighting` si están instalados vía Homebrew.

**Gestión de versiones (`dot_config/mise/config.toml`):** mise gestiona Python, uv, Node, Go, Rust, Terraform 1.15.7, Terragrunt, TFLint, fd, lazygit y delta. Establece `PIP_REQUIRE_VIRTUALENV=true` para prevenir instalaciones globales de pip.

**Entornos por directorio (`dot_config/direnv/direnvrc`):** Define funciones helper para archivos `.envrc` — `use_aws_profile()`, `use_gcp_project()`, `use_tf_workspace()`. La activación de mise se maneja por activación de shell, no por `use_mise()` (deprecado).

**Prompt (`dot_config/starship.toml`):** Muestra estado de git, contexto/namespace de Kubernetes (solo en directorios k8s), proyecto de GCP, workspace de Terraform, y duración de comandos. Ruta estándar XDG: `~/.config/starship.toml` — funciona igual en macOS y Linux.

**Git (`dot_gitconfig.tmpl`):** Usa delta para diffs (side-by-side), rebase al hacer pull, poda automática de refs remotas, estilo de conflicto `zdiff3`, `rerere` habilitado. La firma SSH de commits es opt-in vía la variable `gitSigningKey`.

---

## Versiones de Herramientas (mise)

| Herramienta | Versión |
|-------------|---------|
| Python | 3.13 |
| Node.js | 24 (Active LTS) |
| Go | 1.26 |
| Terraform | 1.14.7 |
| Terragrunt | 0.99 |
| TFLint | 0.61 |
| Poetry | 2.3 |
| Ruff | 0.15 |

> **Nota:** Terraform utiliza la licencia BSL de HashiCorp. [OpenTofu](https://opentofu.org/) (MPL 2.0) es una alternativa compatible — revisa `dot_config/mise/config.toml` para ver cómo alternar (comentado).

---

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

---

## Personalización por Máquina

### Shell local

Crea `~/.zshrc.local` para configuraciones específicas de la máquina (no versionado en git):

```bash
# ~/.zshrc.local
export CUSTOM_VAR="value"
alias my-alias="my-command"
```

### Datos de chezmoi locales

Para sobrescribir variables de plantilla (correo de trabajo, llave SSH de firma), crea `~/.chezmoidata/local.toml` **antes** de ejecutar `chezmoi init`:

```toml
# ~/.chezmoidata/local.toml
[data]
email = "trabajo@empresa.com"
gitSigningKey = "key::ssh-ed25519 AAAA..."
```

Este archivo tiene prioridad sobre la configuración global y nunca será rastreado por git.

---

## Firma de Commits de Git (opcional)

Para habilitar la firma de commits basada en SSH (sin necesidad de GPG):

1. Configura `gitSigningKey` en `~/.chezmoidata/local.toml`
2. Ejecuta `chezmoi apply` para regenerar `~/.gitconfig`
3. Crea `~/.ssh/allowed_signers`:
   ```
   tu@correo.com ssh-ed25519 AAAA...
   ```

---

## Flujo de Trabajo de Docencia

```bash
# Navegar a los materiales de clase
teaching

# Grabar sesión de terminal para los alumnos
rec workshop-demo.cast

# Convertir a GIF para la documentación
agg workshop-demo.cast workshop-demo.gif
```

---

## Créditos

- [chezmoi](https://www.chezmoi.io/) para la gestión de dotfiles
- [mise](https://mise.jdx.dev/) para la gestión de versiones de herramientas
- [Starship](https://starship.rs/) para el prompt de shell
- [Homebrew](https://brew.sh/) / [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux) para la gestión de paquetes
