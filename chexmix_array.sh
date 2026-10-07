#!/bin/bash
#SBATCH --job-name=chexmix
#SBATCH --output=logs/chexmix_%A_%a.out
#SBATCH --error=logs/chexmix_%A_%a.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=15G
#SBATCH --time=06:00:00

set -euo pipefail

# Load ChExMix
eval $(spack load --sh chexmix)

# Reference and software paths
REF_SOURCE=/ref/mblab/data/yeast_data/chipexo
MEME_PATH=/ref/mblab/software/spack-1.1.0/opt/spack/linux-x86_64/meme-5.5.7-jvb4u5kienfjwqxfwb7gffcmudtgevcz/bin

# Create output directory
mkdir -p chexmix_output logs

# Read design file from lookup
DESIGN_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$1")

# Input validation
if [[ -z "${DESIGN_FILE// }" ]]; then
    echo "Error: Design file is empty for task ID ${SLURM_ARRAY_TASK_ID}" >&2
    exit 1
fi

if [[ ! -f "$DESIGN_FILE" ]]; then
    echo "Error: Design file does not exist: $DESIGN_FILE" >&2
    exit 1
fi

# Extract condition name from filename (minus extension)
CONDITION=$(basename "$DESIGN_FILE" .txt)

# Create condition-specific output directory
OUTPUT_DIR="chexmix_output/$CONDITION"
mkdir -p "$OUTPUT_DIR"

echo "Processing condition: $CONDITION"
echo "Design file: $DESIGN_FILE"
echo "Output directory: $OUTPUT_DIR"

# Run ChExMix
# note that this is 0.52. paper used
# v0.31. that isn't on github releases.
# v0.30 is. One bug fix between 0.3 and
# v.52 is the handling of mapq0, which
# were erroneously included in v3.0
chexmix \
  --threads 8 \
  --geninfo $REF_SOURCE/sacCer3.info \
  --seq $REF_SOURCE/sacCer3_cegr.fa \
  --back $REF_SOURCE/yeast.back \
  --excludebed $REF_SOURCE/exclude_regions/ChExMix_Peak_Filter_List_190612.bed \
  --format BAM \
  --noread2 \
  --design "$DESIGN_FILE" \
  --memepath $MEME_PATH \
  --scalewin 1000 \
  --fixedalpha 0 \
  --mememinw 8 \
  --mememaxw 21 \
  --lenientplus \
  --q 0.01 \
  --minfold 1.5 \
  --out "$OUTPUT_DIR/${CONDITION}_chexmix" \
  > "$OUTPUT_DIR/${CONDITION}_chexmix.out" 2>&1

echo "Completed: $CONDITION"
