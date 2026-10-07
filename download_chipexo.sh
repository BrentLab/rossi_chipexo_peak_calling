#!/bin/bash

#SBATCH --time 5-10:00:00
#SBATCH --mem-per-cpu 250MB
#SBATCH -J dl_chipexo
#SBATCH -o dl_chipexo.log

wget -r -np -nH --cut-dirs=5 -R index.html https://www.datacommons.psu.edu/download/eberly/pughlab/yeast-epigenome-project/
