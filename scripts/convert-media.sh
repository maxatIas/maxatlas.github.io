#!/usr/bin/env bash
# convert-media.sh — convert images (JPG/PNG) → AVIF
# Usage: ./scripts/convert-media.sh [content-dir]
#
# For each .jpg/.jpeg/.png: produces a sibling .avif
# Originals are NOT deleted; re-running skips already-converted files.

set -euo pipefail

if ! command -v magick &>/dev/null; then
  echo "ERROR: ImageMagick not found. Install it with: brew install imagemagick" >&2
  exit 1
fi

# Default: process both content/ and static/
DIRS=("${@:-content static}")
if [[ $# -gt 0 ]]; then
  DIRS=("$@")
else
  DIRS=(content static)
fi

# ── Images (JPG / PNG) → AVIF ─────────────────────────────────────────────────
echo "==> Converting images → AVIF …"
for dir in "${DIRS[@]}"; do
  [[ -d "$dir" ]] || { echo "  skip (not a directory): $dir"; continue; }
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
  done < <(find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)
done

echo ""
echo "Done."
