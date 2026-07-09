# Changelog

## 2026-07-09

- Corregido: config de Starship se desplegaba a `~/.config/.starship.toml` (ruta muerta); ahora `dot_config/starship.toml` → `~/.config/starship.toml`.
- Corregido: `dot_library/` desplegaba a `~/.library/` en vez de `~/Library/`; Ghostty ahora usa un solo archivo en `~/.config/ghostty/config.ghostty` con symlink en Application Support (macOS).
- Ghostty: apariencia reconciliada desde la máquina (Hurmit Nerd Font Mono 18, tema Afterglow) + comportamiento del repo.
- Eliminado `dot_vimrc` (vim = nvim en todo el flujo).
- Aliases podados según uso real del historial; `tf*`/`k*` vienen de los plugins de OMZ.
- `STARSHIP_DISTRO` exportado en `.zshrc` (ícono de OS en el prompt).
- Git: eliminados defaults redundantes (`push.default`, `color.ui`); agregado `git-lfs` al Brewfile.
- SSH: `SetEnv TERM=xterm-256color` agregado al repo (fix para Ghostty en hosts remotos).
- mise: terraform 1.15.7 (reconciliado), sin `experimental`, `shell_alias` solo `tg`.
- Brewfiles: sin `uv` duplicado (lo gestiona mise), sin líneas comentadas de mdbook/gnupg; agregada fuente Hurmit.
