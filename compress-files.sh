
INPUT_DIR="$1"
INPUT_DIR="${INPUT_DIR%/}"

PARENT_DIR="$(dirname "$INPUT_DIR")"
BASENAME="$(basename "$INPUT_DIR")"

OUTPUT_DIR="$PARENT_DIR/${BASENAME}-compressed"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/*; do
  [ -e "$file" ] || continue

  filename="$(basename "$file")"
  ext="${filename##*.}"
  name="${filename%.*}"

  case "$ext" in
    jpg|jpeg)
      # Compress JPEG
      cjpeg -quality 80 "$file" > "$OUTPUT_DIR/$name.jpg"
      ;;
    png)
      # Compress PNG (lossy but good)
      pngquant --quality=65-85 --output "$OUTPUT_DIR/$name.png" --force "$file"
      ;;
  esac
done
