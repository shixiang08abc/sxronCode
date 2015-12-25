#!/bin/sh
searchHubDir=$1
CacheDir=$2
trainDir=$3
datadir=$4
locateip=$5
qohost=$6
model=$7
queryterm=$8
dumpdata=$9
dumpresult=${10}

echo "searchHubDir=$searchHubDir"
echo "CacheDir=$CacheDir"
echo "trainDir=$trainDir"
echo "datadir=$datadir"
echo "locateip=$locateip"
echo "qohost=$qohost"
echo "model=$model"
echo "queryterm=$queryterm"
echo "dumpdata=$dumpdata"
echo "dumpresult=$dumpresult"

echo "restart searchHub link $qohost"
cd $searchHubDir/conf
rm searchhub.conf; ln -s $qohost searchhub.conf
cd $searchHubDir
sh restart.sh
sleep 5s

echo "`date "+%Y-%m-%d %H:%M:%S"`  start fangzi offline link model=$model"
cd $CacheDir/data/base/rerank_data
rm relevance.model; ln -s $model relevance.model
cd $trainDir/RelevanceLTRData/codename
rm dump.data; ln -s $dumpdata dump.data
cd $CacheDir
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
spit=`expr $[$queryline + 6] / 6`
spit1=$spit
spit2=`expr $spit1 \* 2`
spit3=`expr $spit1 \* 3`
spit4=`expr $spit1 \* 4`
spit5=`expr $spit1 \* 5`
spit6=`expr $spit1 \* 6`
echo "queryline=$queryline everyspit=$spit spit1=$spit1 spit2=$spit2 spit3=$spit3 spit4=$spit4 spit5=$spit5 spit6=$spit6"

nohup perl request_dump.pl $queryterm $locateip 0 $spit1 &
nohup perl request_dump.pl $queryterm $locateip $spit1 $spit2 &
nohup perl request_dump.pl $queryterm $locateip $spit2 $spit3 &
nohup perl request_dump.pl $queryterm $locateip $spit3 $spit4 &
nohup perl request_dump.pl $queryterm $locateip $spit4 $spit5 &
nohup perl request_dump.pl $queryterm $locateip $spit5 $spit6 &

sleep 30s

cd $CacheDir
file_size=`ls -l dump_result | awk '{ print $5}'`
while((1))
do
    sleep 60s
    new_file_size=`ls -l dump_result | awk '{ print $5}'`
    if [ $new_file_size -ne $file_size ];then
        file_size=$new_file_size;
    else
        break;
    fi
done

sleep 20
cp $CacheDir/dump_result $dumpresult
