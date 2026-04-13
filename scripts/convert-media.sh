#!/usr/bin/env bash
# convert-media.sh — convert images (JPG/PNG) → AVIF
# Usage: ./scripts/convert-media.sh [content-dir]
#
# For each .jpg/.jpeg/.png: produces a sibling .avif
# Originals are NOT deleted; re-running skips already-converted files.

set -euo pipefail

CONTENT_DIR="${1:-content}"

if ! command -v ffmpeg &>/dev/null; then
  echo "ERROR: ffmpeg not found. Install it with: brew install ffmpeg" >&2
  exit 1
fi

# ── Images (JPG / PNG) → AVIF ─────────────────────────────────────────────────
echo "==> Converting images → AVIF …"
while IFS= read -r -d '' src; do
  # Derive output path: strip extension, add .avif
  base="${src%.*}"
  dst="${base}.avif"
  if [[ -f "$dst" ]]; then
    echo "  skip (exists): $dst"
    continue
  fi
  echo "  $src → $dst"
  ffmpeg -i "$src" \
    -c:v libaom-av1 -crf 30 -b:v 0 \
    -pix_fmt yuv420p \
    -still-picture 1 \
    "$dst" \
    -loglevel error -stats
done < <(find "$CONTENT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)

echo ""
echo "Done."
