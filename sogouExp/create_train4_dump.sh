#!/bin/sh
searchHubDir=$1
CacheDir=$2
trainDir=$3
datadir=$4
locateip=$5
qohost=$6
basemodel=$7
queryterm=$8
queryvalid=$9
rankmask=${10}

echo "searchHubDir=$searchHubDir"
echo "CacheDir=$CacheDir"
echo "trainDir=$trainDir"
echo "datadir=$datadir"
echo "locateip=$locateip"
echo "qohost=$qohost"
echo "basemodel=$basemodel"
echo "queryterm=$queryterm"
echo "queryvalid=$queryvalid"
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

echo "`date "+%Y-%m-%d %H:%M:%S"`  start create train4 dump rankmask=$rankmask"
filedir=$trainDir/RelevanceLTRData/codename/$datadir
if [ ! -d "$filedir" ];then
mkdir $filedir
fi

dumptrain=$filedir/qs.dump.train.4
dumpvalid=$filedir/qs.dump.valid

echo "`date "+%Y-%m-%d %H:%M:%S"` send train4 query reld on new query: $queryterm" >> $filedir/log
date >> $filedir/log
rm $trainDir/data/qs.dump
cd $trainDir/RelevanceTrain/nlp_exp/script
perl request_train.pl $queryterm $locateip $rankmask
sleep 20s
mv $trainDir/data/qs.dump  $dumptrain

echo "`date "+%Y-%m-%d %H:%M:%S"`  start create valid dump rankmask=$rankmask"
echo "`date "+%Y-%m-%d %H:%M:%S"`  send valid query reld on new query: $queryvalid" >> $filedir/log
date >> $filedir/log
rm $trainDir/data/qs.dump
cd $trainDir/RelevanceTrain/nlp_exp/script
perl request_diff.pl $queryvalid $locateip $rankmask
sleep 20s
mv $trainDir/data/qs.dump  $dumpvalid
