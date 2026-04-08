INPUT_DIR="$1"
INPUT_DIR="${INPUT_DIR%/}" # remove trailing slash if any

# Get parent directory and base folder name
PARENT_DIR="$(dirname "$INPUT_DIR")"
BASENAME="$(basename "$INPUT_DIR")"

# Create output directory: parent + "-webp"
OUTPUT_DIR="$PARENT_DIR/${BASENAME}-webp"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*.png; do
  [ -e "$file" ] || continue

  filename="$(basename "$file")"
  name="${filename%.png}"

  cwebp "$file" -o "$OUTPUT_DIR/$name.webp"
done
