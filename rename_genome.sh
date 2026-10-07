IN=/ref/mblab/data/S288C_R64/S288C_reference_genome_R64-5-1_20240529/S288C_reference_sequence_R64-5-1_20240529_chr_normalized.fa
OUT=sacCer3_cegr.fa

awk 'BEGIN{
  split("I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI", r, " ");
  for(i=1;i<=16;i++) map["chr" r[i]]="chr" i;
  map["chrM"]="chrM";
}
/^>/{
  name=substr($1,2);
  if(name in map){ print ">" map[name] }
  else { print "UNMAPPED: " $0 > "/dev/stderr"; print $0 }
  next
}
{ print }
' "$IN" > "$OUT"
