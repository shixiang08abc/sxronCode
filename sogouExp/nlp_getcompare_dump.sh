#!/bin/sh

CacheDir=$1
trainDir=$2
datadir=$3
locateip=$4
queryterm=$5
filename=$6

echo "`date "+%Y-%m-%d %H:%M:%S"`  start request offline diff dump filename=$filename"
cd $CacheDir/data/base/rerank_data/
rm relevance.model; ln -s $trainDir/RelevanceLTRData/codename/$datadir/models/$filename relevance.model
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

filedir=$trainDir/RelevanceLTRData/codename/$datadir/results
if [ ! -d "$filedir" ];then
mkdir $filedir
fi

sleep 20s
cd $CacheDir
mv dump_result $filedir/$filename.all

