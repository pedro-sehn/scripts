INPUT_DIR="$1"
INPUT_DIR="${INPUT_DIR%/}"

if [ -z "$INPUT_DIR" ]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

PARENT_DIR="$(dirname "$INPUT_DIR")"
BASENAME="$(basename "$INPUT_DIR")"

COMPRESSED_DIR="$PARENT_DIR/${BASENAME}-compressed"

# Step 1: compress original images
~/scripts/compress-files.sh "$INPUT_DIR"

# Step 2: convert compressed PNGs → WebP
~/scripts/convert-png-to-webp.sh "$COMPRESSED_DIR"

echo "Done: compression → conversion finished."
