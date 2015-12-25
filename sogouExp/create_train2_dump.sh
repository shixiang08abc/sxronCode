#!/bin/sh
searchHubDir=$1
CacheDir=$2
trainDir=$3
datadir=$4
locateip=$5
qohost=$6
basemodel=$7
queryterm=$8
rankmask=$9

echo "searchHubDir=$searchHubDir"
echo "CacheDir=$CacheDir"
echo "trainDir=$trainDir"
echo "datadir=$datadir"
echo "locateip=$locateip"
echo "qohost=$qohost"
echo "basemodel=$basemodel"
echo "queryterm=$queryterm"
echo "rankmask=$rankmask"

echo "restart searchHub link $qohost"
cd $searchHubDir/conf
rm searchhub.conf; ln -s $qohost searchhub.conf
cd $searchHubDir
sh restart.sh
sleep 5s

echo "start fangzi link basemodel=$basemodel"
cd $CacheDir/data/base/rerank_data
rm relevance.model; ln -s $basemodel relevance.model
cd $CacheDir
sh start_fangzi.sh

while((1))
do
        lines=`grep loop log/err | wc -l`
        if [ $lines -eq 4 ];then
                echo "loop $lines"
                break;
        fi
done
sleep 30s

echo "`date "+%Y-%m-%d %H:%M:%S"`  start create diff dump rankmask=$rankmask"
filedir=$trainDir/RelevanceLTRData/codename/$datadir
if [ ! -d "$filedir" ];then
mkdir $filedir
fi

dumptrain=$filedir/qs.dump.train.2
echo "send train query reld on new query: $queryterm" >> $filedir/log
date >> $filedir/log
rm $trainDir/data/qs.dump

cd $trainDir/RelevanceTrain/nlp_exp/script
perl request_train.pl $queryterm $locateip $rankmask
sleep 20
mv $trainDir/data/qs.dump  $dumptrain



