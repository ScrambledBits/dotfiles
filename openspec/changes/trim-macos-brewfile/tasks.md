## 1. Decide (owner) — mark keep or cut next to each

- [x] 1.1 `rabbitmq` (0 uses) — decide; if cut, delete the line. Verify by `grep -c rabbitmq Brewfile.MacOS`.
- [x] 1.2 `cocoapods` (0 uses; pairs with machine-local `flutter`) — decide; default cut. Verify the line is gone or a comment states the reason.
- [x] 1.3 `tectonic` (0 uses) — decide. Verify as above.
- [x] 1.4 `aws-vault` (0 uses; README:98 advertises it) — decide; if cut, also remove it from README:98. Verify `grep -n aws-vault README.md Brewfile.MacOS` agree.
- [x] 1.5 `llmfit` (2 uses), `openai-whisper` (1 use), `poppler` (no dependents) — decide each. Verify the file reflects the decisions.
- [x] 1.6 Casks `dbeaver-community`, `mysqlworkbench`, `pgadmin4` (three DB clients) — decide which stay. Verify.
- [x] 1.7 Nerd Font casks: keep `font-hurmit-nerd-font`; decide the other 13. Verify the remaining list matches what Ghostty or other apps reference.

## 2. Record

- [x] 2.1 Add the decisions as one CHANGELOG bullet per cut line (and "kept: …" for the rest); verify the CHANGELOG entry and `Brewfile.MacOS` agree line for line.

## 3. Verification

- [x] 3.1 `brew bundle check --file=Brewfile.MacOS` passes on this machine; CI green.
