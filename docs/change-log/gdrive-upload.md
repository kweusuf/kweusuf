# Change Log: gdrive-upload

## `adf69aaa` — Add Google Drive PDF upload via rclone

**Timestamp:** 2026-07-08T21:35:49

### What changed

Added a workflow step that uploads `resume.pdf` to Google Drive after building, replacing the existing file by ID (`191t9WDPxvc-tl4gKenMbwUbahvO4RymU`) using `rclone backend copyid`. This preserves the existing share link. The step is skipped silently if the `RCLONE_CONFIG` GitHub secret is not configured. Updated `RESUME-AUTOMATION-README.md` with rclone setup instructions and troubleshooting.

### Why (justification)

The user shares their resume PDF via a Google Drive link in many places. Now that the PDF is built from source (not downloaded from Drive), we need to push updates back to keep the shared link valid. Replacing by file ID means the share URL never changes.

### Alternatives considered

- **Google Drive API via gcloud SDK**: Heavier setup (GCP project, service account, OAuth scopes). rclone is simpler — single config file, one command.
- **Upload as new file + delete old**: Would change the file ID and break the share link. `backend copyid` replaces content in-place.
- **Skip Google Drive, serve from GitHub Pages**: Would require changing all places where the Drive link is shared. Not the user's workflow.

### Review notes

The `RCLONE_CONFIG` secret must contain the full `~/.config/rclone/rclone.conf` content. The remote must be named `gdrive`. Token may expire if unused for 6 months — re-run `rclone config` to refresh.

## `76510cdd` — Add Google Drive PDF upload via rclone

**Timestamp:** 2026-07-08T21:37:51

**Files changed:**

```text
.github/workflows/build-and-preview.yml | 15 +++++++++++++++
 RESUME-AUTOMATION-README.md             | 15 ++++++++++++++-
 docs/change-log/gdrive-upload.md        | 23 +++++++++++++++++++++++
 3 files changed, 52 insertions(+), 1 deletion(-)
```

**What changed:** Same as `adf69aaa` — amend added the change-log file to the commit. No code changes.

**Why (justification):** Moved from `main` branch to dedicated `gdrive-upload` branch per user request. Renamed change-log from `main.md` to `gdrive-upload.md`.

**Alternatives considered:** None — branch management only.

**Review notes:** No functional change from previous commit.

## WIP notes

Fixed markdown lint warnings in change-log. `docs/change-log/main.md` is an untracked leftover from the branch switch — not part of this branch's work. Implementation complete, ready to push and merge.

## `08f04221` — Fix Google Drive upload: use Drive API instead of rclone copyid

**Timestamp:** 2026-07-09T11:24:26

**Files changed:**

```text
.github/workflows/build-and-preview.yml | 35 ++++++++++++++++++++++++++++-----
 RESUME-AUTOMATION-README.md             |  6 ++++--
 docs/change-log/gdrive-upload.md        | 25 +++++++++++++++++++++++
 3 files changed, 59 insertions(+), 7 deletions(-)
```

**What changed:** Replaced the `rclone backend copyid` approach with a direct Google Drive API call. The workflow now extracts the `refresh_token` from the `RCLONE_CONFIG` secret, gets a fresh access token via the OAuth2 token endpoint, and uses `curl` to PATCH the file content via `https://www.googleapis.com/upload/drive/v3/files/{id}?uploadType=media`. No rclone installation needed in CI — uses `curl` and `python3` (both available on `ubuntu-latest`).

**Why (justification):** `rclone backend copyid` copies files *within* Google Drive — it cannot upload a local file to replace an existing Drive file by ID. The Google Drive API's PATCH upload endpoint replaces file content in-place, preserving the file ID and share link.

**Alternatives considered:**

- **rclone copyto with folder path**: Requires knowing the parent folder path. Would create a new file if the path is wrong, breaking the share link.
- **rclone with --drive-root-folder-id**: Sets the root to the parent folder, but still can't target a specific file ID for replacement.
- **Install rclone in CI just for the config parsing**: Overkill — the only thing we need from the config is the `refresh_token`, which is a one-line grep.

**Review notes:** The OAuth client credentials (`client_id`/`client_secret`) are rclone's default public credentials, not a secret. The `refresh_token` in `RCLONE_CONFIG` is the actual secret. Tokens may expire if unused for 6 months — re-run `rclone config` locally to refresh.

## `88764d8c` — Fix markdown lint warnings in change-log

**Timestamp:** 2026-07-09T11:25:13

**Files changed:**

```text
docs/change-log/gdrive-upload.md | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)
```

**What changed:** Added blank lines around headings (MD022), language tag to fenced code block (MD040), blank lines around fences (MD031), removed consecutive blank lines (MD012).

**Why (justification):** Markdown lint warnings — no functional change, documentation formatting only.

**Alternatives considered:** None — cosmetic fix.

**Review notes:** No code changes.

## `46ebcefd` — Fix Google Drive upload: use rclone copy with root folder ID

**Timestamp:** 2026-07-09T11:35:08

**Files changed:**

```text
.github/workflows/build-and-preview.yml | 42 ++++++++++-----------------------
 1 file changed, 12 insertions(+), 30 deletions(-)
```

**What changed:** Replaced the OAuth token refresh approach with direct rclone usage. The workflow now installs rclone in CI, sets up the config from `RCLONE_CONFIG` secret, extracts the remote name dynamically, and uses `rclone copy resume.pdf <remote>:/ --drive-root-folder-id 1196dOMXtqi022tHjQIhle17Wj0rPfq74`. rclone handles token refresh automatically. The file is renamed to `Resume_Eusuf_Kanchwala_Backend_Java_Go.pdf` before upload so rclone matches and replaces the existing file by name.

**Why (justification):** The previous approach used hardcoded rclone OAuth client credentials to refresh the token via curl, but the credentials aren't stored in the rclone config — they're compiled into the binary. The refresh failed with `KeyError: 'access_token'`. Using rclone directly avoids this entirely since it handles token refresh internally.

**Alternatives considered:**

- **Fix the OAuth credentials**: Would require finding rclone's current default client_id/client_secret from source code. Fragile — credentials change across rclone versions.
- **Custom Google OAuth app**: User would need to create a GCP project, enable Drive API, create OAuth credentials. Too much setup for a personal project.
- **Google Drive API via curl with user-provided credentials**: Requires user to store client_id and client_secret as separate secrets. More complex than needed.

**Review notes:** The parent folder ID (`1196dOMXtqi022tHjQIhle17Wj0rPfq74`) is hardcoded in the workflow. If the file moves to a different folder on Google Drive, this ID needs to be updated. rclone's `copy` command replaces files with matching names in the target folder — verified that the file ID (`191t9WDPxvc-tl4gKenMbwUbahvO4RymU`) is preserved after replacement.

## `a3706ddb` — Fill in change-log for rclone upload fix

**Timestamp:** 2026-07-09T11:36:32

**Files changed:**

```text
docs/change-log/gdrive-upload.md | 42 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)
```

**What changed:** Populated the hook-appended skeleton fields for commit `46ebcefd` with concrete detail — the OAuth approach failure, why rclone was chosen, and the parent folder ID caveat.

**Why (justification):** Hook requires populated fields on every commit.

**Alternatives considered:** None — documentation only.

**Review notes:** No code changes.

## `6e8f41c7` — Fix RCLONE_CONFIG parsing: handle literal newlines in secret

**Timestamp:** 2026-07-09T11:41:02

**Files changed:**

```text
.github/workflows/build-and-preview.yml | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)
```

**What changed:** Changed `echo "$RCLONE_CONFIG" > ~/.config/rclone/rclone.conf` to `printf '%b' "$RCLONE_CONFIG" > ~/.config/rclone/rclone.conf`. Also changed remote name extraction to read from the written config file instead of the raw secret value.

**Why (justification):** GitHub Actions secrets store multiline values with literal `\n` escape sequences. `echo` writes these literally, producing a single-line config file that rclone can't parse (treats the entire value as a filename). `printf '%b'` converts escape sequences to real newlines.

**Alternatives considered:**

- **Use a base64-encoded secret**: Encode the config as base64, decode in CI. Cleaner but adds an extra step for the user.
- **Use separate secrets for each config field**: More granular but more complex setup.
- **Use GitHub environment files**: `echo "RCLONE_CONFIG<<EOF" >> $GITHUB_ENV` approach — more verbose.

**Review notes:** If the secret is stored with actual newlines (not escaped), `printf '%b'` still works correctly — it preserves real newlines and only converts escape sequences. This fix is backward-compatible.
## `b4a8f1af` — Fix lint warnings in change-log

**Timestamp:** 2026-07-09T11:42:08

**Files changed:**

```text
docs/change-log/gdrive-upload.md | 41 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)
```

**What changed:** Added blank lines around headings and code blocks (MD022, MD031), removed consecutive blank lines (MD012), added language tags to fenced code blocks (MD040).

**Why (justification):** Markdown lint warnings — formatting only, no functional change.

**Alternatives considered:** None — cosmetic fix.

**Review notes:** No code changes.

## `1ca81d13` — Fill in change-log skeleton for lint-fix commit

**Timestamp:** 2026-07-09T11:51:40

**Files changed:**

```text
docs/change-log/gdrive-upload.md | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)
```

**What changed:** Populated the hook-appended skeleton for commit `b4a8f1af` with concrete detail about the lint fixes.

**Why (justification):** Hook requires populated fields on every commit.

**Alternatives considered:** None — documentation only.

**Review notes:** No code changes.

## `6400bdd8` — Fix RCLONE_CONFIG parsing: use Python for reliable multiline handling

**Timestamp:** 2026-07-09T11:55:30

**Files changed:**

```text
.github/workflows/build-and-preview.yml | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)
```

**What changed:** Replaced `printf '%b'` with Python's `os.environ['RCLONE_CONFIG']` to write the rclone config file. Python reads the environment variable as-is, handling both literal `\n` escape sequences and actual newlines correctly. Also added error handling for missing remote name extraction.

**Why (justification):** Both `echo` and `printf '%b'` failed because GitHub Actions passes multiline secrets as raw strings — the shell treats the entire value (including newlines) as part of the file path argument. Python's `os.environ[]` reads environment variables as strings without shell interpretation, writing them to a file byte-for-byte.

**Alternatives considered:**

- **Base64-encode the secret**: User would need to `base64 ~/.config/rclone/rclone.conf` and store the encoded value. Extra step, but more robust.
- **Use GitHub environment files**: `echo "RCLONE_CONFIG<<EOF" >> $GITHUB_ENV` with heredoc — more verbose and error-prone.
- **Use rclone's `--config` flag with stdin**: Pipe the config content directly. Would work but adds complexity.

**Review notes:** The Python snippet uses `os.environ['RCLONE_CONFIG']` which will raise `KeyError` if the variable is empty — but the `if [[ -z "$RCLONE_CONFIG" ]]` check above handles that case first.

## `bc43f51a` — Fill in change-log for Python config fix

**Timestamp:** 2026-07-09T11:56:44

**Files changed:**

```text
docs/change-log/gdrive-upload.md | 42 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)
```

**What changed:** Populated the hook-appended skeleton for commit `6400bdd8` with detail about the Python-based config file approach.

**Why (justification):** Hook requires populated fields on every commit.

**Alternatives considered:** None — documentation only.

**Review notes:** No code changes.

## `8222993b` — Add debugging and explicit --config flag for rclone

**Timestamp:** 2026-07-09T12:02:10

**Files changed:**

```text
.github/workflows/build-and-preview.yml | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)
```

**What changed:** Added debug output to the upload step: prints config file size and first 3 lines after writing, prints the extracted remote name before uploading. Added explicit `--config "$CONFIG_FILE"` flag to the rclone command to ensure it reads from `~/.config/rclone/rclone.conf` and not from a file in the working directory.

**Why (justification):** The `Failed to load config file` error persists even after switching from `printf` to Python. The error shows rclone treating the config content as a filename, suggesting it's not finding the config file we wrote. The `--config` flag forces rclone to use the correct path. Debug output will reveal whether the file is written correctly and what remote name is extracted.

**Alternatives considered:**

- **Skip rclone entirely, use curl with Drive API**: Requires correct OAuth client credentials, which are hardcoded in the rclone binary and change across versions. Harder to maintain.
- **Base64-encode the secret**: User would run `base64 ~/.config/rclone/rclone.conf` and store the encoded value. Workflow decodes it. More robust but adds setup complexity.

**Review notes:** The `--config` flag is the key fix — rclone may be reading a config from the current directory (the repo root) instead of `~/.config/rclone/`. Debug output will be visible in CI logs for troubleshooting.

## `3f20a6bf` — Fill in change-log for debug/flag commit
**Timestamp:** 2026-07-09T12:03:34

**Files changed:**
```
docs/change-log/gdrive-upload.md | 41 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)
```

**What changed:** Populated the hook-appended skeleton for commit `8222993b` with detail about the debug output and explicit `--config` flag.

**Why (justification):** Hook requires populated fields on every commit.

**Alternatives considered:** None — documentation only.

**Review notes:** No code changes.

