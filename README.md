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

# 2. Poner Homebrew en el PATH de esta sesión (el instalador no lo hace)
eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
# eval "$(/usr/local/bin/brew shellenv)"    # Intel

# 3. Instalar chezmoi (única dependencia inicial — no está en el Brewfile)
brew install chezmoi

# 4. Inicializar y aplicar todo en un solo paso
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git
```

### Máquina nueva — Linux (Debian/Ubuntu, Fedora, Arch)

```bash
# 1. Instalar dependencias mínimas (el script de bootstrap instala el resto)
sudo apt-get install -y curl git zsh                       # Debian/Ubuntu
sudo dnf install -y curl git zsh                           # Fedora
sudo pacman -Sy --noconfirm curl git zsh                   # Arch

# 2. Instalar chezmoi en ~/.local/bin y ponerlo en el PATH de esta sesión
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# 3. Inicializar y aplicar todo en un solo paso
chezmoi init --apply git@github.com:ScrambledBits/dotfiles.git

# 4. Cambiar el shell de inicio de sesión a zsh (paso manual, pide tu contraseña)
chsh -s "$(command -v zsh)"
```

Durante la inicialización se te pedirá:
- Nombre completo
- Correo electrónico
- Usuario de GitHub
- Llave SSH de firma de commits (opcional — deja en blanco para omitirla)

Esto mantiene tu información personal fuera del repositorio.

El proceso automáticamente:
1. Instala Homebrew (Linuxbrew en Linux) si no está presente
2. Ejecuta `brew bundle` con el `Brewfile` y (en macOS) también con `Brewfile.MacOS`
3. Descarga Oh My Zsh (no requiere paso manual)
4. Aplica todos los dotfiles en `~`

> **App Store (macOS):** las apps de `mas` se instalan después de que `brew bundle` instale `mas` mismo. Si no has iniciado sesión en la App Store, verás una advertencia; inicia sesión y ejecuta `chezmoi state delete-bucket --bucket=entryState && chezmoi apply`.

### Máquina existente (ya inicializada)

```bash
# Aplicar cambios (incluyendo nuevos paquetes en los Brewfiles)
chezmoi apply

# Instalar versiones de herramientas definidas en mise
mise install
```

---

## Verificación (CI)

Cada push y pull request corre [`.github/workflows/chezmoi-dry-run.yml`](.github/workflows/chezmoi-dry-run.yml) en `ubuntu-latest` y `macos-latest`: aplica los dotfiles en modo `--dry-run`, además de renderizar y aplicar de verdad todos los templates en un `$HOME` de prueba para arrancar una shell zsh interactiva real (sin `Homebrew` ni los `run_*` scripts) y confirmar que los alias documentados resuelven. También corre `shellcheck` sobre cada script renderizado y valida `dot_config/starship.toml` con `starship print-config`.

---

## Estructura de Paquetes

Los paquetes se gestionan con dos archivos Homebrew que los scripts de instalación embeben automáticamente:

| Archivo | Plataforma | Contenido |
|---------|-----------|-----------|
| `Brewfile` | macOS + Linux | Herramientas CLI de DevOps |
| `Brewfile.MacOS` | macOS únicamente | Formulas macOS-específicas, apps gráficas (casks, incl. VS Code + extensiones, OrbStack), Mac App Store, fuentes |

> **Linux:** El script de Linux usa solo el `Brewfile` compartido, que no contiene líneas `cask` ni `mas`.

---

## Qué Incluye

- **Shell:** zsh con Oh My Zsh (instalado automáticamente vía chezmoi), prompt de Starship, mise, direnv, zsh-autosuggestions, fast-syntax-highlighting
- **Cloud:** Herramientas para AWS con módulos conscientes del contexto en Starship
- **Kubernetes:** k9s, kubectx, stern, prompt con contexto/namespace activo
- **IaC:** Terraform (vía mise), Terragrunt, TFLint, Checkov, Trivy
- **Desarrollo:** Neovim, delta (diffs de git), lazygit, fd, bat, eza, ripgrep, fzf, zoxide
- **Docencia:** asciinema, vhs, agg (grabación y conversión a GIF de sesiones de terminal)
- **macOS exclusivo:** OrbStack (Docker Desktop), aws-vault (credenciales seguras), Proxyman (proxy HTTP), Raycast (lanzador)

---

## Arquitectura

**Shell (`dot_zshrc.tmpl`):** Oh My Zsh con el tema desactivado — Starship es el prompt. `dot_config/shell/paths.tmpl` calcula `BREW_PREFIX` según el sistema/arquitectura y arma el `PATH` antes de que se cargue el resto de la configuración. Integra mise (vía el plugin `mise` de Oh My Zsh), direnv, zoxide (`z` reemplaza `cd`), y Starship; las integraciones opcionales están protegidas con `command -v` para no romper el shell si falta alguna herramienta. Sources `~/.zshrc.local` para sobreescrituras locales. También carga `zsh-autosuggestions` y `fast-syntax-highlighting` si están instalados vía Homebrew.

**Gestión de versiones (`dot_config/mise/config.toml`):** mise gestiona Python, uv, Node, Go, Rust, Terraform 1.15.9 (pinned — el resto usa `latest`), Terragrunt, TFLint, fd, lazygit y delta. Establece `PIP_REQUIRE_VIRTUALENV=true` para prevenir instalaciones globales de pip. Herramientas exclusivas de una máquina van en un `~/.config/mise/config.local.toml` sin versionar, que mise carga automáticamente junto al archivo gestionado.

**Entornos por directorio (`dot_config/direnv/direnvrc`):** Define funciones helper para archivos `.envrc` — `use_aws_profile()`, `use_tf_workspace()`. La activación de mise se maneja por activación de shell, no por `use_mise()` (deprecado).

**Prompt (`dot_config/starship.toml`):** Ícono de sistema operativo (módulo `[os]`), estado de git, contexto/namespace de Kubernetes (solo en directorios k8s), perfil de AWS, workspace de Terraform, y duración de comandos. Ruta estándar XDG: `~/.config/starship.toml` — funciona igual en macOS y Linux.

**Git (`dot_gitconfig.tmpl`):** Usa delta para diffs (side-by-side), rebase al hacer pull, poda automática de refs remotas, estilo de conflicto `zdiff3`, `rerere` habilitado, credential helper `osxkeychain` (solo macOS). La firma SSH de commits es opt-in: se pregunta la llave al inicializar (`chezmoi init`) y puede cambiarse después con `chezmoi edit-config`.

---

## Versiones de Herramientas (mise)

| Herramienta | Versión |
|-------------|---------|
| Python | latest |
| uv | latest |
| Node.js | latest |
| Go | latest |
| Rust | latest |
| Terraform | 1.15.7 |
| Terragrunt | latest |
| TFLint | latest |

> **Nota:** Terraform utiliza la licencia BSL de HashiCorp. [OpenTofu](https://opentofu.org/) (MPL 2.0) es una alternativa compatible — revisa `dot_config/mise/config.toml` para ver cómo alternar (comentado).

---

## Alias Principales

Los alias personalizados son mínimos; las familias `g*`, `tf*` y `k*` vienen de los plugins de OMZ (git, terraform, kubectl):

| Alias | Comando |
|-------|---------|
| `vim` | nvim |
| `cat` | bat |
| `grep` | batgrep |
| `find` | fd |
| `ls`/`ll`/`la`/`l` | variantes de eza |

Ver también las tareas de mise y los alias de git abajo.

### Tareas de mise (`mise run <tarea>`)

| Tarea | Qué hace |
|-------|----------|
| `tf-check` | `terraform fmt -check` + `tflint` + `terraform validate` |
| `tf-docs` | Genera documentación del módulo Terraform con terraform-docs |
| `k8s-check` | Valida manifiestos de Kubernetes con kubeconform |
| `secrets-check` | Escanea el repositorio en busca de secretos con gitleaks |

### Neovim y git

Los atajos de Neovim (`<leader>ff/fg/fb/fh/e` para buscar archivos, grep, buffers, ayuda y el explorador de archivos) están en `dot_config/nvim/init.lua`. Los alias de git propios (`undo`, `amend`) están en `dot_gitconfig.tmpl`; el resto (`gst`, `gco`, `glog`, entre otros) viene del plugin `git` de Oh My Zsh.

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

Los valores de plantilla (nombre, correo, llave de firma) se piden una sola vez en `chezmoi init` y persisten por máquina en `~/.config/chezmoi/chezmoi.toml` (nunca rastreado por git). Para cambiar uno, edita ese archivo y vuelve a ejecutar `chezmoi apply`.

> Nota: chezmoi **no** lee `~/.chezmoidata/` del home; ese mecanismo documentado antes aquí no funcionaba.

### Herramientas de mise locales

Para instalar una herramienta de mise solo en una máquina (sin agregarla al repositorio), créala en `~/.config/mise/config.local.toml` — mise lo carga automáticamente junto al `config.toml` gestionado.

### Credenciales de GitHub en Linux

En macOS, `credential.helper = osxkeychain` guarda las credenciales de git en el Keychain. En Linux, el `.gitconfig` gestionado usa `cache --timeout=3600` (sin dependencias extra), pero para GitHub específicamente es mejor usar `gh`, que ya viene en el `Brewfile` compartido:

```bash
gh auth login
gh auth setup-git
```

Esto configura un credential helper propio de `gh` para `github.com`, que coexiste con el `cache` por defecto.

### API keys y secretos compartidos entre proyectos

`~/.config/shell/api_keys.env` (machine-local, créalo manualmente) guarda API keys que usan varios proyectos. **No se carga globalmente** — cargarlo en cada shell pondría todas las keys en cada proceso, incluso en proyectos que no las necesitan. En su lugar, cada proyecto que las necesite las carga solo mientras estás en su directorio:

```bash
# En la raíz del proyecto, crea .envrc:
echo 'dotenv_if_exists ~/.config/shell/api_keys.env' >> .envrc
direnv allow .
```

direnv carga esas variables solo al entrar al directorio y las descarga al salir. El `.envrc` de un proyecto puede commitearse sin problema — solo contiene la ruta al archivo compartido, nunca los valores de las keys. Si un proyecto además necesita variables propias, agrégalas al mismo `.envrc`:

```bash
# .envrc
dotenv_if_exists ~/.config/shell/api_keys.env
export PROJECT_SPECIFIC_VAR="valor"
```

Si una key propia de un proyecto no debe compartirse ni commitearse, agrega `.envrc` (o el `.env` que referencie) al `.gitignore` de ese proyecto.

---

## Firma de Commits de Git (opcional)

Para habilitar la firma de commits con GPG:

1. Obtén tu key ID: `gpg --list-secret-keys --keyid-format long`
2. Configura `gitSigningKey` en `~/.config/chezmoi/chezmoi.toml` (o respóndelo en `chezmoi init`)
3. Ejecuta `chezmoi apply` para regenerar `~/.gitconfig`

---

## Créditos

- [chezmoi](https://www.chezmoi.io/) para la gestión de dotfiles
- [mise](https://mise.jdx.dev/) para la gestión de versiones de herramientas
- [Starship](https://starship.rs/) para el prompt de shell
- [Homebrew](https://brew.sh/) / [Linuxbrew](https://docs.brew.sh/Homebrew-on-Linux) para la gestión de paquetes
