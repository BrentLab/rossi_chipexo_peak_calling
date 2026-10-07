#!/usr/bin/env bash
# fetch_yep_peaks.sh
#
# Extracts *_chexmix_filtered_peaks.bed from each *_YEP.zip in ZIP_DIR.
# Output: yep_filtered_peaks/ in the current working directory.

set -euo pipefail

ZIP_DIR="${1:-/lts/mblab/downloaded_data/chipexo/yeastepigenome_data}"
OUT_DIR="$(pwd)/yep_filtered_peaks"

if [[ ! -d "$ZIP_DIR" ]]; then
    echo "[error] ZIP_DIR not found: $ZIP_DIR" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

COUNT=0; SKIP=0; FAIL=0

for zip_path in "$ZIP_DIR"/*_YEP.zip; do
    zip_name=$(basename "$zip_path")
    sample_id="${zip_name%_YEP.zip}"
    bed_name="${sample_id}_chexmix_filtered_peaks.bed"
    dest="$OUT_DIR/$bed_name"

    if [[ -f "$dest" ]]; then
        echo "[skip] $bed_name already exists"
        (( SKIP++ )) || true
        continue
    fi

    # file path inside the zip may vary — find it
    bed_in_zip=$(unzip -Z1 "$zip_path" 2>/dev/null | grep -m1 "${bed_name}$" || true)

    if [[ -z "$bed_in_zip" ]]; then
        echo "[warn] $bed_name not found in $zip_name — skipping" >&2
        (( FAIL++ )) || true
        continue
    fi

    echo "[ext ] $zip_name  →  $bed_name"
    unzip -p "$zip_path" "$bed_in_zip" > "$dest"
    (( COUNT++ )) || true
done

echo ""
echo "[done] extracted=$COUNT  skipped=$SKIP  failed=$FAIL"
echo "[done] output in: $OUT_DIR"
