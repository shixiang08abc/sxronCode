#!/bin/sh
searchHubDir=/search/odin/web_searchhub
CacheDir=/search/odin/fangzi/nlp/cache/web_rerank/web_cache/WebCache
trainDir=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo
basedir=base			#base 目录
targetdir=sxquerytw			#test 目录

qohostbase=searchhub.conf.wp96		#base qo
qohosttest=searchhub.conf.wp96		#test qo
fangzi=sjs				#房子 sjs or nm
basemodel=relevance.model.online	#base model
rankmask=0x0				#rankmask
locateip=			#本机ip

querytrain1=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/nlp_exp/queryterm/train.query.1	#训练集1 
querytrain2=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/nlp_exp/queryterm/train.query.2	#训练集2
querytrain3=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/nlp_exp/queryterm/train.query.3	#训练集3
querytrain4=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/nlp_exp/queryterm/train.query.4	#训练集4
queryvalid=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/nlp_exp/queryterm/test.valid	#校验集
queryterm=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/nlp_exp/queryterm/12k.query		#query集

leafmin=10				
leafmax=50
leafgap=2

#仅仅解单独一个dump文件时用到
onlydumpmodel=/search/odin/fangzi/nlp/cache/web_rerank/web_cache/WebCache/data/base/rerank_data/relevance.model.online
onlydumpdata=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/data/codename/$targetdir/qs.dump.diff.all
onlydumpresult=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/data/codename/$targetdir/dump.result.all

#新旧dumpresult对比时用到，指定oldmodelresult文件
oldresult=/search/odin/fangzi/nlp/cache/web_rerank/rank_demo/RelevanceTrain/data/codename/$targetdir/results/oldmodelresult.all

cd $CacheDir/conf
rm webcache_fangzi_lunxun.cfg; ln -s webcache_fangzi_lunxun_$fangzi.cfg webcache_fangzi_lunxun.cfg
rm webcache_fangzi_lunxun_offline.cfg; ln -s webcache_fangzi_lunxun_offline_$fangzi.cfg webcache_fangzi_lunxun_offline.cfg
cd $trainDir/RelevanceTrain/nlp_exp/script

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh create_base_dump.sh"
#sh create_base_dump.sh $searchHubDir $CacheDir $trainDir $basedir $locateip $qohostbase $basemodel $queryterm

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_base_dump.sh"
#sh request_base_dump.sh $searchHubDir $CacheDir $trainDir $basedir $locateip $qohostbase $basemodel $queryterm

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh create_diff_dump.sh"
#sh create_diff_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $queryterm $rankmask

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_only_dump.sh"
#sh request_only_dump.sh $searchHubDir $CacheDir $trainDir $basedir $locateip $qohostbase $onlydumpmodel $queryterm $onlydumpdata $onlydumpresult

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_diff_dump.sh"
#sh request_diff_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $queryterm $leafmin $leafmax $leafgap

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh create_train1_dump.sh"
#sh create_train1_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain1 $rankmask

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_train1_dump.sh"
#sh request_train1_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain1

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh create_train2_dump.sh"
#sh create_train2_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain2 $rankmask

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_train2_dump.sh"
#sh request_train2_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain2

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh create_train3_dump.sh"
#sh create_train3_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain3 $rankmask

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_train3_dump.sh"
#sh request_train3_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain3

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh create_train4_dump.sh"
#sh create_train4_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain4 $queryvalid $rankmask

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh request_train4_dump.sh"
#sh request_train4_dump.sh $searchHubDir $CacheDir $trainDir $targetdir $locateip $qohosttest $basemodel $querytrain4 $queryvalid

#echo "`date "+%Y-%m-%d %H:%M:%S"`  sh insert_diff_vr.sh"
#sh insert_diff_vr.sh $trainDir $targetdir $oldresult

#echo "`date "+%Y-%m-%d %H:%M:%S"`  python merge_diff_anno.py"
#python merge_diff_anno.py $trainDir $targetdir


