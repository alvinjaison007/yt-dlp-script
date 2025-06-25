#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "❌ Usage: $0 urls.txt"
    exit 1
fi

url_file="$1"

# Check if file exists
if [ ! -f "$url_file" ]; then
    echo "❌ File not found: $url_file"
    exit 1
fi

# Set output directory
output_dir="/Users/jarvis/Desktop/aivideos/shortmovies/converted"
mkdir -p "$output_dir"

# Cookies file path
cookies_file="$HOME/Downloads/cookies.txt"

# Read each URL from the file
while IFS= read -r video_url || [ -n "$video_url" ]; do
    # Skip empty lines
    if [ -z "$video_url" ]; then
        continue
    fi

    echo "🔍 Processing: $video_url"

    # Predict actual filename yt-dlp will generate
    downloaded_file=$(yt-dlp --cookies "$cookies_file" --print "%(title)s.%(ext)s" -f 'bv*[ext=mp4]+ba[ext=m4a]/best[ext=mp4]/best' "$video_url")
    base_name="${downloaded_file%.*}"
    converted_file="${output_dir}/${base_name}_qt.mp4"

    echo "⬇️ Downloading: $downloaded_file"
    yt-dlp --cookies "$cookies_file" -f 'bv*[ext=mp4]+ba[ext=m4a]/best[ext=mp4]/best' \
           --merge-output-format mp4 \
           -o "$downloaded_file" \
           "$video_url"

    # Check if the download succeeded
    if [ -f "$downloaded_file" ]; then
        echo "🎞 Converting for QuickTime compatibility..."
        if [ -f "$converted_file" ]; then
            echo "⚠️ Converted file already exists, skipping: $converted_file"
            rm -f "$downloaded_file"
            continue
        fi

        ffmpeg -nostdin -y -i "$downloaded_file" -c:v libx264 -c:a aac -movflags +faststart "$converted_file"

        echo "🧹 Cleaning up original file..."
        rm -f "$downloaded_file"

        echo "✅ Saved to: $converted_file"
    else
        echo "❌ Download failed or file not found: $downloaded_file"
    fi

    echo "----------------------------------------"
done < "$url_file"

echo "🎉 All videos processed from: $url_file"
