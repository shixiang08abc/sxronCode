#!/bin/sh
searchHubDir=$1
CacheDir=$2
trainDir=$3
datadir=$4
locateip=$5
qohost=$6
basemodel=$7
queryterm=$8

echo "searchHubDir=$searchHubDir"
echo "CacheDir=$CacheDir"
echo "trainDir=$trainDir"
echo "datadir=$datadir"
echo "locateip=$locateip"
echo "qohost=$qohost"
echo "basemodel=$basemodel"
echo "queryterm=$queryterm"

echo "restart searchHub link $qohost"
cd $searchHubDir/conf
rm searchhub.conf; ln -s $qohost searchhub.conf
cd $searchHubDir
sh restart.sh
sleep 5s

echo "`date "+%Y-%m-%d %H:%M:%S"`  start fangzi offline link basemodel=$basemodel"
cd $CacheDir/data/base/rerank_data
rm relevance.model; ln -s $basemodel relevance.model
cd $trainDir/RelevanceLTRData/codename
rm dump.data; ln -s $datadir/qs.dump.train.2 dump.data
cd $CacheDir
rm data/ltr.dump;
sh start_fangzi_offline.sh

while((1))
do
        lines=`grep loop log/err | wc -l`
        if [ $lines -eq 4 ];then
                echo "loop $lines"
                break;
        fi
done
sleep 1m

cd $trainDir/RelevanceTrain/nlp_exp/script

queryline=`cat $queryterm | wc -l`
spit=`expr $[$queryline + 3] / 3`
spit1=$spit
spit2=`expr $spit1 \* 2`
spit3=`expr $spit1 \* 3`
echo "queryline=$queryline everyspit=$spit spit1=$spit1 spit2=$spit2 spit3=$spit3"

nohup perl request_train_dump.pl $queryterm $locateip 0 $spit1 &
nohup perl request_train_dump.pl $queryterm $locateip $spit1 $spit2 &
nohup perl request_train_dump.pl $queryterm $locateip $spit2 $spit3 &

sleep 1m

while((1))
do
        sleep 30s
        pid=`ps aux | grep request_train_dump | grep -v grep | awk '{ print $2}' | wc -l`
        if [ $pid -eq 0 ];then
		echo "no request_train_dump running"
                break;
        fi
done

sleep 20s
mv $CacheDir/data/ltr.dump $trainDir/RelevanceLTRData/codename/$datadir/ltr.train.2





