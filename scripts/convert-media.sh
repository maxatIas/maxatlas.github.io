#!/usr/bin/env bash
# convert-media.sh — convert images (JPG/PNG) → AVIF
# Usage: ./scripts/convert-media.sh [content-dir]
#
# For each .jpg/.jpeg/.png: produces a sibling .avif
# Originals are NOT deleted; re-running skips already-converted files.

set -euo pipefail

CONTENT_DIR="${1:-content}"

if ! command -v magick &>/dev/null; then
  echo "ERROR: ImageMagick not found. Install it with: brew install imagemagick" >&2
  exit 1
fi

# ── Images (JPG / PNG) → AVIF ─────────────────────────────────────────────────
echo "==> Converting images → AVIF …"
while IFS= read -r -d '' src; do
  base="${src%.*}"
  dst="${base}.avif"
  if [[ -f "$dst" ]]; then
    echo "  skip (exists): $dst"
    continue
  fi
  echo "  $src → $dst"
  magick "$src" -quality 60 "$dst"
  rm "$src"
done < <(find "$CONTENT_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)

echo ""
echo "Done."
