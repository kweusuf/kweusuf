#!/bin/bash
set -euo pipefail

# build-resume.sh — Compile the LaTeX resume into its PDF variants
#
# Both variants come from the single source latex/main.tex. The condensed one
# is produced by defining \SHORTRESUME, which activates the \ifshortresume
# guards in the BUILD VARIANTS block of that file.
#
#   resume.pdf         full version
#   resume-1page.pdf   condensed version
#
# Usage:
#   ./build-resume.sh                  # Build both PDFs into the repo root
#   ./build-resume.sh --full           # Build only the full PDF
#   ./build-resume.sh --short          # Build only the condensed PDF
#   ./build-resume.sh --check          # Exit 0 if up to date, 1 if rebuild needed
#   ./build-resume.sh --output DIR     # Write PDFs to DIR instead of the repo root
#
# Requires: pdflatex (texlive-latex-base + texlive-latex-extra)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LATEX_DIR="${SCRIPT_DIR}/latex"
SOURCE_FILE="${LATEX_DIR}/main.tex"
HASH_FILE="${SCRIPT_DIR}/.latex-source-hash"

OUTPUT_DIR="${SCRIPT_DIR}"
FULL_PDF="resume.pdf"
SHORT_PDF="resume-1page.pdf"

BUILD_FULL=true
BUILD_SHORT=true
CHECK_ONLY=false

usage() {
    sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --full)
            BUILD_SHORT=false
            shift
            ;;
        --short)
            BUILD_FULL=false
            shift
            ;;
        --output)
            [[ -z "${2:-}" ]] && usage
            OUTPUT_DIR="$2"
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

if [[ "$BUILD_FULL" == false && "$BUILD_SHORT" == false ]]; then
    echo "Error: nothing to build (--full and --short are mutually exclusive selectors)." >&2
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

# Every output this invocation is responsible for
REQUIRED_OUTPUTS=()
[[ "$BUILD_FULL" == true ]] && REQUIRED_OUTPUTS+=("${OUTPUT_DIR}/${FULL_PDF}")
[[ "$BUILD_SHORT" == true ]] && REQUIRED_OUTPUTS+=("${OUTPUT_DIR}/${SHORT_PDF}")

MISSING=false
for output in "${REQUIRED_OUTPUTS[@]}"; do
    [[ -f "$output" ]] || MISSING=true
done

if [[ "$CURRENT_HASH" == "$PREV_HASH" ]] && [[ "$MISSING" == false ]]; then
    echo "No changes detected in LaTeX sources. PDFs are up to date."
    exit 0
fi

if $CHECK_ONLY; then
    echo "Rebuild needed: source files changed or an expected PDF is missing."
    exit 1
fi

# pdflatex is only required once we actually compile, so --check works on a
# machine (or CI runner) without a TeX installation.
if ! command -v pdflatex &>/dev/null; then
    echo "Error: pdflatex is not installed." >&2
    echo "Install: brew install --cask mactex (macOS) or apt install texlive-latex-base texlive-latex-extra (Linux)" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Compile from the source directory so \input paths resolve correctly.
# -jobname keeps the two variants from clobbering each other's aux files.
compile() {
    local jobname="$1"
    local definition="${2:-}"
    local log="${LATEX_DIR}/${jobname}.build.log"
    echo "Compiling ${SOURCE_FILE} (${jobname}) ..."
    if ! (
        cd "$LATEX_DIR"
        pdflatex -interaction=nonstopmode -halt-on-error -jobname="$jobname" \
            "${definition}\\input{main.tex}" >"$log" 2>&1
    ); then
        echo "Error: pdflatex failed for ${jobname}. Last 30 lines of ${log}:" >&2
        tail -30 "$log" >&2
        exit 1
    fi
}

if [[ "$BUILD_FULL" == true ]]; then
    compile "resume_full"
    if [[ ! -f "${LATEX_DIR}/resume_full.pdf" ]]; then
        echo "Error: full PDF not generated. Re-run pdflatex in ${LATEX_DIR} to see the error." >&2
        exit 1
    fi
    mv "${LATEX_DIR}/resume_full.pdf" "${OUTPUT_DIR}/${FULL_PDF}"
fi

if [[ "$BUILD_SHORT" == true ]]; then
    compile "resume_short" '\def\SHORTRESUME{}'
    if [[ ! -f "${LATEX_DIR}/resume_short.pdf" ]]; then
        echo "Error: condensed PDF not generated. Re-run pdflatex in ${LATEX_DIR} to see the error." >&2
        exit 1
    fi
    mv "${LATEX_DIR}/resume_short.pdf" "${OUTPUT_DIR}/${SHORT_PDF}"
fi

# Save hash for future change detection
echo "$CURRENT_HASH" > "$HASH_FILE"

for output in "${REQUIRED_OUTPUTS[@]}"; do
    echo "Build successful: $output"
done
