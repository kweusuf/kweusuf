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

