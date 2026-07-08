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
