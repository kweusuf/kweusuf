# Change Log: latex-build

## Automate LaTeX build and preview pipeline

### What changed

Replaced the download-only preview workflow with a full build pipeline:

- **New `build-resume.sh`**: Local script to compile `latex/main.tex` → `resume.pdf` via Tectonic. Supports `--check` (detect changes without building) and `--output DIR`. Uses SHA-256 hash of all LaTeX source files for change detection, with portable `sha256sum`/`shasum` support for macOS and Linux.
- **Updated `update-resume-preview.sh`**: Removed Google Drive download dependency. Now expects `resume.pdf` at repo root (produced by `build-resume.sh`). Added `--pdf` and `--output` CLI flags, `RESUME_DPI`/`RESUME_QUALITY` environment variables, and `set -euo pipefail`.
- **New `.github/workflows/build-and-preview.yml`**: Combined daily workflow (cron 6:00 AM UTC + workflow_dispatch) that: checks for source changes via SHA-256 hash, compiles LaTeX with Tectonic (`wtfjoke/setup-tectonic@v3`), generates preview with ImageMagick, commits only if content actually changed. Supports force-rebuild via manual trigger.
- **Deleted `.github/workflows/update-resume-preview.yml`**: Replaced by the combined workflow.
- **Committed `latex/main.tex`**: LaTeX source was previously untracked; now part of the repository.
- **Updated `RESUME-AUTOMATION-README.md`**: Reflects new architecture, local build instructions, and file structure.

### Why (justification)

The previous pipeline downloaded the PDF from Google Drive on every run, even when the resume hadn't changed. This was wasteful and fragile (external dependency on Google Drive URL). The new pipeline compiles from source, detects changes via content hashing, and only rebuilds/commits when necessary. Eliminates external download dependency entirely.

### Alternatives considered

- **latexmk**: Heavier dependency (requires full TeX distribution). Tectonic is a single self-contained binary that auto-downloads packages — better for CI.
- **Two separate workflows** (build then preview): Simpler individually but adds complexity for inter-workflow coordination. Combined workflow is more straightforward.
- **Timestamp-based change detection**: Unreliable across CI runs (fresh checkout = new timestamps). Content hashing is deterministic.

### Review notes

- `wtfjoke/setup-tectonic@v3` is a well-maintained action for Tectonic installation in CI.
- The `.latex-source-hash` file is committed by CI so subsequent runs can compare against the last-built state.
- Binary comparison via `git diff --staged --quiet` prevents empty commits when outputs are identical.
- `build-resume.sh` uses bash arrays and `[[ ]]` — not POSIX sh, but the shebang is `#!/bin/bash` which is fine.
- `inputs.force` uses `type: choice` (not `boolean`) because GitHub Actions workflow_dispatch doesn't support boolean inputs.
## `32cbcdb9` — Automate LaTeX build and preview pipeline
**Timestamp:** 2026-07-08T20:40:56

**Files changed:**
```
.github/workflows/build-and-preview.yml     |  95 +++++++++
 .github/workflows/update-resume-preview.yml |  59 ------
 RESUME-AUTOMATION-README.md                 | 128 ++++++++-----
 build-resume.sh                             | 110 +++++++++++
 docs/change-log/latex-build.md              |  32 ++++
 latex/main.tex                              | 288 ++++++++++++++++++++++++++++
 update-resume-preview.sh                    | 125 ++++++------
 7 files changed, 667 insertions(+), 170 deletions(-)
```

**What changed:** Squashed commit — same content as the detailed entry above. Replaced Google Drive download pipeline with a full LaTeX build pipeline using Tectonic and SHA-256 change detection.

**Why (justification):** Eliminates external dependency on Google Drive URL; compiles from source and only commits when content changes.

**Alternatives considered:** latexmk (heavier), two-workflow design (more coordination), timestamp detection (unreliable in CI).

**Review notes:** `PAT_TOKEN` secret must be configured for push access. First CI run will trigger a rebuild (no stored hash yet). `wtfjoke/setup-tectonic@v3` handles Tectonic installation.

