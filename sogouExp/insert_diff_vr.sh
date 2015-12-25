#!/bin/sh
trainDir=$1
datadir=$2
oldresult=$3

echo "trainDir=$trainDir"
echo "datadir=$datadir"
echo "oldresult=$oldresult"

filedir=$trainDir/RelevanceLTRData/codename/$datadir/results/
echo "`date "+%Y-%m-%d %H:%M:%S"` start insert vr filedir=$filedir"
rm -f q.tmp*
rm -f vr

cd $trainDir/RelevanceTrain/nlp_exp/script
python file_all_vr.py $filedir $oldresult 

