#!/bin/bash
set -euo pipefail

# build-resume.sh — Compile LaTeX resume to PDF
#
# Usage:
#   ./build-resume.sh              # Build PDF, output to resume.pdf
#   ./build-resume.sh --check      # Exit 0 if no changes, 1 if rebuild needed
#   ./build-resume.sh --output DIR # Write PDF to DIR/resume.pdf
#
# Requires: pdflatex (texlive-latex-base + texlive-latex-extra)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LATEX_DIR="${SCRIPT_DIR}/latex"
SOURCE_FILE="${LATEX_DIR}/main.tex"
OUTPUT_FILE="${SCRIPT_DIR}/resume.pdf"
HASH_FILE="${SCRIPT_DIR}/.latex-source-hash"

usage() {
    echo "Usage: $0 [--check] [--output DIR]"
    echo "  --check      Exit 0 if no rebuild needed, 1 if rebuild needed"
    echo "  --output DIR Write PDF to DIR/resume.pdf instead of repo root"
    exit 1
}

CHECK_ONLY=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --output)
            [[ -z "${2:-}" ]] && usage
            OUTPUT_FILE="${2}/resume.pdf"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

# Validate prerequisites
if ! command -v pdflatex &>/dev/null; then
    echo "Error: pdflatex is not installed." >&2
    echo "Install: brew install --cask mactex (macOS) or apt install texlive-latex-base texlive-latex-extra (Linux)" >&2
    exit 1
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file not found: $SOURCE_FILE" >&2
    exit 1
fi

# Portable SHA-256: detect available tool
if command -v sha256sum &>/dev/null; then
    SHA256_CMD="sha256sum"
elif command -v shasum &>/dev/null; then
    SHA256_CMD="shasum -a 256"
else
    echo "Error: Neither sha256sum nor shasum found." >&2
    exit 1
fi

# Compute hash of all LaTeX source files
compute_hash() {
    find "$LATEX_DIR" -type f \( -name '*.tex' -o -name '*.sty' -o -name '*.cls' -o -name '*.bib' -o -name '*.bst' -o -name '*.biblatex' \) \
        -print0 2>/dev/null | sort -z | xargs -0 $SHA256_CMD | $SHA256_CMD | cut -d' ' -f1
}

CURRENT_HASH=$(compute_hash)
PREV_HASH=""
if [[ -f "$HASH_FILE" ]]; then
    PREV_HASH=$(cat "$HASH_FILE")
fi

if [[ "$CURRENT_HASH" == "$PREV_HASH" ]] && [[ -f "$OUTPUT_FILE" ]]; then
    echo "No changes detected in LaTeX sources. PDF is up to date."
    exit 0
fi

if $CHECK_ONLY; then
    echo "Rebuild needed: source files changed or PDF missing."
    exit 1
fi

# Build
echo "Compiling $SOURCE_FILE → $OUTPUT_FILE ..."
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Run pdflatex from the source directory so \input paths resolve correctly
(
    cd "$LATEX_DIR"
    pdflatex -interaction=nonstopmode -halt-on-error main.tex 2>&1
)

GENERATED_PDF="${LATEX_DIR}/main.pdf"
if [[ -f "$GENERATED_PDF" ]]; then
    mv "$GENERATED_PDF" "$OUTPUT_FILE"
fi

if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "Error: PDF not generated." >&2
    exit 1
fi

# Save hash for future change detection
echo "$CURRENT_HASH" > "$HASH_FILE"
echo "Build successful: $OUTPUT_FILE"
