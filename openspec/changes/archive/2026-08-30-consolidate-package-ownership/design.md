## Context

See proposal.md. Homebrew's bundle `uv` handler (`bundle/extensions/extension.rb` `ensure_package_manager_installed!`) runs `brew install --formula uv` when `uv` is not on brew's PATH — mise's uv never is. mise 2026.8 lists `ruff` in its registry (`aqua:astral-sh/ruff`) and exposes a `pipx` backend (`mise backends`).

## Goals / Non-Goals

**Goals:** one uv on the machine; a written rule the next Brewfile edit can follow.

**Non-Goals:** migrating brew formulae that mise could also install (`tmux`, `cloudflared`, `gh`…) — brew is the right owner for unversioned system tools; deciding which out-of-scope apps to keep (see `trim-macos-brewfile`).

## Decisions

- **mise `pipx:` backend for mdformat/nano-pdf** over `uv tool install` in a new `run_onchange` script: uses the existing mise-tools script, no new file. mise's pipx backend delegates to `uvx`/`uv` when available (mise docs); if a machine lacks it, `mise settings pipx.uvx=true` is the switch. Alternative: keep the `uv` lines and accept brew uv — rejected, it contradicts the recorded intent (CHANGELOG:14).
- **`ruff` as a core mise tool** (registry entry) rather than `pipx:ruff`: pre-built binary, no Python needed.
- **Header-comment rule, not tooling**: the rule is one sentence; a lint would be over-engineering for a personal repo.

## Risks / Trade-offs

- [`pipx:` backend behaviour differs across mise versions] → verify with `mise ls` after `mise install`; fall back to `uv tool install` in the mise script if needed.
- [Existing machines keep brew uv until someone uninstalls it] → documented machine step in tasks; harmless meanwhile (mise's uv shadows it on `PATH`).
