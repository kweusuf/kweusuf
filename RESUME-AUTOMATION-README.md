# Resume Preview Automation

This repository includes automation to automatically update the resume preview image daily by downloading the latest resume PDF from your hosted location and converting it to an image.

## How it works

The GitHub Action runs **daily at 6:00 AM UTC** and:
1. Downloads the latest resume PDF from `https://kweusuf.is-a.dev/resume.pdf`
2. Converts the PDF to a high-quality image
3. Commits and pushes the updated image to the repository

## Setup

### Prerequisites
- GitHub repository with Actions enabled
- Resume PDF hosted at `https://kweusuf.is-a.dev/resume.pdf`
- Personal Access Token (PAT) with `repo` permissions for automated commits

### Setting up Personal Access Token
1. Go to GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (Full control of private repositories)
4. Copy the generated token
5. Go to your repository Settings > Secrets and variables > Actions
6. Click "New repository secret"
7. Name: `PAT_TOKEN`
8. Value: Paste your personal access token
9. Click "Add secret"

### Manual Testing
You can also run the script locally for testing:
1. Download the PDF: `wget -O assets/resume.pdf "https://drive.google.com/uc?export=download&id=191t9WDPxvc-tl4gKenMbwUbahvO4RymU"`
2. Run: `./update-resume-preview.sh`
3. The script will generate `assets/resume-preview.jpg`

### Automatic Daily Updates (GitHub Actions)
The GitHub Action is already configured to:
- Run daily at 6:00 AM UTC
- Download the latest PDF from your hosted location
- Convert it to an image automatically
- Update the preview without any manual intervention

## Files
- `update-resume-preview.sh` - Script to convert PDF to image
- `.github/workflows/update-resume-preview.yml` - GitHub Action for daily automation
- `assets/resume-preview.jpg` - Generated preview image
- `README.md` - References the correct image file

## Requirements
- ImageMagick (for PDF to image conversion)
- wget (for downloading PDF)
- GitHub repository with Actions enabled

## Configuration
- **Schedule**: Daily at 6:00 AM UTC (configurable in `.github/workflows/update-resume-preview.yml`)
- **PDF Source**: `https://kweusuf.is-a.dev/resume.pdf`
- **Output**: `assets/resume-preview.jpg` (first page only, 250 DPI, 95% quality, with white background and flattening)

## Troubleshooting
- If the script fails, ensure ImageMagick and wget are installed
- The action will only commit changes if the PDF has actually been updated
- Check the Actions tab in your GitHub repository for run logs
- The script converts only the first page of the PDF
- **ImageMagick Command Issue**: The workflow now tries both `magick` (IM 7) and `convert` (IM 6) commands for compatibility
- **GitHub Actions Not Running**: Make sure GitHub Actions are enabled in repository Settings > Actions > General
- **No Changes Committed**: The workflow checks both staged and unstaged changes. If no changes are detected, it means the resume preview is already up to date
- **Git Push Permission Issues**: Add a PAT_TOKEN secret with `repo` permissions to your repository secrets
