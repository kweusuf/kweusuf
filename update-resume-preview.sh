#!/bin/bash
set -euo pipefail

# update-resume-preview.sh — Render every page of the resume PDF to preview images
#
# GitHub cannot embed a PDF in a README (its sanitizer strips iframes/embeds and
# CSP blocks frames), so the profile README displays one image per page instead.
# This script keeps that image set in sync with the PDF.
#
# Usage:
#   ./update-resume-preview.sh                    # resume.pdf → assets/resume-preview-<page>.jpg
#   ./update-resume-preview.sh --pdf FILE         # Use a specific PDF
#   ./update-resume-preview.sh --output-dir DIR   # Write images to DIR (default: assets/)
#   ./update-resume-preview.sh --prefix NAME      # Filename prefix (default: resume-preview)
#
# Output: <output-dir>/<prefix>-1.jpg, <prefix>-2.jpg, … — one file per PDF page.
# Preview images from a previous run are replaced, so a shorter PDF cannot leave
# stale pages behind.
#
# Resolution and quality can be overridden via environment variables:
#   RESUME_DPI=200    (default: 200)
#   RESUME_QUALITY=95 (default: 95)
#
# Requires: ghostscript (`gs`)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PDF_FILE="${SCRIPT_DIR}/resume.pdf"
OUTPUT_DIR="${SCRIPT_DIR}/assets"
PREFIX="resume-preview"
RESUME_DPI="${RESUME_DPI:-200}"
RESUME_QUALITY="${RESUME_QUALITY:-95}"

usage() {
    local status="${1:-1}"
    cat >&2 <<'EOF'
Usage: ./update-resume-preview.sh [options]

Options:
  --pdf FILE          PDF to render (default: ./resume.pdf)
  --output-dir DIR    Directory for page images (default: ./assets)
  --prefix NAME       Filename prefix (default: resume-preview)
  -h, --help          Show this help

Environment:
  RESUME_DPI          Render resolution in DPI (default: 200)
  RESUME_QUALITY      JPEG quality, 0-100 (default: 95)
EOF
    exit "$status"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pdf)
            [[ -n "${2:-}" ]] || usage
            PDF_FILE="$2"
            shift 2
            ;;
        --output-dir)
            [[ -n "${2:-}" ]] || usage
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --prefix)
            [[ -n "${2:-}" ]] || usage
            PREFIX="$2"
            shift 2
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

if [[ ! -f "$PDF_FILE" ]]; then
    echo "PDF not found at $PDF_FILE." >&2
    echo "Run ./build-resume.sh to generate it, or provide one with --pdf." >&2
    exit 1
fi

if [[ ! "$PREFIX" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Error: --prefix must contain only letters, digits, dots, underscores, or hyphens." >&2
    exit 1
fi

if ! command -v gs &>/dev/null; then
    echo "Error: ghostscript (gs) is not installed." >&2
    echo "Install: brew install ghostscript  (macOS) or apt install ghostscript (Linux)" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Drop previews from a previous run (including the legacy single-page
# assets/resume-preview.jpg) so stale pages never linger.
shopt -s nullglob
for stale in "$OUTPUT_DIR/${PREFIX}-"*.jpg "$OUTPUT_DIR/${PREFIX}.jpg"; do
    rm -f "$stale"
done

echo "Rendering $PDF_FILE → $OUTPUT_DIR/${PREFIX}-<page>.jpg (${RESUME_DPI} DPI, ${RESUME_QUALITY}% quality) ..."
gs -q -dNOPAUSE -dBATCH -dSAFER \
    -sDEVICE=jpeg \
    -dJPEGQ="$RESUME_QUALITY" \
    -r"$RESUME_DPI" \
    -dTextAlphaBits=4 -dGraphicsAlphaBits=4 \
    -sOutputFile="$OUTPUT_DIR/${PREFIX}-%d.jpg" \
    "$PDF_FILE"

pages=( "$OUTPUT_DIR/${PREFIX}-"*.jpg )
if (( ${#pages[@]} == 0 )); then
    echo "Error: Failed to generate preview images." >&2
    exit 1
fi

echo "Preview updated: ${#pages[@]} page image(s)"
for page in "${pages[@]}"; do
    echo "  $page"
done
