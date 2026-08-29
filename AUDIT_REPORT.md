# Audit Report — ScrambledBits/dotfiles

Audited 2026-08-28 against `main` @ `6ef3dfc`. Two lenses, run in sequence: **Lens A** (Tech Lead: what is broken, dead, or rotting) then **Lens B** (Technical PM: what is missing, what to build, in what order). Every finding is tagged `verified` (tool output or mechanically checkable by reading) or `inferred` (judgment), and cites `file:lines`.

> **Before your next `chezmoi apply`:** this repo deploys every non-ignored root file into `$HOME` (see U-11). `AUDIT_REPORT.md`, `ROADMAP.md`, and `audit_findings.json` are **not** in `.chezmoiignore` — add them (or move them) first, or they land in `~/` and get auto-committed. The audit did not edit any source file.

---

## 1. Orientation

**Stack.** No application code. A [chezmoi](https://chezmoi.io) source state: 8 Go-templated files, 6 shell scripts (`run_once_*`/`run_onchange_*`), TOML/Lua/plain configs, two Brewfiles. ~1.46k LOC across 28 files, 47 commits, single author. No tests, no CI. Tools available and used for this audit: chezmoi v2.72.0, starship 1.26.0, gitleaks 8.30.1, nvim 0.12.5, OpenSSH 10.3, shellcheck 0.11.0 (via `uvx shellcheck-py`), pre-commit 4.6.2 (via `uvx`), Homebrew.

**What it is, for whom.** Personal dotfiles for one Senior Cloud/DevOps engineer who also teaches: zsh + Oh My Zsh + Starship, mise for tool versions, direnv helpers, Neovim, Ghostty, a hardened SSH config, git with delta, and Brewfile-driven package install. Declared targets: macOS (Apple Silicon and Intel) **and** Linux (Debian/Ubuntu, Fedora, Arch) — Linux support is explicitly deliberate (`CLAUDE.md:7`, `README.md:4`). The "user" of this product is the author on a *fresh machine*; the product's job is that `chezmoi init --apply` produces a working, identical environment there.

**Requirements sources inventoried.** `README.md` (Spanish, user-facing), `CLAUDE.md` (agent-facing, same content deployed to `~/CLAUDE.md`), `CHANGELOG.md`, `TODO.md`, inline comments in every template/script, `.chezmoiignore` comments, and commit messages (47).

**Hotspots (commits per file, from `git log --name-only`).** `dot_config/mise/config.toml` 10 · `dot_zshrc.tmpl` 9 · `Brewfile` 9 · `Brewfile.MacOS` 7 · `.chezmoiignore` 7 · `.chezmoi.toml.tmpl` 7 · `run_onchange_before_install-packages-darwin.sh.tmpl` 6 · `README.md` 6 · `dot_config/starship.toml` 6 · `dot_gitconfig.tmpl` 5.

**Live-machine context (this repo *is* the active chezmoi source: `chezmoi source-path` → this directory).** `chezmoi status` reports drift on `.zshrc` and `.config/mise/config.toml` (see Assumptions A-2).

---

## 2. Requirements traceability matrix

### 2.1 Documented + implemented (confirmed)

| Requirement (source) | Implementing code |
|---|---|
| chezmoi naming conventions, `private_` on `~/.claude`/`~/Library` (CLAUDE.md:9-17) | `private_dot_claude/`, `private_Library/…` — `chezmoi managed` confirms |
| mise manages Python/uv/Node/Go/Rust/TF/Terragrunt/TFLint/fd/lazygit/delta; `PIP_REQUIRE_VIRTUALENV`; `tg` alias; 4 tasks (CLAUDE.md:53) | `dot_config/mise/config.toml:5-54` |
| direnv helpers `use_aws_profile/use_gcp_project/use_tf_workspace` (README:103) | `dot_config/direnv/direnvrc:9-23` |
| Starship: git, k8s ctx/ns in k8s dirs, gcloud, aws, terraform ws, cmd_duration, `command_timeout=1000` (CLAUDE.md:57) | `dot_config/starship.toml` — `starship print-config` emits **zero** unknown-key warnings (`verified`) |
| Git: delta side-by-side, pull.rebase, fetch.prune, zdiff3, rerere, branch sort, LFS, hooksPath (CLAUDE.md:61) | `dot_gitconfig.tmpl:13-99` |
| SSH: modern ciphers, `accept-new`, multiplexing via `~/.ssh/sockets`, GitHub/GitLab, OrbStack include (darwin), `config.local` include, `SetEnv TERM` (CLAUDE.md:63, CHANGELOG:12) | `dot_ssh/config.tmpl`; `run_once_after_setup-ssh-sockets.sh`; `ssh -G github.com` confirms effective values |
| gitleaks pre-commit hook if installed (CLAUDE.md:29) | `dot_config/git/hooks/executable_pre-commit:4-6` |
| Brewfiles embedded in install scripts, not deployed (README:74, `.chezmoiignore:32-34`) | `run_onchange_before_install-packages-*.sh.tmpl:20-24` |
| Homebrew/Linuxbrew bootstrap incl. apt/dnf/pacman deps (README:53-54) | `run_once_before_install-homebrew-*.sh.tmpl` |
| Ghostty single XDG config + macOS symlink (CLAUDE.md:59) | `dot_config/ghostty/config.ghostty`, `private_Library/.../symlink_config.ghostty.tmpl` — Ghostty docs list `config.ghostty` as a valid filename (`verified`) |
| `~/.zshrc.local` sourced last (README:147) | `dot_zshrc.tmpl:140` |
| `git.autoCommit=true`, `autoPush=false` (CLAUDE.md:79) | `.chezmoi.toml.tmpl:3-5` |
| SSH commit signing opt-in via `gitSigningKey` (README:170-179) | `dot_gitconfig.tmpl:6-8,45-57` — template is correct, but see **U-2**: nothing can set the variable |
| All 6 shell scripts pass shellcheck 0.11 with zero findings (rendered via `chezmoi execute-template`) | `verified` |

### 2.2 Documented + missing / partial

| # | Promise | Where promised | Reality | Finding |
|---|---|---|---|---|
| 1 | OS icon in the prompt | CHANGELOG:10, CLAUDE.md:47, `starship.toml:22` | `STARSHIP_DISTRO` renders as `""` — the glyphs are absent from the template bytes | **U-1** |
| 2 | Per-machine `[data]` overrides via `~/.chezmoidata/local.toml` | README:155-166, CLAUDE.md:85, `.chezmoi.toml.tmpl:20-23`, `.chezmoiignore:5-6` | chezmoi only reads `.chezmoidata` from the **source state**; `~/.chezmoidata/…` is never read | **U-2** |
| 3 | Opt-in SSH commit signing | README:170-179 | Unreachable: `gitSigningKey` is hardcoded `""` and (2) doesn't work | **U-2** |
| 4 | Oh My Zsh as part of the shell | README:87, CLAUDE.md:45 | Nothing installs it; on this machine it is a manual clone | **U-4** |
| 5 | `chezmoi init --apply` yields a working shell on a new machine | README:14-57 | Homebrew is never put on `PATH` by any managed file | **U-5** |
| 6 | Mac App Store apps install; re-run `chezmoi apply` after signing in | README:58, `Brewfile.MacOS:45-49` | `mas` isn't installed yet on first run; `run_onchange` won't re-run on plain `apply` | **U-6** |
| 7 | Aliases `kctx`, `projects`, `teaching`, `rec`; `agg` in the teaching flow | README:128-140, 185-194 | None defined/installed | **U-7** |
| 8 | Azure tooling; GCP SDK | README:88, CLAUDE.md:7; `.zshrc:125-128` | No `azure-cli`, no `google-cloud-sdk` in any Brewfile; no `[azure]` starship module | **U-8** |
| 9 | mdbook + plugins | README:79, 92 | Not in any Brewfile (CHANGELOG:14 says removed) | **U-7** |
| 10 | Linux works | README:4, CLAUDE.md:7 | Never exercised (`TODO.md:3`); three Linux-only defects found (U-5, F-3, F-4) | **U-9** |
| 11 | `~/.claude/settings.json` managed | CLAUDE.md:17, 43 | `.chezmoiignore:12` excludes it; `chezmoi managed` does not list it | **U-10** |
| 12 | `timezone` is a template variable | CLAUDE.md:12, `.chezmoi.toml.tmpl:14` | No template references `.timezone` | **U-3** |

### 2.3 Implemented + undocumented (in README; CLAUDE.md documents most)

| Item | Where | Call |
|---|---|---|
| mise tasks `tf-check`/`tf-docs`/`k8s-check`/`secrets-check` | `mise/config.toml:40-54` | **Doc gap** — add to README (they are the most useful thing in the repo for a DevOps user) |
| Neovim keymaps `<leader>ff/fg/fb/fh/e`, plugin set | `nvim/init.lua:72-84` | **Doc gap** — one table in README |
| Git aliases (`review`, `files`, `undo`, `amend`, …) | `dot_gitconfig.tmpl:67-90` | **Doc gap** |
| `~/.config/shell/paths` as the PATH file | `dot_config/shell/paths` | **Doc gap** (README) — and its own comment in `.zshrc:7` says it's manual |
| VS Code `argv.json` management | `dot_vscode/argv.json` | **Scope creep — cut** (see R-8: the only non-default value is a machine-specific crash-reporter UUID) |
| `README.md`, `CLAUDE.md` deployed to `~/` | `chezmoi managed` lists both; `~/README.md`, `~/CLAUDE.md` exist on this machine | **Scope creep — cut** (see U-11) |
| Non-DevOps apps in `Brewfile.MacOS` | `Brewfile.MacOS:3-14,16-24` | **Review candidates** (R-10, per your Checkpoint 2 answer) |

### 2.4 Contradicted (docs say X, code does Y)

| # | Doc claim | Code | Which is right |
|---|---|---|---|
| C-1 | README:99 "Oh My Zsh con tema robbyrussell" | `dot_zshrc.tmpl:32` `ZSH_THEME=""` | Code (Starship). Fix README. `verified` |
| C-2 | README:113-122 pins Python 3.13 / Node 24 / Go 1.26 / TF **1.14.7** / Poetry 2.3 / Ruff 0.15 | mise: all `latest` except `terraform = "1.15.7"`; no poetry; ruff via `uv "ruff"` (`Brewfile:85`); README:101 itself says 1.15.7 | Code. Table is stale on every row. `verified` |
| C-3 | README:78 Brewfile has "casks comunes" | `grep -c '^cask ' Brewfile` = 0 | Code. `verified` |
| C-4 | README:92 asciinema/vhs are general "Docencia" tools | Both only in `Brewfile.MacOS:1,13` — absent on Linux | Undecided → **Q-1** (assumption A-3: move `asciinema` to shared Brewfile; `vhs` too, it is available on Linuxbrew) |
| C-5 | CLAUDE.md:26 "Neovim, single-file config, **no plugin manager**" | `init.lua:36-46` bootstraps lazy.nvim | Code. Fix CLAUDE.md. `verified` |
| C-6 | CLAUDE.md:53 "Terraform 1.15.7 (pinned)" | Live machine has 1.15.9 (`chezmoi status` MM) | Per Checkpoint 2: bump repo pin to **1.15.9**; `flutter` entry stays machine-local (A-2) |
| C-7 | `.chezmoiignore:11` comment "settings.json excluded so machine-specific hooks are preserved" vs CLAUDE.md:43 "only file managed under ~/.claude" | File exists in source, is ignored, never deployed | Per Checkpoint 2: the ignore is right → delete `private_dot_claude/` (U-10) |
| C-8 | CHANGELOG:10 "`STARSHIP_DISTRO` exportado (ícono de OS)" | Exports empty string | Code is broken, not the doc (U-1) |
| C-9 | `.zshrc:7` "Create these manually: … paths" | `paths` is chezmoi-managed | Code. Fix comment. `verified` |
| C-10 | Homebrew scripts: "chezmoi runs scripts in a clean environment" (`run_once_before_install-homebrew-*.sh.tmpl:15,31`) | chezmoi passes its own environment to scripts; only *login profiles* aren't sourced | Comment is half-wrong; and the `eval shellenv` it justifies is dead code (R-5). `inferred` on the env claim |
| C-11 | README:58 "vuelve a ejecutar `chezmoi apply`" to install mas apps | `run_onchange_` only re-runs when rendered content changes (chezmoi docs) | Code. README instruction does nothing (U-6). `verified` |

---

## 3. Unimplemented / half-built (Lens A)

**U-1 · OS icon in prompt is broken — `STARSHIP_DISTRO` exports an empty string on both OSes.** `verified`
`dot_zshrc.tmpl:77` — `xxd` on the source line shows `{{ if eq .chezmoi.os "darwin" }}{{ else }}{{ end }}` with **no bytes** between the template tags; rendered output is `export STARSHIP_DISTRO=""`. `dot_config/starship.toml:11,22-23` then renders `╭╴` followed by nothing. The glyphs were lost at some point (probably a tool round-trip that dropped private-use codepoints).
*Fix (1 line, removes 4):* delete the export and the `[env_var.STARSHIP_DISTRO]` block; enable Starship's built-in `[os]` module (`disabled = false`) — it detects macOS and Linux distros itself (Arch/Fedora/Ubuntu symbols are in the default config; `starship print-config` on 1.26 confirms) and needs nothing from `.zshrc`.

**U-2 · The documented per-machine override mechanism does not exist, so SSH signing can never be enabled.** `verified`
`.chezmoi.toml.tmpl:15-23` hardcodes `gitSigningKey = ""` and tells you to create `~/.chezmoidata/local.toml`; README:155-179 and CLAUDE.md:85 repeat it; `.chezmoiignore:5-6` ignores those paths. chezmoi documentation: `.chezmoidata` files are read **from the source state**, never from `$HOME`. Consequence: `dot_gitconfig.tmpl:6-8,45-57` (the entire signing block) is unreachable template code, and `~/.chezmoidata` does not exist on this machine (never worked).
*Fix:* `gitSigningKey = {{ promptStringOnce . "gitSigningKey" "SSH signing key (empty to skip)" "" | quote }}` — the value lands in the untracked per-machine `chezmoi.toml`, which is exactly what the docs wanted. Delete `.chezmoiignore:5-6`; rewrite README §"Datos de chezmoi locales" to `chezmoi edit-config`.

**U-3 · `timezone` is prompted for and never used.** `verified` — `.chezmoi.toml.tmpl:14`; `grep -rn timezone` hits only docs. Cut the prompt (or use it: `export TZ={{ .timezone }}` — but nothing today needs it).

**U-4 · Oh My Zsh is never installed.** `verified`
`dot_zshrc.tmpl:31,66` sources `~/.oh-my-zsh/oh-my-zsh.sh`. No script, Brewfile, or README step installs it (grep over the repo: only `.zshrc`, docs). On this machine it is a manually cloned git repo (`~/.oh-my-zsh`, last commit 2026-08-25). On a fresh machine every `plugins=(…)` entry silently does nothing: no `g*`, `k*`, `tf*` aliases, no `kubectl`/`terraform` completions — the three alias families CLAUDE.md:72 says "come from the enabled OMZ plugins".
*Fix:* `.chezmoiexternal.toml` with the archive entry from the chezmoi docs (`type = "archive"`, `stripComponents = 1`, `refreshPeriod = "168h"`). Zero scripting; also makes OMZ updates part of `chezmoi apply` (and then drop `zstyle ':omz:update'` at `.zshrc:40-41`).

**U-5 · Homebrew is never put on `PATH` by any managed file — the shell is broken on a fresh macOS *and* Linux machine.** `verified`
Nothing in `dot_zshrc.tmpl` or `dot_config/shell/paths` (the designated PATH file) adds `/opt/homebrew/bin` or `/home/linuxbrew/.linuxbrew/bin`. This machine works only because an **unmanaged** `~/.zprofile:43` runs `brew shellenv`. On a fresh Apple Silicon Mac (`/opt/homebrew/bin` is not in the default PATH) or any Linux box: `.zshrc:26` `command -v brew` fails → `BREW_PREFIX` empty → lines 68-71 (autosuggestions, syntax highlighting), 125-135 (gcloud, git-extras) silently skip; lines 78, 84, 87, 98 `eval "$(starship|mise|direnv|zoxide …)"` each print `command not found` on every shell start; `cat`/`ls`/`find` aliases point at missing binaries. Same root cause breaks README:22-23: after step 1 (Homebrew installer, which does **not** modify PATH), step 2 `brew install chezmoi` fails with `command not found: brew`.
*Fix (one change, three wins):* in `dot_config/shell/paths` set `BREW_PREFIX` from the template (`{{ if eq .chezmoi.os "darwin" }}{{ if eq .chezmoi.arch "arm64" }}/opt/homebrew{{ else }}/usr/local{{ end }}{{ else }}/home/linuxbrew/.linuxbrew{{ end }}`) and prepend `$BREW_PREFIX/bin:$BREW_PREFIX/sbin` — removes the `brew --prefix` subprocess at `.zshrc:26`, fixes Linux, and stops depending on `~/.zprofile`. README: add `eval "$(/opt/homebrew/bin/brew shellenv)"` between steps 1 and 2.

**U-6 · Mac App Store apps never install on first run, and the documented recovery step is a no-op.** `verified`
`run_onchange_before_install-packages-darwin.sh.tmpl:36-43`: the branch tests `command -v mas`, but `mas` is installed *by this very bundle* (`Brewfile.MacOS:7`), so on a fresh machine the `else` branch runs, filters the `mas` lines, and prints the misleading "Not signed in to App Store". README:58 then says to re-run `chezmoi apply`, but a `run_onchange_` script re-runs only when its rendered content changes (chezmoi docs, verified). The only ways to re-trigger are editing a Brewfile or `chezmoi state delete-bucket --bucket=scriptState`.
*Fix:* split the `mas` list into its own `run_onchange_after_install-mas-apps.sh.tmpl` (runs after brew, checks `mas` then, hashes only the mas lines) and correct the README instruction. Also `mas outdated` as a sign-in probe is `inferred` — it is not documented to fail when signed out.

**U-7 · README promises aliases and tools that don't exist.** `verified`
`kctx`, `projects`, `teaching`, `rec` (README:134-139) are not in `dot_zshrc.tmpl:109-120`, not in the OMZ kubectl plugin (`grep kctx ~/.oh-my-zsh/plugins/kubectl/` → nothing), and `kubectx` ships only `kubectx`/`kubens`. `agg` (README:193) is in no Brewfile. `mdbook` (README:79,92) is in no Brewfile. The "Flujo de Trabajo de Docencia" section (README:183-194) therefore fails at every line.
*Decision for Lens B:* add the four aliases + `agg` (they're tiny and match the stated teaching use case), drop mdbook from the README.

**U-8 · Multi-cloud claim: Azure absent, GCP SDK unmanaged.** `verified` (absence), `inferred` (whether wanted)
README:88 / CLAUDE.md:7 say GCP, AWS, Azure. `awscli` is in `Brewfile:4`; there is no `azure-cli`, no `google-cloud-sdk` (the cask that `.zshrc:125-128` sources), and Starship has `[gcloud]`/`[aws]` but no `[azure]`. Either add `cask "google-cloud-sdk"` + `brew "azure-cli"` + `[azure]` module, or drop Azure from the docs. → **Q-2**.

**U-9 · Linux has never been exercised.** `verified`
`TODO.md:3` says so; there is no `.github/` and no other CI. This audit found three Linux-only defects by reading (U-5, F-3, F-4). Given "Linux support is deliberate, do not remove it" (CLAUDE.md:7), the cheapest guard is a CI job that runs `chezmoi init --apply --dry-run` in an `ubuntu` container plus shellcheck (already clean).

**U-10 · `private_dot_claude/settings.json` is dead: ignored by `.chezmoiignore:12`, never deployed.** `verified`
`chezmoi managed` lists `.claude` (the directory) but not `.claude/settings.json`. The live `~/.claude/settings.json` has 14 top-level keys (`hooks`, `model`, `statusLine`, `permissions`, …); the repo copy has 5. Per Checkpoint 2: delete `private_dot_claude/` and fix CLAUDE.md:17,43. Keep `.chezmoiignore:12` (it is what makes the intent real).

**U-11 · `README.md` and `CLAUDE.md` are deployed into `$HOME`.** `verified`
`chezmoi managed` lists `CLAUDE.md` and `README.md`; `~/CLAUDE.md` (7.0k, 12 Jul) and `~/README.md` (7.2k, 9 Jul) exist on this machine. `~/CLAUDE.md` is then picked up as project instructions by every Claude Code session anywhere under `$HOME` — this session loaded it. Add both to `.chezmoiignore` (next to `CHANGELOG.md`/`TODO.md`, `.chezmoiignore:36-39`), then `chezmoi forget`/delete the two stray files. The same applies to the three files this audit produced.

---

## 4. Unused / redundant code (Lens A)

Tooling note: knip/depcheck/vulture do not apply to a dotfiles repo; this section is grep + chezmoi/starship/brew/nvim tool output + reading. Dynamic-access risk is nil here (no reflection/DI), so tool-backed items are `verified`.

| # | What | Where | Evidence | Action |
|---|---|---|---|---|
| R-1 | Never-deployed Claude settings | `private_dot_claude/settings.json` | `chezmoi managed` (U-10) `verified` | Delete dir |
| R-2 | Unreachable signing template blocks | `dot_gitconfig.tmpl:6-8,45-57` | U-2 `verified` | Keep blocks, fix the variable (U-2) |
| R-3 | Ignore entries that match nothing | `.chezmoiignore:5-6` (`.chezmoidata/*` — never a target), `:39` (`.gitignore` — chezmoi already ignores every dot-prefixed source file; docs + `chezmoi managed` confirm) | `verified` | Delete 3 lines |
| R-4 | mise activated twice | `dot_zshrc.tmpl:84` `eval "$(mise activate zsh)"` **and** `plugins=(… mise)` at `:61` — `~/.oh-my-zsh/plugins/mise/mise.plugin.zsh:6` runs the identical eval | `verified` | Delete `.zshrc:83-84` |
| R-5 | Dead `brew shellenv` after install | `run_once_before_install-homebrew-darwin.sh.tmpl:14-20`, `…-linux.sh.tmpl:30-36` | Only an `echo` follows; each chezmoi script is its own process, so the PATH change dies immediately. Comment says otherwise (C-10) `verified` | Delete 7+7 lines |
| R-6 | Dead cask/mas filter and over-broad upgrade | `run_onchange_before_install-packages-linux.sh.tmpl:29-32` filters `^cask `/`^mas ` from a Brewfile that has **0** such lines; `:27` `brew upgrade --quiet` upgrades *every* formula on the box, and is redundant because `brew bundle install` upgrades by default (Homebrew manpage, verified) | `verified` | Delete both |
| R-7 | Ghostty AppSupport symlink loads the same file twice | `private_Library/private_Application Support/private_com.mitchellh.ghostty/symlink_config.ghostty.tmpl`, `.chezmoiignore:41-44` | Ghostty docs: XDG `config.ghostty` is read on macOS too, "all macOS-specific files are loaded after all XDG files"; `ghostty +show-config` prints every key twice | `verified` (mechanism) / `inferred` (no other reason for it, e.g. the macOS "Open Config" menu) | Delete the tree + ignore block → removes the `private_Library` special case and the `Library/**` Linux ignore entirely |
| R-8 | `dot_vscode/argv.json` manages nothing useful | `dot_vscode/argv.json:15,19` | Only live keys: `enable-crash-reporter: true` (VS Code default) and `crash-reporter-id` — a **machine-specific UUID** now cloned to every machine | `verified` | Drop from management; ignore `.vscode/**` |
| R-9 | `Comment.nvim` duplicates built-in `gc` | `dot_config/nvim/init.lua:111` | `nvim --clean -c 'echo maparg("gc","n")'` on 0.12.5 → `<Lua … vim/_core/defaults>` (built-in since 0.10) | `verified` | Delete line |
| R-10 | Brewfile duplicates & out-of-scope entries | `Brewfile:59,67,68` three Docker extensions (`ms-azuretools.vscode-docker` is the legacy shell of `vscode-containers`); `Brewfile:66,78` two CSV extensions; `Brewfile.MacOS:26,38` `font-monaspace` + `font-monaspice-nerd-font`; `Brewfile.MacOS:30-43` 14 Nerd Fonts while Ghostty uses one (`config.ghostty:1`); review candidates per Checkpoint 2: `rabbitmq`, `cocoapods`, `mysqlworkbench`/`pgadmin4`/`dbeaver-community`, `watson`, `llmfit`, `openai-whisper`, `ollama` | `inferred` (usage unknown) | List for per-item decision |
| R-11 | Deprecated Homebrew formula | `Brewfile.MacOS:5` `gemini-cli` | `brew info --json` → `deprecated: true` | `verified` | Replace with the npm/mise install or drop; it will stop installing when disabled |
| R-12 | SSH host blocks restate `Host *` | `dot_ssh/config.tmpl:37-44,52-59` repeat `IdentityFile`×2, `IdentitiesOnly`, `AddKeysToAgent`, `UseKeychain` already in `:93-100`; `ssh -G github.com` shows identical effective values | `verified` | Trim each block to `User git` + `PreferredAuthentications publickey` |
| R-13 | Stale comments | `.zshrc:7` (C-9); `init.lua:80,87,104,110,113` "replaces NERDTree/vim-polyglot/lightline/NERDCommenter/delimitMate" — the vimrc they migrated from was deleted (CHANGELOG:8) | `verified` | Delete |
| R-14 | Duplicate `~/.local/bin` PATH export | live `~/.zshrc` has an extra `export PATH="$HOME/.local/bin:$PATH"` appended by an installer (drift, not in source); `dot_config/shell/paths:1` already does it | `verified` via `chezmoi diff` | Re-apply; nothing to change in source |

---

## 5. Refactoring opportunities (Lens A) — hotspot-ranked

Each entry: smell · churn · concrete move.

**F-1 · `dot_zshrc.tmpl` (9 commits): inconsistent guards and a subprocess for a compile-time constant.** `verified`
Smell: `fzf` is guarded with `command -v` (`:101`) but `starship`/`mise`/`direnv`/`zoxide` are not (`:78,84,87,98`); `BREW_PREFIX` forks `brew --prefix` on every shell (`:26`).
Move: template `BREW_PREFIX` per OS/arch in `dot_config/shell/paths` (see U-5), delete `:26`, guard the four evals uniformly (`command -v X >/dev/null && eval "$(X init zsh)"`), delete the duplicate mise eval (R-4). Net: −6 lines, one fewer fork, shell survives missing tools.

**F-2 · Two near-identical package scripts and two near-identical Homebrew bootstraps (darwin script: 6 commits).** `verified`
Smell: `run_onchange_before_install-packages-{darwin,linux}.sh.tmpl` differ only in the `Brewfile.MacOS` include, the mas branch, and — accidentally — their failure policy (`|| true` at darwin `:38,42` vs hard-fail at linux `:33`, which aborts the entire `chezmoi apply` on one bad formula) and upgrade policy (R-6). `run_once_before_install-homebrew-{darwin,linux}.sh.tmpl` differ only in prefix path and the apt/dnf/pacman block.
Move: one `run_onchange_before_install-packages.sh.tmpl` and one `run_once_before_install-homebrew.sh.tmpl`, each using `{{ if eq .chezmoi.os "darwin" }}` for the OS-specific block and a single error policy. Every future Brewfile-handling change then lands once.

**F-3 · `credential.helper = osxkeychain` is unconditional.** `verified`
`dot_gitconfig.tmpl:92-93` — on Linux every HTTPS git operation prints `git: 'credential-osxkeychain' is not a git command`. Move: wrap in `{{ if eq .chezmoi.os "darwin" }}` (Linux alternative: `cache --timeout=3600` or `libsecret`). Same treatment for the OMZ `macos` plugin at `.zshrc:59` — the plugin has no top-level OS guard, so it loads its `osascript` functions on Linux (`inferred`, harmless).

**F-4 · Neovim clipboard is wrong on Linux.** `verified` (semantics)
`init.lua:29` `clipboard = "unnamed"` = system clipboard on macOS but the **PRIMARY selection** on X11/Wayland. `"unnamedplus"` is the system clipboard on both. One-word change.

**F-5 · Global `core.hooksPath` silently disables every repo-local hook framework — including the `pre-commit` and `commitlint` this repo installs.** `verified`
`dot_gitconfig.tmpl:17` + `Brewfile:38` (`pre-commit`), `:9` (`commitlint`). pre-commit 4.6.2 source: `Cowardly refusing to install hooks with \`core.hooksPath\` set.` — `pre-commit install` fails in every repo on this machine; husky/lefthook hooks written to `.git/hooks/` are ignored by git.
Move (smallest): keep the global gitleaks hook and make it chain — append `[ -x "$(git rev-parse --git-path hooks)/pre-commit" ] && exec "$(git rev-parse --git-path hooks)/pre-commit" "$@"` to `executable_pre-commit`. pre-commit's refusal is about *install*, so per-repo you'd still need `pre-commit install -f` or `git config --local core.hooksPath .git/hooks`; the alternative is dropping the global hooksPath and adding gitleaks as a pre-commit hook per repo. Choose one; today you have neither working together.

**F-6 · SSH `KexAlgorithms` pins a single 2013 algorithm and drops post-quantum defaults.** `verified` (client), `inferred` (servers)
`dot_ssh/config.tmpl:68-69` "Modern encryption (2024+)" → `curve25519-sha256@libssh.org` only. `ssh -Q kex` on this OpenSSH 10.3 lists `mlkem768x25519-sha256` and `sntrup761x25519-sha512`, which OpenSSH ≥ 9.9 / ≥ 9.0 prefer by default. Move: `KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256` — or delete the line and let the client default win.

**F-7 · `nvim-treesitter` pinned to the locked `master` branch.** `verified` (deliberate: commit `a828daf`)
`init.lua:88-91`. Upstream README: `master` "is locked but will remain available for backward compatibility with Nvim 0.11"; `main` requires 0.12 (this machine: 0.12.5). Not urgent — `master` still works — but the `main` branch is "a different plugin" (no `configs` module, no `ensure_installed`), so budget an M-size rewrite of that block when you move. **Later.**

---

## 6. Feature opportunities with requirements (Lens B)

Each: problem · requirement · acceptance criteria. Items marked ★ re-evaluate a 1a finding as finish/cut/defer.

**P-1 ★ Fresh-machine bootstrap actually works (finish U-4, U-5).** Effort **S**.
Problem: `chezmoi init --apply` on a new Mac or Linux box produces a shell with missing PATH, missing OMZ, and four `command not found` errors per prompt.
Requirement: the system must produce a working prompt with all managed integrations on first login after `chezmoi init --apply`, without any unmanaged file.
AC: (1) `zsh -ic true` prints nothing to stderr on a fresh macOS VM and an `ubuntu:24.04` container; (2) `type gst tf k` resolve to OMZ aliases; (3) `echo $PATH` contains the brew prefix before `/usr/bin`; (4) `~/.zprofile` may be absent.

**P-2 ★ OS icon via Starship `[os]` (finish U-1, the lazy way).** Effort **S**.
Requirement: the prompt must show an OS/distro symbol without any shell-side export.
AC: (1) `starship prompt` on macOS contains the Apple symbol, on Ubuntu the Ubuntu symbol; (2) `grep STARSHIP_DISTRO` over the repo returns nothing.

**P-3 ★ Per-machine secrets/overrides that chezmoi actually reads (finish U-2; cut the `~/.chezmoidata` docs).** Effort **S**.
Requirement: the system must let a machine set `gitSigningKey` without editing tracked files.
AC: (1) `chezmoi init` prompts once for the signing key with an empty default; (2) `chezmoi edit-config` then `chezmoi apply` renders `[gpg] format = ssh` in `~/.gitconfig`; (3) README no longer mentions `~/.chezmoidata`.

**P-4 ★ Mac App Store apps install on first run (finish U-6).** Effort **S**.
AC: (1) on a fresh Mac signed into the App Store, the five `mas` apps install during the first `chezmoi apply`; (2) when signed out, the warning names the real cause and the documented recovery command actually re-runs the install.

**P-5 ★ Teaching workflow aliases (finish U-7 partially; cut mdbook).** Effort **S**.
Requirement: every command in README §"Flujo de Trabajo de Docencia" must exist.
AC: (1) `rec`, `teaching`, `projects`, `kctx` resolve in a fresh shell; (2) `agg` and `asciinema` are installed on both OSes; (3) mdbook is removed from the README (already removed from Brewfiles).

**P-6 ★ Multi-cloud claim honored or dropped (U-8) — needs Q-2.** Effort **S** either way.
If honored: AC (1) `az --version`, `gcloud --version` succeed after apply on macOS; (2) Starship shows `[azure]` subscription in a dir with `AZURE_*` env set. If dropped: README/CLAUDE.md say "GCP + AWS".

**P-7 Linux CI (U-9).** Effort **M**.
Requirement: the system must prove a Linux apply is at least syntactically and structurally valid on every push.
AC: (1) GitHub Actions job on `ubuntu-latest` runs `chezmoi init --source . --apply --dry-run --verbose` with prompt values supplied via `--promptString`; (2) shellcheck over rendered scripts; (3) `starship print-config` emits no warnings; (4) a `macos-latest` job renders templates for darwin.

**P-8 Neovim LSP with the native client (natural extension).** Effort **M**.
Problem: treesitter highlights `terraform`/`yaml`/`python`/`go` (`init.lua:95-98`) but there is no LSP — no diagnostics, no go-to-definition, for a Terraform/K8s-heavy user. Neovim 0.11+ ships `vim.lsp.config`/`vim.lsp.enable`, so no plugin is needed; mise already installs tool binaries (`terraform-ls`, `yaml-language-server` are in the mise registry).
AC: (1) opening a `.tf` file attaches `terraform-ls` (`:checkhealth vim.lsp`); (2) a YAML manifest gets schema diagnostics; (3) no new plugin-manager entries beyond an optional completion source.

**P-9 Unified package scripts (F-2) and Linux-safe gitconfig/nvim (F-3, F-4).** Effort **S–M**. AC: one packages script, one Homebrew script; `git fetch` over HTTPS on Linux prints no `osxkeychain` warning; `"+y` in nvim on Linux puts text on the system clipboard.

**P-10 Hooks that coexist (F-5).** Effort **S**. AC: (1) `pre-commit install` succeeds in a repo with `.pre-commit-config.yaml`; (2) gitleaks still blocks a staged secret in a repo *without* pre-commit.

**Open question, not a finding:** `~/.config/shell/api_keys.env` (`.zshrc:12-14`) exports every API key into every process of every interactive shell. `aws-vault` is already in `Brewfile.MacOS:2` and direnv is wired; per-directory or on-demand loading would shrink the blast radius. Whether that friction is acceptable is your call.

---

## 7. Looks bad but is actually fine

- **`config.ghostty` filename** — not a typo: Ghostty docs list `$XDG_CONFIG_HOME/ghostty/config.ghostty` before `config`; `ghostty +show-config` confirms `font-family = Hurmit Nerd Font Mono`, `theme = Afterglow` loaded. `verified`
- **`$env_var` followed by `$all` in `starship.toml:10-12`** — `$all` excludes explicitly listed modules; `starship prompt` with `STARSHIP_DISTRO=ZQZ` renders it exactly once. `verified`
- **`[kubernetes.context_aliases]` and every other Starship key** — `starship print-config` on 1.26.0 emits zero warnings; the CLAUDE.md caution about invalid keys is satisfied today. `verified`
- **`[shell_alias]` in mise config** — valid key (per project guidance); not flagged.
- **`uv "ruff"` / `uv "mdformat"` Brewfile lines** — `brew bundle` supports `--uv` (help text and manpage). `verified`
- **`--upgrade` in the darwin script (`:38,42`)** — flag exists; it just forces upgrade even when `HOMEBREW_BUNDLE_NO_UPGRADE` is set. Harmless.
- **`gitleaks protect`/`detect`** — still supported without deprecation output on 8.30.1 (`gitleaks git` is the newer form but no warning is printed). `verified`
- **`Include ~/.ssh/config.local` for a file that may not exist** — OpenSSH ignores non-matching Include globs; no error.
- **Three one-line `use_*` functions in `direnvrc`** — trivial wrappers, but they follow direnv's `use <thing>` convention and are documented; leave.
- **`.chezmoiignore:13-26` `.claude/*` runtime entries** — they name targets that aren't in the source, so they only quiet `chezmoi unmanaged`/guard `chezmoi add`. Harmless.
- **`~/.cargo/env` sourcing (`.zshrc:90-92`)** — guarded by `-f`; harmless whether or not mise's rust creates it.

---

## 8. Assumptions made

- **A-1** (Checkpoint 2, answered): `~/.claude/settings.json` stays machine-local; repo copy is deleted.
- **A-2** (Checkpoint 2, answered): repo pin moves to `terraform = "1.15.9"`; the live `flutter` entry is machine-local and belongs in an unmanaged `~/.config/mise/config.local.toml`, then `chezmoi apply` re-syncs the file (R-14 is fixed by the same apply).
- **A-3** `assumption`: `asciinema`/`vhs`/`agg` should be cross-platform (moved to the shared `Brewfile`) because the README presents the teaching flow as OS-agnostic. If teaching only ever happens on the Mac, leave them in `Brewfile.MacOS` and say so in README.
- **A-4** `assumption`: the Ghostty AppSupport symlink has no purpose beyond "load config on macOS", which the XDG path already does. If you rely on Ghostty's macOS "Open Config" menu writing to that path, keep it.
- **A-5** `assumption`: R-10 review candidates are listed, not recommended for removal; no usage data was available.
- **Q-1** (open): should `asciinema`/`vhs` be available on Linux? (A-3 assumes yes.)
- **Q-2** (open): keep the Azure claim and add `azure-cli` + `[azure]`, or drop Azure from the docs? P-6 is written both ways.

---

## 9. Roadmap (summary — full version in `ROADMAP.md`)

Scoring is RICE-style with reach = "every fresh machine / every shell start" vs "one file, once", confidence = the finding's tag, effort in T-shirt sizes.

| Horizon | Milestone | Items |
|---|---|---|
| **Now** | M1 · A fresh machine gets a working shell | U-5/F-1, U-4, R-4, U-1/P-2, U-2/P-3, F-3, F-4, U-10/R-1, U-11, R-3, C-1/C-2/C-5/C-9/C-11 doc fixes, A-2 pin bump |
| **Next** | M2 · One code path per OS, Linux proven | F-2, R-5, R-6, U-6/P-4, F-5/P-10, R-7, R-8, R-12, R-13, U-7/P-5, U-8/P-6 (after Q-2), F-6, P-7 CI |
| **Later** | M3 · Editor and toolbox depth | R-9, F-7, P-8 LSP, R-10/R-11 Brewfile trim, secrets-loading question |

Severity distribution for the record: 2 items that break a fresh machine outright (U-4, U-5), 4 that make a documented feature unreachable (U-1, U-2, U-6, U-7), the rest are cleanup, doc drift, and Linux-only defects. Nothing here argues for a rewrite; the repo is small, shellcheck-clean, and the fixes are line-sized.
