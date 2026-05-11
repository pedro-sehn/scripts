if [ -z "$1" ]; then
  echo "Usage: ./eps-to-svg.sh file-name.eps"
  exit 1
fi

INPUT="$1"
OUTPUT="${INPUT%.*}.svg"

if [ ! -f "$INPUT" ]; then
  echo "File not found: $INPUT"
  exit 1
fi

/Applications/Inkscape.app/Contents/MacOS/inkscape "$INPUT" \
  --export-type=svg \
  --export-filename="$OUTPUT"

echo "Created: $OUTPUT"
