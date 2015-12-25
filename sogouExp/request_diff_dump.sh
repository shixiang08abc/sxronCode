#!/bin/sh
searchHubDir=$1
CacheDir=$2
trainDir=$3
datadir=$4
locate=$5
qohost=$6
queryterm=$7

echo "searchHubDir=$searchHubDir"
echo "CacheDir=$CacheDir"
echo "trainDir=$trainDir"
echo "datadir=$datadir"
echo "locate=$locate"
echo "qohost=$qohost"
echo "queryterm=$queryterm"

echo "restart searchHub link $qohost"
cd $searchHubDir/conf
rm searchhub.conf; ln -s $qohost searchhub.conf
cd $searchHubDir
sh restart.sh
sleep 5

cd $trainDir/RelevanceLTRData/codename
rm dump.data; ln -s $datadir/qs.dump.diff.all dump.data

cd $trainDir/RelevanceTrain/nlp_exp/script
python nlp_getallresult_dump.py $CacheDir $trainDir $datadir $locate $queryterm $8 $9 ${10}





