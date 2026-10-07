#!/bin/bash
#SBATCH --job-name=macs3
#SBATCH --output=logs/macs3_%A_%a.out
#SBATCH --error=logs/macs3_%A_%a.err
#SBATCH --array=1-TOTAL_DESIGNS
#SBATCH --mem=1G
#SBATCH --time=00:30:00

set -euo pipefail

# Load MACS3
eval $(spack load --sh py-macs3)

# Create output directory
mkdir -p macs3_output logs

# Read design file path from lookup
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
OUTPUT_DIR="macs3_output/$CONDITION"
mkdir -p "$OUTPUT_DIR"

echo "Processing condition: $CONDITION"
echo "Design file: $DESIGN_FILE"
echo "Output directory: $OUTPUT_DIR"

# Parse design file to extract control and signal BAMs
# Skip header line (#DataFile)
CONTROL_BAM=""
SIGNAL_BAMS=""

while IFS=$'\t' read -r bam_file signal_control format replicate_name; do
    # Skip header
    if [[ "$bam_file" == "#DataFile" ]]; then
        continue
    fi

    # Skip empty lines
    if [[ -z "${bam_file// }" ]]; then
        continue
    fi

    # Collect control
    if [[ "$signal_control" == "control" ]]; then
        CONTROL_BAM="$bam_file"
    fi

    # Collect signal files
    if [[ "$signal_control" == "signal" ]]; then
        SIGNAL_BAMS="$SIGNAL_BAMS $bam_file"
    fi
done < "$DESIGN_FILE"

# Validate we have control and signal
if [[ -z "$CONTROL_BAM" ]]; then
    echo "Error: No control BAM found in design file" >&2
    exit 1
fi

if [[ -z "$SIGNAL_BAMS" ]]; then
    echo "Error: No signal BAM files found in design file" >&2
    exit 1
fi

# Trim leading/trailing whitespace from SIGNAL_BAMS
SIGNAL_BAMS=$(echo $SIGNAL_BAMS | xargs)

echo "Control BAM: $CONTROL_BAM"
echo "Signal BAMs: $SIGNAL_BAMS"

# Validate files exist
if [[ ! -f "$CONTROL_BAM" ]]; then
    echo "Error: Control BAM file does not exist: $CONTROL_BAM" >&2
    exit 1
fi

for bam in $SIGNAL_BAMS; do
    if [[ ! -f "$bam" ]]; then
        echo "Error: Signal BAM file does not exist: $bam" >&2
        exit 1
    fi
done

# Run MACS3 callpeak
# note I took the median
# fragment size from one
# bam like so
# samtools view -f 1 bams/11835_filtered.bam | awk '{print $9}' | awk '$1>0' | sort -n | awk '{a[NR]=$1} END {print a[int(NR/2)]}'
macs3 callpeak \
  -t $SIGNAL_BAMS \
  -c "$CONTROL_BAM" \
  -f BAM \
  -n "$CONDITION" \
  -g 1.2e7 \
  -q 0.999999999999 \
  --nomodel \
  --extsize 50 \
  --call-summits \
  --min-length 50 \
  --max-gap 100 \
  -B \
  --cutoff-analysis \
  --trackline \
  --outdir "$OUTPUT_DIR"

echo "Completed: $CONDITION"
echo "Output files in: $OUTPUT_DIR"
