# Roadmap — ScrambledBits/dotfiles

Derived from `AUDIT_REPORT.md` (2026-08-28). Standalone: each item carries its requirement and acceptance criteria. IDs (`U-`, `R-`, `F-`, `P-`, `C-`) reference the report. Effort: S = minutes to an hour, M = an afternoon, L = a day+.

> First: add `AUDIT_REPORT.md`, `ROADMAP.md`, `audit_findings.json` to `.chezmoiignore` before the next `chezmoi apply`, or they deploy into `$HOME`.

---

## NOW — M1 · A fresh machine gets a working shell

**Theme:** `chezmoi init --apply` on a clean Mac or Linux box must produce the documented environment with no unmanaged files. Today it doesn't, on either OS.

**Exit criterion:** on a clean macOS VM and an `ubuntu:24.04` container, `zsh -ic true` prints nothing to stderr, `type gst tf k` resolve, the prompt shows an OS symbol, and `git fetch` over HTTPS prints no `osxkeychain` warning on Linux.

| # | Item | Effort | Confidence |
|---|---|---|---|
| 1 | **Homebrew on PATH from managed files** (U-5, F-1): template `BREW_PREFIX` per OS/arch in `dot_config/shell/paths`, prepend `$BREW_PREFIX/bin:$BREW_PREFIX/sbin`, delete `brew --prefix` fork at `.zshrc:26`, guard the four `eval "$(… init zsh)"` lines with `command -v`. README: add `eval "$(/opt/homebrew/bin/brew shellenv)"` between steps 1 and 2. | S | verified |
| 2 | **Install Oh My Zsh via `.chezmoiexternal.toml`** (U-4): archive type, `stripComponents = 1`, `refreshPeriod = "168h"`; drop `zstyle ':omz:update'` lines. | S | verified |
| 3 | **Delete duplicate mise activation** (R-4): `.zshrc:83-84` (OMZ `mise` plugin already does it). | S | verified |
| 4 | **OS icon via Starship `[os]`** (U-1/P-2): remove `STARSHIP_DISTRO` export and `[env_var.STARSHIP_DISTRO]`; set `[os] disabled = false`. | S | verified |
| 5 | **Real per-machine overrides** (U-2/P-3): `gitSigningKey = {{ promptStringOnce . "gitSigningKey" "SSH signing key (empty to skip)" "" | quote }}`; delete `.chezmoiignore:5-6`; README "Datos de chezmoi locales" → `chezmoi edit-config`. Remove the unused `timezone` prompt (U-3). | S | verified |
| 6 | **Linux-safe gitconfig and nvim** (F-3, F-4): wrap `credential.helper = osxkeychain` in a darwin guard; `clipboard = "unnamedplus"`. | S | verified |
| 7 | **Stop deploying docs into `$HOME`** (U-11): add `README.md`, `CLAUDE.md` (+ the three audit files) to `.chezmoiignore`; remove `~/README.md`, `~/CLAUDE.md`. | S | verified |
| 8 | **Drop the dead Claude settings copy** (U-10/R-1, per Checkpoint 2): delete `private_dot_claude/`; fix CLAUDE.md:17,43. Delete redundant `.gitignore` ignore line (R-3). | S | verified |
| 9 | **Sync the mise pin** (C-6, per Checkpoint 2): `terraform = "1.15.9"`; move the live `flutter` entry to `~/.config/mise/config.local.toml`; `chezmoi apply` clears the `.zshrc` drift (R-14). | S | verified |
| 10 | **README truth pass** (C-1, C-2, C-3, C-5, C-9, C-11): theme is Starship, versions table → "latest via mise" (or delete it), no casks in `Brewfile`, CLAUDE.md nvim uses lazy.nvim, `.zshrc:7` comment, mas recovery command. | S | verified |

Requirements for M1 (PM form):
- *Bootstrap.* The system must produce a working prompt with all managed integrations on first login after `chezmoi init --apply`, without any unmanaged file. AC: stderr-clean `zsh -ic true` on both OSes; OMZ aliases resolve; brew prefix precedes `/usr/bin` in `PATH`; `~/.zprofile` may be absent.
- *OS icon.* The prompt must show an OS/distro symbol with no shell-side export. AC: Apple symbol on macOS, Ubuntu symbol on Ubuntu; `grep STARSHIP_DISTRO` over the repo is empty.
- *Overrides.* A machine must be able to set `gitSigningKey` without editing tracked files. AC: `chezmoi init` prompts once with empty default; after `chezmoi edit-config` + `apply`, `~/.gitconfig` contains `[gpg] format = ssh`; README no longer mentions `~/.chezmoidata`.

---

## NEXT — M2 · One code path per OS, Linux proven

**Theme:** collapse the duplicated scripts, fix the first-run and hook interactions, and put Linux under CI so "deliberate Linux support" is a tested claim instead of a TODO.

**Exit criterion:** one packages script and one Homebrew script in the source; a GitHub Actions run on `ubuntu-latest` + `macos-latest` that renders every template, shellchecks every script, and runs `starship print-config` warning-free; `pre-commit install` works in a repo with `.pre-commit-config.yaml`; `mas` apps install on a signed-in fresh Mac.

| # | Item | Effort | Confidence |
|---|---|---|---|
| 1 | **Merge the OS-split scripts** (F-2, R-5, R-6): single `run_onchange_before_install-packages.sh.tmpl` and `run_once_before_install-homebrew.sh.tmpl` with `{{ if eq .chezmoi.os "darwin" }}` blocks; one failure policy (`|| true` per bundle, as darwin does today); drop dead `brew shellenv` evals, dead cask/mas grep, and the box-wide `brew upgrade`. | M | verified |
| 2 | **Mac App Store on first run** (U-6/P-4): own `run_onchange_after_install-mas-apps.sh.tmpl` hashing only the `mas` lines, run after brew; honest warning text; README recovery = `chezmoi state delete-bucket --bucket=scriptState && chezmoi apply`. | S | verified |
| 3 | **Hooks that coexist** (F-5/P-10): global `pre-commit` chains to `$(git rev-parse --git-path hooks)/pre-commit` when present — or drop `core.hooksPath` and add gitleaks per repo via pre-commit. Pick one. | S | verified |
| 4 | **Linux CI** (U-9/P-7): `chezmoi init --source . --apply --dry-run --verbose` with `--promptString` values on both runners; shellcheck rendered scripts; `starship print-config` must be warning-free. | M | verified |
| 5 | **Teaching aliases and tools** (U-7/P-5): `rec`, `teaching`, `projects`, `kctx` in `.zshrc`; `asciinema`, `vhs`, `agg` in the shared `Brewfile` (assumption A-3); remove mdbook from README. | S | verified |
| 6 | **Multi-cloud: honor or drop** (U-8/P-6, needs Q-2): add `cask "google-cloud-sdk"`, `brew "azure-cli"`, `[azure]` starship module — or edit README/CLAUDE.md to "GCP + AWS". | S | inferred |
| 7 | **Remove the Ghostty AppSupport symlink** (R-7, assumption A-4): XDG path already loads on macOS; deletes `private_Library/` and the `Library/**` ignore. | S | verified / inferred |
| 8 | **Drop `dot_vscode/argv.json`** (R-8): only content is a default and a machine-specific crash-reporter UUID. | S | verified |
| 9 | **SSH tidy** (R-12, F-6): trim GitHub/GitLab blocks to `User` + `PreferredAuthentications`; `KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256` (or delete the line). | S | verified (client) / inferred (servers) |
| 10 | **Comment cleanup** (R-13): `.zshrc:7`, `init.lua` "replaces …" lines, "clean environment" comments in scripts. | S | verified |
| 11 | **README additions** (§2.3 doc gaps): mise tasks, nvim keymaps, git aliases, `paths` file. | S | verified |

Requirements for M2 (PM form):
- *Single script per concern.* The system must have exactly one package-install script and one Homebrew-bootstrap script regardless of OS. AC: `ls run_*` shows 4 scripts (packages, homebrew, mise-tools, mas-apps) + ssh-sockets; rendered darwin and linux variants differ only inside `{{ if }}` blocks.
- *Linux proof.* Every push must render and lint the Linux variant. AC: green CI on `ubuntu-latest`; shellcheck 0 findings; starship 0 warnings.
- *Hooks.* AC: `pre-commit install` succeeds; gitleaks still blocks a staged secret in a repo without pre-commit.
- *mas.* AC: five `mas` apps install during the first `chezmoi apply` on a signed-in Mac; signed-out warning names the cause; documented recovery command re-runs the install.

---

## LATER — M3 · Editor and toolbox depth

**Theme:** things that make daily work better once the base is sound. None of these are broken today.

**Exit criterion:** `:checkhealth vim.lsp` shows `terraform-ls` attached in a `.tf` buffer; nvim-treesitter on `main`; `Brewfile.MacOS` reviewed line-by-line with a decision recorded per item.

| # | Item | Effort | Confidence |
|---|---|---|---|
| 1 | **Delete `Comment.nvim`** (R-9): Neovim ≥ 0.10 ships `gc`. | S | verified |
| 2 | **Neovim LSP via native client** (P-8): `vim.lsp.config`/`vim.lsp.enable` for `terraform-ls`, `yaml-language-server`, `pyright`/`basedpyright`, `gopls`; binaries via mise. No new plugin manager entries required. | M | inferred |
| 3 | **nvim-treesitter → `main`** (F-7): machine is on 0.12.5; `main` is a different plugin (no `configs`, no `ensure_installed`) — rewrite `init.lua:88-102`. | M | verified |
| 4 | **Brewfile review** (R-10, R-11): replace deprecated `gemini-cli` formula; collapse 3 Docker extensions → `ms-azuretools.vscode-containers` (+ `docker.docker` if wanted), 2 CSV extensions → 1, `font-monaspace` vs `font-monaspice-nerd-font`; decide per item on `rabbitmq`, `cocoapods`, `mysqlworkbench`/`pgadmin4`/`dbeaver-community`, `watson`, `llmfit`, `openai-whisper`, `ollama`, and the 13 unused Nerd Fonts. | S–M | verified (dups, deprecation) / inferred (scope) |
| 5 | **API-key loading** (open question): `api_keys.env` is exported into every process; consider `aws-vault`/direnv per-directory loading. | M | inferred |

Requirements for M3 (PM form):
- *LSP.* AC: opening a `.tf` file attaches `terraform-ls`; a K8s YAML gets schema diagnostics; no plugin-manager additions beyond an optional completion source.
- *Treesitter.* AC: highlighting works for the 10 languages in `ensure_installed` today after moving to `main`; `:checkhealth nvim-treesitter` clean.
