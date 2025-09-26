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
