#!/bin/bash
set -euo pipefail

# update-resume-preview.sh — Convert resume PDF to preview image
#
# Usage:
#   ./update-resume-preview.sh                 # Use resume.pdf from repo root
#   ./update-resume-preview.sh --pdf FILE      # Use specific PDF
#   ./update-resume-preview.sh --output FILE   # Write to specific output path
#
# Resolution and quality can be overridden via environment variables:
#   RESUME_DPI=200    (default: 200)
#   RESUME_QUALITY=95 (default: 95)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PDF_FILE="${SCRIPT_DIR}/resume.pdf"
OUTPUT_IMAGE="${SCRIPT_DIR}/assets/resume-preview.jpg"
RESUME_DPI="${RESUME_DPI:-200}"
RESUME_QUALITY="${RESUME_QUALITY:-95}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pdf)
            [[ -z "${2:-}" ]] && { echo "Error: --pdf requires a file path" >&2; exit 1; }
            PDF_FILE="$2"
            shift 2
            ;;
        --output)
            [[ -z "${2:-}" ]] && { echo "Error: --output requires a file path" >&2; exit 1; }
            OUTPUT_IMAGE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--pdf FILE] [--output FILE]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

if [[ ! -f "$PDF_FILE" ]]; then
    echo "PDF not found at $PDF_FILE." >&2
    echo "Run ./build-resume.sh to generate it, or provide one with --pdf." >&2
    exit 1
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_IMAGE")"

# Convert PDF to image (first page only)
# Try magick (ImageMagick 7) first, fallback to convert (ImageMagick 6)
echo "Converting $PDF_FILE → $OUTPUT_IMAGE (${RESUME_DPI} DPI, ${RESUME_QUALITY}% quality) ..."
if command -v magick &>/dev/null; then
    magick -density "$RESUME_DPI" "${PDF_FILE}[0]" \
        -quality "$RESUME_QUALITY" \
        -background white -flatten \
        "$OUTPUT_IMAGE"
elif command -v convert &>/dev/null; then
    convert -density "$RESUME_DPI" "${PDF_FILE}[0]" \
        -quality "$RESUME_QUALITY" \
        -background white -flatten \
        "$OUTPUT_IMAGE"
else
    echo "Error: ImageMagick is not installed." >&2
    echo "Install: brew install imagemagick  (macOS) or apt install imagemagick (Linux)" >&2
    exit 1
fi

if [[ ! -f "$OUTPUT_IMAGE" ]]; then
    echo "Error: Failed to generate preview image." >&2
    exit 1
fi

echo "Preview updated: $OUTPUT_IMAGE"
