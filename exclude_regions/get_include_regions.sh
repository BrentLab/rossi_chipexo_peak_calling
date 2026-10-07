bedtools sort -i ChExMix_Peak_Filter_List_190612_sgd.bed   -g /ref/mblab/data/S288C_R64/GCF_000146045.2_R64_genomic.fa.fai > sorted_exclude.bed

bedtools complement -i sorted_exclude.bed -g /ref/mblab/data/S288C_R64/GCF_000146045.2_R64_genomic.fa.fai > keep_regions.bed
