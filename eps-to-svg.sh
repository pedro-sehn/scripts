#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: eps-to-svg.sh file-name.eps"
  exit 1
fi

INPUT="$1"
OUTPUT="${INPUT%.*}.svg"

if [ ! -f "$INPUT" ]; then
  echo "File not found: $INPUT"
  exit 1
fi

if command -v inkscape >/dev/null 2>&1; then
  INKSCAPE="inkscape"
elif [ -x "/Applications/Inkscape.app/Contents/MacOS/inkscape" ]; then
  INKSCAPE="/Applications/Inkscape.app/Contents/MacOS/inkscape"
elif [ -x "/Applications/Inkscape.app/Contents/MacOS/Inkscape" ]; then
  INKSCAPE="/Applications/Inkscape.app/Contents/MacOS/Inkscape"
else
  echo "Inkscape not found."
  echo "Install it with: brew install --cask inkscape"
  exit 1
fi

"$INKSCAPE" "$INPUT" \
  --export-type=svg \
  --export-filename="$OUTPUT"

if [ $? -eq 0 ]; then
  echo "Created: $OUTPUT"
else
  echo "Conversion failed."
  exit 1
fi
