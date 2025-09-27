#!/bin/bash

# Script to update resume preview image from PDF
# Downloads PDF from https://kweusuf.is-a.dev and converts to image
# Requires ImageMagick and wget/curl to be installed

PDF_FILE="assets/resume.pdf"
OUTPUT_IMAGE="assets/resume-preview.jpg"
PDF_URL="https://drive.google.com/uc?export=download&id=191t9WDPxvc-tl4gKenMbwUbahvO4RymU"

echo "Checking for resume PDF..."

# If PDF doesn't exist, try to download it with fallback options
if [ ! -f "$PDF_FILE" ]; then
    echo "PDF not found locally. Attempting to download from: $PDF_URL"

    # Try wget first
    if command -v wget >/dev/null 2>&1; then
        echo "Trying wget..."
        wget -O "$PDF_FILE" "$PDF_URL"
        if [ $? -eq 0 ]; then
            echo "✅ Successfully downloaded PDF using wget"
        else
            echo "❌ wget failed, trying curl..."
            # Try curl as fallback
            if command -v curl >/dev/null 2>&1; then
                curl -L -o "$PDF_FILE" "$PDF_URL"
                if [ $? -eq 0 ]; then
                    echo "✅ Successfully downloaded PDF using curl"
                else
                    echo "❌ curl also failed. Please download manually from: $PDF_URL"
                    exit 1
                fi
            else
                echo "❌ Neither wget nor curl available for download"
                exit 1
            fi
        fi
    else
        # Try curl if wget not available
        if command -v curl >/dev/null 2>&1; then
            echo "wget not available, trying curl..."
            curl -L -o "$PDF_FILE" "$PDF_URL"
            if [ $? -eq 0 ]; then
                echo "✅ Successfully downloaded PDF using curl"
            else
                echo "❌ curl failed. Please download manually from: $PDF_URL"
                exit 1
            fi
        else
            echo "❌ Neither wget nor curl available for download"
            exit 1
        fi
    fi
fi

echo "Converting $PDF_FILE to $OUTPUT_IMAGE..."

# Convert PDF to image with high quality (first page only)
# Try magick first (ImageMagick 7), fallback to convert (ImageMagick 6)
if command -v magick >/dev/null 2>&1; then
    magick -density 200 "$PDF_FILE[0]" -quality 95 -background white -flatten "$OUTPUT_IMAGE"
else
    convert -density 200 "$PDF_FILE[0]" -quality 95 -background white -flatten "$OUTPUT_IMAGE"
fi

if [ $? -eq 0 ]; then
    echo "Successfully updated $OUTPUT_IMAGE"
    echo "Your resume preview has been updated!"
else
    echo "Error: Failed to convert PDF to image"
    echo "Make sure ImageMagick is installed"
    exit 1
fi
