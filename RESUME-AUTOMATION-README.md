# Resume Build & Preview Automation

Automated pipeline that compiles the LaTeX resume to PDF and generates a preview image, running daily via GitHub Actions.

## How It Works

The GitHub Action (`.github/workflows/build-and-preview.yml`) runs **daily at 6:00 AM UTC** and:

1. Checks if LaTeX source files have changed (SHA-256 hash comparison)
2. Installs [Tectonic](https://tectonic-typesetting.github.io/) — a self-contained LaTeX engine
3. Compiles `latex/main.tex` → `resume.pdf`
4. Converts the PDF to a high-quality preview image (`assets/resume-preview.jpg`)
5. Commits and pushes both files if they changed

If nothing changed, the workflow exits cleanly with no commits.

## Manual Execution

Trigger the workflow manually from the **Actions** tab:

- **Run workflow** → triggers a rebuild
- **Force rebuild** → rebuilds even if sources haven't changed

## Local Build

### Prerequisites

- [Tectonic](https://tectonic-typesetting.github.io/) (`curl --proto '=https' --tlsv1.2 -sSf https://tectonic-typesetting.github.io/book/latest/installation.html | sh`)
- [ImageMagick](https://imagemagick.org/) (`brew install imagemagick`)

### Build PDF

```bash
./build-resume.sh                    # Compiles LaTeX → resume.pdf
./build-resume.sh --check            # Check if rebuild needed (exit code)
./build-resume.sh --output ./build   # Write PDF to ./build/resume.pdf
```

### Generate Preview

```bash
./update-resume-preview.sh                    # Converts resume.pdf → assets/resume-preview.jpg
./update-resume-preview.sh --pdf path/to.pdf  # Use a specific PDF
./update-resume-preview.sh --output out.jpg   # Write to specific path
```

### Full Pipeline (local)

```bash
./build-resume.sh && ./update-resume-preview.sh
```

## Configuration

| Variable    | Default | Description                       |
| ----------- | ------- | --------------------------------- |
| `RESUME_DPI`    | `200`       | Image resolution for preview      |
| `RESUME_QUALITY`| `95`        | JPEG quality (0–100)              |

## File Structure

| File                                | Description                         |
| ----------------------------------- | ----------------------------------- |
| `latex/main.tex`                        | LaTeX source (the single source of truth) |
| `resume.pdf`                            | Generated PDF (committed by CI)     |
| `.latex-source-hash`                    | Hash of source files for rebuild detection |
| `assets/resume-preview.jpg`             | Generated preview image             |
| `build-resume.sh`                       | Local build script                  |
| `update-resume-preview.sh`              | PDF → image conversion script       |
| `.github/workflows/build-and-preview.yml`| CI workflow                        |

## Setup

### Prerequisites

- GitHub repository with Actions enabled
- Personal Access Token (PAT) with `repo` permissions for automated commits

### Setting up Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (Full control of private repositories)
4. Copy the generated token
5. Go to your repository Settings → Secrets and variables → Actions
6. Click "New repository secret"
7. Name: `PAT_TOKEN`, Value: your token

## Troubleshooting

- **Workflow not running**: Ensure GitHub Actions are enabled in Settings → Actions → General
- **No commits created**: The workflow only commits when content actually changes — check the Actions logs
- **Build fails**: Check that `latex/main.tex` compiles locally with `tectonic latex/main.tex`
- **ImageMagick errors**: The script supports both IM 7 (`magick`) and IM 6 (`convert`)
- **Push permission issues**: Verify the `PAT_TOKEN` secret has `repo` scope
