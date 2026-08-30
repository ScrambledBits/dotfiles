## Why

`CHANGELOG.md` stops at 2026-07-09 although the largest change in the repo's history (`161c53f`, PR #2, 2026-08-29) landed since; the CI workflow added in that PR is mentioned in neither README nor CLAUDE.md's Repository Map; README:84 says `Brewfile.MacOS` holds "taps y formulas macOS-específicos" but it contains no `tap` line (audit 2026-08-30: D-1, D-2, C-3).

## What Changes

- `CHANGELOG.md`: add a `## 2026-08-29` entry summarising PR #2 (fresh-machine bootstrap fixes, OMZ external, `paths.tmpl`, `promptStringOnce` signing key, hooks chaining, SSH kex, treesitter `main`, CI, docs). Add a `## 2026-08-30` entry as the OpenSpec changes land.
- `README.md`: one line for `.github/workflows/chezmoi-dry-run.yml` (what it checks); fix the `Brewfile.MacOS` row wording in §"Estructura de Paquetes".
- `CLAUDE.md`: add the workflow to the Repository Map.

## Capabilities

### New Capabilities
- (none — documentation only; `skip_specs: true`)

### Modified Capabilities
- (none)

## Impact

`CHANGELOG.md`, `README.md:81-86`, `CLAUDE.md` Repository Map. No behaviour change.
