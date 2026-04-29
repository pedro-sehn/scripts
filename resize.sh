#!/bin/bash

# Usage:
#   script.sh input_image scale_factor
#   script.sh input_image output_image scale_factor
#   script.sh input_image widthxheight
#   script.sh input_image output_image widthxheight
#
# Examples:
#   script.sh photo.jpg 0.5
#   script.sh photo.jpg out.jpg 0.5
#   script.sh photo.jpg 800x
#   script.sh photo.jpg x600
#   script.sh photo.jpg 800x600
#   script.sh photo.jpg out.jpg 800x600

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 input_image [output_image] scale_factor|widthxheight" >&2
  exit 1
fi

INPUT="$1"

if [ "$#" -eq 2 ]; then
  TARGET="$2"
  EXT="${INPUT##*.}"
  NAME="${INPUT%.*}"
  OUTPUT="${NAME}_scaled.${EXT}"
else
  OUTPUT="$2"
  TARGET="$3"
fi

# Check dependencies
if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  echo "Error: ImageMagick is not installed." >&2
  exit 1
fi

# Decide resize argument:
# - 0.5      -> 50%
# - 800x     -> 800x
# - x600     -> x600
# - 800x600  -> 800x600
if [[ "$TARGET" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  RESIZE_ARG="$(printf '%.0f%%' "$(echo "$TARGET * 100" | bc -l)")"
elif [[ "$TARGET" =~ ^[0-9]+x$ || "$TARGET" =~ ^x[0-9]+$ || "$TARGET" =~ ^[0-9]+x[0-9]+$ ]]; then
  RESIZE_ARG="$TARGET"
else
  echo "Error: invalid resize target '$TARGET'." >&2
  echo "Use a scale factor like 0.5 or a size like 800x, x600, or 800x600." >&2
  exit 1
fi

# Resize
if command -v magick >/dev/null 2>&1; then
  magick "$INPUT" -resize "$RESIZE_ARG" "$OUTPUT"
else
  convert "$INPUT" -resize "$RESIZE_ARG" "$OUTPUT"
fi

# Output path for chaining
realpath "$OUTPUT"