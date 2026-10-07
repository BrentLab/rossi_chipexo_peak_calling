BEGIN {
    FS="\t"
    OFS="\t"
    # Roman numeral to numeric mapping for yeast
    roman["chrI"] = "chr1"
    roman["chrII"] = "chr2"
    roman["chrIII"] = "chr3"
    roman["chrIV"] = "chr4"
    roman["chrV"] = "chr5"
    roman["chrVI"] = "chr6"
    roman["chrVII"] = "chr7"
    roman["chrVIII"] = "chr8"
    roman["chrIX"] = "chr9"
    roman["chrX"] = "chr10"
    roman["chrXI"] = "chr11"
    roman["chrXII"] = "chr12"
    roman["chrXIII"] = "chr13"
    roman["chrXIV"] = "chr14"
    roman["chrXV"] = "chr15"
    roman["chrXVI"] = "chr16"
    roman["chrM"] = "chrM"
}
{
    # Replace chromosome name in first column
    old_chr = $1
    if (old_chr in roman) {
        $1 = roman[old_chr]
    }
    print
}
