#!/bin/bash

# Script to update resume preview image from PDF
# Downloads PDF from https://kweusuf.is-a.dev and converts to image
# Requires ImageMagick and wget/curl to be installed

PDF_FILE="assets/resume.pdf"
OUTPUT_IMAGE="assets/resume-preview.jpg"

echo "Checking for resume PDF..."

if [ ! -f "$PDF_FILE" ]; then
    echo "Error: $PDF_FILE not found!"
    echo "This script expects the PDF to be downloaded first."
    echo "Run this script after downloading the PDF from: https://kweusuf.is-a.dev/resume.pdf"
    exit 1
fi

echo "Converting $PDF_FILE to $OUTPUT_IMAGE..."

# Convert PDF to image with high quality (first page only)
magick -density 250 "$PDF_FILE[0]" -quality 95 -background white -flatten "$OUTPUT_IMAGE"

if [ $? -eq 0 ]; then
    echo "Successfully updated $OUTPUT_IMAGE"
    echo "Your resume preview has been updated!"
else
    echo "Error: Failed to convert PDF to image"
    echo "Make sure ImageMagick is installed"
    exit 1
fi
