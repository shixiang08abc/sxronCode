#!/bin/bash

outfile=$1
rm -f $outfile

while read word
do
	#wget -O temphtml "http://nginx01.web.cnc/web?forceQuery=on&meta=off&query=$word" 2>/dev/null
	#wget -O temphtml "http://10.16.129.116/web?forceQuery=on&meta=off&query=$word" 2>/dev/null
	#wget -O temphtml "http://10.16.129.116:8081/websearch/sogou.jsp?forceQuery=on&meta=off&query=$word" 2>/dev/null
	wget -O temphtml "http://10.134.43.125/web?forceQuery=on&meta=off&query=$word" 2>/dev/null
	#wget -O temphtml "http://10.16.129.116/web?forceQuery=on&meta=off&query=$word" 2>/dev/null
	cat temphtml | perl vr_parser.pl $word >> $outfile
	rm -f temphtml
done
