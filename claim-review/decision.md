# Claim Panel Decision — AUDIT_REPORT.md

Source: `AUDIT_REPORT.md` (2026-08-28), normalized into 33 claim records (`claims.json`) plus one open question with no proposed fix. Panel: **3 independent judges**, spawned in parallel, each seeing only the claims and its own charter — (1) Performance impact, (2) Correctness & regression risk (veto holder), (3) Maintainability & complexity cost. Each judge reviewed all 33 claims in one pass. Raw votes: `votes.json`.

Result: **29 IMPLEMENT · 0 REJECTED · 4 BLOCKED (1 by veto) · 1 needs a proposed fix · 0 MALFORMED.** No vote was downgraded — all 99 votes cited file paths, tool output, or official docs. Judge 2 (correctness) confirmed all three judges' evidence independently and found two errors *in the audit's proposed fixes* (see refactor-005 and unimplemented-006); those corrections are folded into the entries below.

> **Before the next `chezmoi apply`:** `chezmoi managed` now lists `claim-review/` as well as the three audit files. Add `claim-review/**` to `.chezmoiignore` alongside them (unimplemented-011), or the panel outputs deploy into `$HOME`.

---

## IMPLEMENT

Ranked by payoff relative to effort. Tally is implement–reject–needs_info.

### Tier 1 — fixes a broken fresh-machine bootstrap (S each)

**1. unimplemented-005 · Homebrew never on PATH from managed files — 3–0–0**
Fix: template `BREW_PREFIX` per OS/arch in `dot_config/shell/paths`, prepend `$BREW_PREFIX/bin:$BREW_PREFIX/sbin`, delete the `brew --prefix` fork at `dot_zshrc.tmpl:26`, guard the four `eval "$(… init zsh)"` lines with `command -v`; README: add `eval "$(/opt/homebrew/bin/brew shellenv)"` between steps 1 and 2.
All three judges verified the only PATH source is the unmanaged `~/.zprofile:43`. Judge 1 measured `brew --prefix` at ~14 ms per shell, so the deletion is a real per-shell saving. Judge 2 asks for one guard to avoid a regression on non-standard prefixes: `[[ -x $BREW_PREFIX/bin/brew ]] || BREW_PREFIX=$(brew --prefix)`. Judge 3 notes the guard pattern already exists at `:101` (fzf), so this is uniformity, not new cleverness.

**2. unimplemented-004 · Oh My Zsh is never installed — 3–0–0**
Fix: `.chezmoiexternal.toml` archive entry (`stripComponents = 1`, `refreshPeriod = "168h"`); drop the `zstyle ':omz:update'` lines.
Verified by all judges: no Brewfile, script, or README step installs OMZ; `dot_zshrc.tmpl:66` sources it unconditionally. Judge 2's regression note: on this machine `~/.oh-my-zsh` is a git clone, so an `exact = true` external will replace `.git` and wipe `~/.oh-my-zsh/cache` on every apply — add `.oh-my-zsh/cache` and `.oh-my-zsh/custom/**` to `.chezmoiignore`. Dropping the updater zstyles is safe because OMZ's `check_for_upgrade.sh:27-35` no-ops when `$ZSH` is not a git repo.

**3. unimplemented-001 · OS icon renders empty — 3–0–0**
Fix: delete the `STARSHIP_DISTRO` export and `[env_var.STARSHIP_DISTRO]`; enable `[os]`.
All judges reproduced the empty template bytes (`xxd`); Judge 2 traced it to commit `37a3568` — the line was born empty. Implementation caveat from Judge 2: `$os` sits near the end of `$all`, so also replace `$env_var` with `$os` in the `format` string (and set `os.symbols` if Nerd glyphs are wanted instead of the default emoji) or the icon moves to the end of the prompt.

**4. unused-004 · mise activated twice per shell — 3–0–0**
Fix: delete `dot_zshrc.tmpl:83-84`.
The OMZ `mise` plugin (enabled at `:61`) already runs the identical eval, with a `$+commands[mise]` guard the `.zshrc` copy lacks. Judge 1 measured ~23 ms per `mise activate zsh`. Judge 2's only dependency note: this relies on OMZ being present, i.e. item 2.

**5. refactor-003 · `osxkeychain` and OMZ `macos` plugin unconditional — 3–0–0**
Fix: wrap `dot_gitconfig.tmpl:92-93` and `dot_zshrc.tmpl:59` in `{{ if eq .chezmoi.os "darwin" }}`.
Judge 2 confirmed the OMZ macos plugin has no `OSTYPE` guard of its own. Judge 3: reuse the exact conditional already in `dot_ssh/config.tmpl:8-11`; skip the optional Linux `cache` helper (YAGNI). Zero effect on macOS.

**6. refactor-004 · nvim clipboard wrong on Linux — 3–0–0**
Fix: `clipboard = "unnamedplus"`.
One-token change; Judge 2 verified macOS maps both `*` and `+` to pbcopy, so behavior is identical there.

**7. unimplemented-011 · README.md / CLAUDE.md deployed into `$HOME` — 3–0–0**
Fix: add `README.md`, `CLAUDE.md`, `AUDIT_REPORT.md`, `ROADMAP.md`, `audit_findings.json` — **and `claim-review/**`** (Judges 2 and 3) — to `.chezmoiignore`; remove the stray `~/README.md` and `~/CLAUDE.md`.
All judges observed that this very session loaded `/Users/admin/CLAUDE.md` as project instructions. Judge 1 frames it as a per-session token cost; Judge 3 as five ignore lines.

**8. unimplemented-002 · `~/.chezmoidata/local.toml` mechanism does not exist — 3–0–0**
Fix: `gitSigningKey = {{ promptStringOnce . "gitSigningKey" "SSH signing key (empty to skip)" "" | quote }}`; delete `.chezmoiignore:5-6`; README → `chezmoi edit-config`.
Verified against chezmoi docs by all three (source-state only). Judge 2 checked the `promptStringOnce` signature accepts a default and that existing machines get re-prompted exactly once for the new key. Judge 3: same pattern as the four adjacent prompts.

### Tier 2 — dead code, wrong docs, small policy fixes (S each)

**9. unused-006 · Linux script: dead cask/mas filter, box-wide `brew upgrade`, hard-fail — 3–0–0**
Fix: delete the grep filters and `brew upgrade`; add `|| true`.
All three confirmed `Brewfile` has zero `cask`/`mas` lines and `brew bundle` upgrades by default. Judge 2: the only behavior change is Linux going from abort-on-one-formula to warn, matching darwin.

**10. unimplemented-006 · mas apps never install on first run; README recovery is a no-op — 3–0–0**
Fix: separate `run_onchange_after_install-mas-apps.sh.tmpl` that runs after brew; fix the warning; fix the README.
**Correction from Judge 2:** the audit's recovery command is wrong — `run_onchange_` state lives in the **`entryState`** bucket (`scriptState` is only for `run_once_`), so document `chezmoi state delete-bucket --bucket=entryState`. Judge 3 prefers reordering inside the existing script (bundle non-mas lines, then mas lines if signed in) over a fourth script file; either is acceptable, the reorder is smaller.

**11. unimplemented-010 · `private_dot_claude/settings.json` never deployed — 3–0–0**
Fix: delete `private_dot_claude/`; fix `CLAUDE.md:17,43`; keep the ignore line.
Judge 2 confirmed deleting the source does not touch `~/.claude` (chezmoi never removes targets without `.chezmoiremove`), so the live hooks are safe.

**12. doc_gap-002 · CLAUDE.md "no plugin manager"; TF pin drift — 3–0–0**
Fix: fix `CLAUDE.md:26`; `terraform = "1.15.9"`; move the live `flutter` entry to `~/.config/mise/config.local.toml`.
Judge 2 verified mise loads `config.local.toml` and that the next apply would otherwise silently revert 1.15.9 and delete flutter — this is protective, do it before the next apply.

**13. doc_gap-001 · README contradicts code on theme, versions, casks, asciinema scope — 3–0–0**
Fix: rewrite the shell line, drop or replace the versions table, fix the Brewfile table. Judge 3: delete the table outright — mise pins `latest` almost everywhere, so any table rots.

**14. unimplemented-007 · README aliases/tools that don't exist — 3–0–0**
Fix: add `kctx`, `projects`, `teaching`, `rec`; add `agg`, `asciinema`, `vhs` to the shared Brewfile; drop mdbook from README.
Judge 2 verified `brew info agg` (1.9.0) and that asciinema/vhs exist on Linuxbrew.

**15. unused-003 · `.chezmoiignore` lines that can never match — 3–0–0.** Delete lines 5-6 and 39. Zero-risk per all three.

**16. unused-005 · dead `brew shellenv` after install in both bootstrap scripts — 3–0–0.** Delete 14 lines; Judge 2 confirmed the package scripts redo shellenv themselves.

**17. unused-008 · `dot_vscode/argv.json` ships only a default and a per-install UUID — 3–0–0.** Delete; Judge 2: VS Code regenerates the file if absent. Judge 3: also drop the now-dead `.vscode` ignore lines rather than adding a `.vscode/**` rule.

**18. unused-007 · Ghostty AppSupport symlink loads the same file twice — 3–0–0.** Delete `private_Library/` and the `Library/**` ignore block. Judge 2 confirmed via docs and `ghostty +show-config | sort | uniq -d` (Ghostty 1.3.1); Judge 1 notes only `font-family*` keys actually duplicate, so the report's "every key twice" is overstated but the double load is real.

**19. unused-012 · SSH host blocks restate `Host *` — 3–0–0.** Trim to `User git` + `PreferredAuthentications`; `ssh -G` output identical before and after per Judges 1 and 2.

**20. unused-013 · stale comments — 3–0–0.** Comment-only.

**21. unimplemented-003 · unused `timezone` prompt — 3–0–0.** Remove; Judge 3 vetoes the "or use it via `TZ`" alternative as speculative.

**22. unused-011 · `gemini-cli` formula deprecated — 3–0–0.** Judge 2 pulled the dates: deprecated 2026-06-18, **disable date 2026-12-18** — after that `brew bundle` fails on `Brewfile.MacOS:5`. Move to mise (`npm:@google/gemini-cli`) or drop.

**23. unused-009 · `Comment.nvim` duplicates built-in `gc` — 3–0–0.** Judge 2's caveat: you lose `gb` (blockwise) and `gco/gcO/gcA`; accept knowingly.

**24. refactor-006 · SSH kex pin drops post-quantum defaults — 3–0–0**
Fix: **delete the `KexAlgorithms` line** (not the hardcoded PQ list). Judge 2 verified that an unknown kex name is fatal (`Bad SSH2 KexAlgorithms`), so a pinned `mlkem768…` list would break every ssh invocation on an older Linux client such as Ubuntu 22.04's OpenSSH 8.9. Judge 3 independently prefers deletion as the lowest-maintenance option.

**25. unused-010 · Brewfile duplicates + out-of-scope entries — 3–0–0 (dedupe only)**
All three implement the *dedupe* (3 Docker extensions → `ms-azuretools.vscode-containers`, 1 CSV extension, 1 Monaspace) and all three say the out-of-scope apps (rabbitmq, cocoapods, DB GUIs, ollama, whisper…) are an owner decision, not an audit cut. Judge 2: removing Brewfile lines never uninstalls anything (no `brew bundle cleanup` runs), so the dedupe is zero-risk.

**26. refactor-001 · inconsistent `command -v` guards, `brew --prefix` fork — 3–0–0.** Same change set as items 1 and 4; listed separately because the audit did. Judge 3: only three new guards are needed since the OMZ mise plugin already guards mise.

**27. doc_gap-003 · README omits mise tasks, keymaps, git aliases, paths file — 3–0–0.** Judge 3's shaping: add the 4-row mise-tasks table (high value) and a one-line pointer to the source files for keymaps/aliases rather than duplicating lists that will rot.

### Tier 3 — larger or contested (M)

**28. unimplemented-009 · Linux CI — 3–0–0 (M)**
Fix: GitHub Actions on `ubuntu-latest` + `macos-latest` running `chezmoi init --source . --apply --dry-run --verbose` with `--promptString` per key.
Two implementation notes shared by Judges 1 and 2: `--dry-run` does **not** execute `run_` scripts, so shellcheck must run against `chezmoi cat`/`execute-template` output to cover the Linux-only defects. Judge 3 asks to keep it to a ~20-line smoke test and skip extra stages unless they prove cheap.

**29. refactor-002 · merge the OS-split package and Homebrew scripts — 2–1–0 (M)**
Passes on majority, with a substantive dissent. Judges 1 and 2 verified the divergence and Judge 2 confirmed the rename is safe (run_once state is content-hashed, both scripts are idempotent, ordering by stripped name is preserved). **Judge 3 rejects:** the scripts differ in five places, the merged file would interleave shell with `{{ if }}` blocks — harder to read than two plain per-OS files, which is chezmoi's idiomatic layout — and the only real defect (policy drift) is already fixed by item 9 in three lines. Recommendation: do item 9 first; revisit this merge only if the scripts diverge again.

---

## REJECTED

None. No claim reached a reject majority.

---

## BLOCKED / NEEDS INFO

**refactor-005 · global `core.hooksPath` breaks `pre-commit`/`commitlint` — 2–0–1, VETOED by Judge 2**
The *problem* is confirmed by all three (Judge 3 reproduced `pre-commit install` refusing in a scratch repo). The *fix as written* is vetoed: option A chains to `$(git rev-parse --git-path hooks)/pre-commit`, but `--git-path hooks` **honors `core.hooksPath`** (verified: `git -c core.hooksPath=/tmp/xhooks rev-parse --git-path hooks` → `/tmp/xhooks`, git 2.50.1), so the global hook would exec itself in an infinite loop on every commit. Chaining also does not lift pre-commit's install refusal, which checks the config value, not the hook. Judge 3 reached the same conclusion from the maintainability side.
**Unblocks it:** rewrite the proposed fix as option B only — drop `core.hooksPath` from `dot_gitconfig.tmpl:17` and run gitleaks per repo via pre-commit (accepting the loss of a global scan) — or, if a global hook must stay, chain to `$(git rev-parse --git-dir)/hooks/pre-commit` and document that `pre-commit install -f` / a per-repo `core.hooksPath` override is still required. Then re-submit.

**unimplemented-008 · Azure/GCP tooling claim — 1–0–2**
Judges 1 and 2 vote needs_info on the same missing item: **the owner's answer to Q-2** (keep the Azure claim and add tooling, or drop it from the docs). Judge 1 notes the two branches differ in cost — sourcing `google-cloud-sdk` completion adds tens of ms to every shell start, the docs-only branch costs nothing. Judge 2 adds that the cask is now named **`gcloud-cli`** (`google-cloud-sdk` resolves to it) and installs under `$(brew --prefix)/share/google-cloud-sdk`, matching the existing `.zshrc:125-128` path. Judge 3 would implement the KISS branch (doc edit + gcloud cask, defer Azure).
**Unblocks it:** answer Q-2.

**feature-001 · Neovim LSP via native client — 1–0–2**
Judge 2 implements (additive; guard each `vim.lsp.enable` with `vim.fn.executable`). Judges 1 and 3 need the same fact: **is nvim actually used for IaC/K8s editing?** Judge 3 points out the Brewfile installs VS Code with terraform/python/go/pylance extensions (`Brewfile:55,64,70-72`), suggesting nvim is the git/quick editor; Judge 1 notes four language servers are a net resource cost (pyright and yaml-language-server are Node processes, gopls is memory-heavy) with no performance upside.
**Unblocks it:** confirm nvim is the primary editor for `.tf`/YAML/Python/Go, and name which servers are wanted.

**refactor-007 · nvim-treesitter `master` → `main` — 1–1–1**
No majority. Judge 2 implements (deferred, own change, needs tree-sitter CLI + C compiler in the Brewfile). Judge 3 rejects (the pin is documented as deliberate, works on 0.12.5, and the proposal itself says "Later" — wait until master actually fails). Judge 1 needs the rewritten block before it can judge.
**Unblocks it:** either a trigger (master breaks on a Neovim upgrade) or a concrete rewritten `init.lua:88-102` submitted as its own claim.

**open-001 · `api_keys.env` exported into every process (AUDIT_REPORT §6 open question) — not judged**
Coherent concern, no proposed fix; routed here per the rules. **Unblocks it:** a concrete proposal (e.g. `aws-vault exec` for AWS, direnv `.envrc` per project, or `op run`), then submit as a claim.

---

## Remaining work

Effort: S = minutes to an hour, M = an afternoon. Order follows the ranking above; items 12 and 7 are time-sensitive (they prevent the next `chezmoi apply` from clobbering live state or deploying audit files into `$HOME`).

- [ ] **S** Bump `terraform = "1.15.9"`, move live `flutter` to `~/.config/mise/config.local.toml`, fix `CLAUDE.md:26` (doc_gap-002) — *do before the next apply*
- [ ] **S** Add `README.md`, `CLAUDE.md`, `AUDIT_REPORT.md`, `ROADMAP.md`, `audit_findings.json`, `claim-review/**` to `.chezmoiignore`; delete `~/README.md`, `~/CLAUDE.md` (unimplemented-011) — *do before the next apply*
- [ ] **S** Template `BREW_PREFIX` per OS/arch in `dot_config/shell/paths` with `brew --prefix` fallback; prepend bin/sbin; delete `.zshrc:26`; guard starship/direnv/zoxide evals; README shellenv step (unimplemented-005, refactor-001)
- [ ] **S** `.chezmoiexternal.toml` for Oh My Zsh; ignore `.oh-my-zsh/cache`, `.oh-my-zsh/custom/**`; drop `zstyle ':omz:update'` lines (unimplemented-004)
- [ ] **S** Delete `.zshrc:83-84` duplicate mise eval (unused-004)
- [ ] **S** Remove `STARSHIP_DISTRO` export + `[env_var.STARSHIP_DISTRO]`; enable `[os]`; replace `$env_var` with `$os` in `format`; set `os.symbols` if Nerd glyphs wanted (unimplemented-001)
- [ ] **S** Darwin-guard `credential.helper = osxkeychain` and the OMZ `macos` plugin (refactor-003)
- [ ] **S** `clipboard = "unnamedplus"` (refactor-004)
- [ ] **S** `gitSigningKey` via `promptStringOnce` with `""` default; delete `.chezmoiignore:5-6`; README → `chezmoi edit-config` (unimplemented-002)
- [ ] **S** Linux packages script: drop grep filters and `brew upgrade`; add `|| true` (unused-006)
- [ ] **S** mas: reorder so mas lines run after brew has installed `mas` (or split script); fix warning text; README recovery = `chezmoi state delete-bucket --bucket=entryState && chezmoi apply` (unimplemented-006)
- [ ] **S** Delete `private_dot_claude/`; fix `CLAUDE.md:17,43` (unimplemented-010)
- [ ] **S** README truth pass: Starship not robbyrussell, drop versions table, no casks in `Brewfile`, asciinema/vhs scope (doc_gap-001)
- [ ] **S** Add `kctx`/`projects`/`teaching`/`rec` aliases; `agg`, `asciinema`, `vhs` to shared `Brewfile`; drop mdbook from README (unimplemented-007)
- [ ] **S** Delete `.chezmoiignore:5-6,39` (unused-003)
- [ ] **S** Delete dead `brew shellenv` blocks in both homebrew scripts (unused-005)
- [ ] **S** Delete `dot_vscode/` and its two ignore lines (unused-008)
- [ ] **S** Delete `private_Library/` and the `Library/**` ignore block; fix `CLAUDE.md:59` (unused-007)
- [ ] **S** Trim GitHub/GitLab SSH blocks to `User` + `PreferredAuthentications` (unused-012)
- [ ] **S** Fix stale comments in `.zshrc:7` and `init.lua` (unused-013)
- [ ] **S** Remove the `timezone` prompt and its CLAUDE.md mention (unimplemented-003)
- [ ] **S** Replace `gemini-cli` brew formula (disable date 2026-12-18) with mise `npm:@google/gemini-cli` or drop (unused-011)
- [ ] **S** Delete `Comment.nvim` line (unused-009)
- [ ] **S** Delete the `KexAlgorithms` line in `dot_ssh/config.tmpl` (refactor-006)
- [ ] **S** Brewfile dedupe: one Docker extension, one CSV extension, one Monaspace; list the out-of-scope apps for owner review (unused-010)
- [ ] **S** README: 4-row mise-tasks table + pointers to keymaps/aliases source (doc_gap-003)
- [ ] **M** GitHub Actions dry-run on ubuntu + macos; shellcheck rendered scripts; starship print-config warning-free (unimplemented-009)
- [ ] **M** *(contested 2–1)* Merge OS-split scripts — only if they diverge again after the item above (refactor-002)

Blocked, awaiting input: refactor-005 (rewrite fix — see veto), unimplemented-008 (answer Q-2), feature-001 (confirm nvim is the IaC editor), refactor-007 (trigger or concrete rewrite), open-001 (propose a fix).
