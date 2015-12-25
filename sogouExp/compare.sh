perl compare.pl $1 $2 > $1.diff
awk -F"\t" 'length($0)>0{query[$1]=1}END{for(q in query) print q}' $1.diff >> q.tmp 
