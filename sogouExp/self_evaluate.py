#!/usr/bin/python
# -*- coding: gbk -*-

# Copyright (c) 2013-2014, Sogou Inc.
# All Rights Reserved
# Author(s): wuwenjin <wuwenjin@sogou-inc.com>; liuliqun <liuliqun@sogou-inc.com>

import sys
import math

ERR2_DIFF = 0.1
ERR3_DIFF = 0.1
MAX_ERR_POW_2 = 32

def err(ranklist, size):
	s = 0.0
	p = 1.0
	for i in range(size):
		r = (pow(2.0, ranklist[i]) - 1)*1.0/MAX_ERR_POW_2
		s += p*r/(i+1)
		p *= (1.0 - r)
	return s

def dcg(ranklist, size):
	dcg_value = 0.0
	for i in range(size):
		g = pow(2.0, ranklist[i]) - 1
		d = 1.0/math.log(1+1+i, 2)
		dcg_value += g*d
	return dcg_value

def ndcg(ranklist, size):
	ndcg_value = 0.0
	dcg_value = dcg(ranklist, size)
	ranklist_sort = ranklist
	ranklist_sort.sort(reverse = True)
	max_dcg_value = dcg(ranklist_sort, size)
	ndcg_value = dcg_value/max_dcg_value
	return ndcg_value

def getLabel(query, url, labelall, defaultLabel):
	items = url.strip().split(" | ")
	label = defaultLabel
	if labelall.has_key(query+"\t"+url):
		label = labelall[query+"\t"+url]
#	elif len(items) > 1 and labelall.has_key(query+"\t"+items[0]) and labelall.has_key(query+"\t"+items[1]) and\
 #    	("wenwen.soso.com" in items[0] or "zhidao.baidu.com" in items[0] or "iask.sina.com.cn" in items[0]):
#			s1 = labelall[query+"\t"+items[0]] 
#			s2 = labelall[query+"\t"+items[1]]
#			if s1 >= 3 and  s2 >= 3:
#				label = 4.0
#			else:
#				label = s1
	else:
		label = labelall.get(query+"\t"+url, defaultLabel);
	return label

# 前三未标注doc设为0分，计算ERR
def calScoreMetric(diffFile, labelall):
	global metrics_out_result
	diffs = {}
	diffsBackup = {}
	
	for line in open(diffFile):
		items = line.strip().split("\t")
		if len(items) < 4:
			continue
		
		query = items[0]
		url = items[2]
		label = getLabel(query, url, labelall, -1)

		if not diffs.has_key(items[0]):
			diffs[items[0]] = [items[2]]
			diffsBackup[items[0]] = [items[1] + "\t" + query + "\t" + url + "\t" + str(label)]
		else:
			diffs[items[0]].append(items[2])
			diffsBackup[items[0]].append(items[1] + "\t" + query + "\t" + url + "\t" + str(label))
	
	"""未标注的设为0分，前3情况"""
	win = 0
	winQ = set()
	draw = 0
	drawQ = set()
	lose = 0
	loseQ = set()
	testERR3Sum = 0
	onlineERR3Sum = 0

	# 丢弃未标注的doc, ERR分数统计
	# 当标注率很高的时候, 是一个理想指标 
	testERR2Sum_ = 0
	onlineERR2Sum_ = 0
	testERR3Sum_ = 0
	onlineERR3Sum_ = 0

	testNolabel = 0 # 前三未标注
	onlineNolabel = 0
	winDCG1  = 0
	drawDCG1 = 0
	loseDCG1 = 0

	# 便于了解未标注文档设为零分的统计结果
	test1Nolabel = 0 # test首条未标注
	online1Nolabel = 0 # online首条未标注
	
	test2Nolabel = 0 # test第二条未标注
	online2Nolabel = 0 # online第二条未标注

	test3Nolabel = 0 # test第三条未标注
	online3Nolabel = 0 # online第三条未标注

	""" 未标注, 扔掉query """
	win1 = 0
	draw1 = 0
	lose1 = 0
	win2 = 0
	draw2 = 0
	lose2 = 0
	win3 = 0
	draw3 = 0
	lose3 = 0
	
	top1difftotal = 0
	top1sameIntop3diff = 0 # 前三不同, 首条相同
	top2difftotal = 0
	top2sameIntop3diff = 0
	top1NolabelInfo = "\n---首条不同且有未标注doc---\n" 
		
	for query in diffs.keys():
		df = diffs[query]
		dfn = len(df)/2
		for doc in diffs[query][:3]:
			label = getLabel(query, doc, labelall, -1)
			if label == -1:
				testNolabel += 1
				if doc == diffs[query][0]:
					test1Nolabel += 1
				if doc == diffs[query][1]:
					test2Nolabel += 1
				if doc == diffs[query][2]:
					test3Nolabel += 1

		for doc in diffs[query][dfn:dfn+3]:
			label = getLabel(query, doc, labelall, -1)
			if label == -1:
				onlineNolabel += 1
				if doc == diffs[query][dfn]:
					online1Nolabel += 1
				if doc == diffs[query][dfn+1]:
					online2Nolabel += 1
				if doc == diffs[query][dfn+2]:
					online3Nolabel += 1

		# 未标注设为0分			
	#	testLabels   = [labelall.get(query + "\t" + x, 0) for x in diffs[query][:3]]
	#	onlineLabels = [labelall.get(query + "\t" + x, 0) for x in diffs[query][3:]]
		
		testLabels   = [getLabel(query, url, labelall, 0) for url in diffs[query][:3]]
		onlineLabels  = [getLabel(query, url, labelall, 0) for url in diffs[query][dfn:dfn+3]]
		
		testERR = err(testLabels, len(testLabels))
		onlineERR = err(onlineLabels, len(onlineLabels))
		testERR3Sum += testERR
		onlineERR3Sum += onlineERR
		
		if abs(testERR - onlineERR) < ERR3_DIFF:
			draw += 1
			drawQ.add(query)
		elif testERR > onlineERR:
			win  += 1
			winQ.add(query)
		else:
			lose += 1
			loseQ.add(query)
		
		if testLabels[0] == onlineLabels[0]:
			drawDCG1 += 1
		elif testLabels[0] > onlineLabels[0]:
			winDCG1 += 1
		else:
			loseDCG1 += 1
		
		# 未标注的 丢弃query
		testLabels_   = [getLabel(query, url, labelall, -1) for url in diffs[query][:3]]
		onlineLabels_   = [getLabel(query, url, labelall, -1) for url in diffs[query][dfn:dfn+3]]
		# 首条不一样
		if diffs[query][0] != diffs[query][dfn]:
			if testLabels_[0] != -1 and onlineLabels_[0] != -1:
				if testLabels_[0] > onlineLabels_[0]:
					win1 += 1
				elif testLabels_[0] == onlineLabels_[0]:
					draw1 += 1
				else:
					lose1 += 1
			else:
				top1NolabelInfo += query + "\t" +  diffs[query][0] + "\t" + str(testLabels_[0]) + "\ttest\n" + query + "\t" + diffs[query][dfn] +"\t" + str(onlineLabels_[0])+"\tonline\n"

			top1difftotal += 1
		else:
			top1sameIntop3diff += 1

		# 计算前三都有标注的ERR分数, 胜出落败情况
		if testLabels_[0] != -1 and testLabels_[1] != -1 and testLabels_[2] != -1 and onlineLabels_[0] != -1 and onlineLabels_[1] != -1 and onlineLabels_[2] != -1:
			testERR_ = err(testLabels_, len(testLabels_))
			onlineERR_ = err(onlineLabels_, len(onlineLabels_))
			testERR3Sum_ += testERR_
			onlineERR3Sum_ += onlineERR_
			if abs(testERR_ - onlineERR_) < ERR3_DIFF:
				draw3 += 1
			elif testERR_ > onlineERR_:
				win3  += 1
			else:
				lose3 += 1

		# 计算前二都有标注的ERR分数, 胜出落败情况; 同时记录前二diff个数
		if diffs[query][0] != diffs[query][dfn] or diffs[query][2] != diffs[query][dfn+1]:
			if testLabels_[0] != -1 and testLabels_[1] != -1 and onlineLabels_[0] != -1 and onlineLabels_[1] != -1:
				testERR_ = err(testLabels_, 2)
				onlineERR_ = err(onlineLabels_, 2)
				testERR2Sum_ += testERR_
				onlineERR2Sum_ += onlineERR_
				if abs(testERR_ - onlineERR_) < ERR2_DIFF:
					draw2 += 1
				elif testERR_ > onlineERR_:
					win2  += 1
				else:
					lose2 += 1
			top2difftotal += 1
		else:
			top2sameIntop3diff += 1
	
	# 输出指标字符串	
	metric_string = "\nM1. 前三diff ERR, 未标注文件\n" \
			+ "前三条 diff 数：" + str(win+draw+lose) + "\n" \
			+ "未标注(前三条)：test(" + str(testNolabel) + ") online(" + str(onlineNolabel) + ")\n" \
			+ "未标注(第一条): test(" + str(test1Nolabel) + ") online(" + str(online1Nolabel) + ")\n" \
			+ "未标注(第二条): test(" + str(test2Nolabel) + ") online(" + str(online2Nolabel) + ")\n" \
			+ "未标注(第三条): test(" + str(test3Nolabel) + ") online(" + str(online3Nolabel) + ")\n" \
			+ "1.未标注文档设0分" \
			+ "\n	Top3_total: " + str(win+draw+lose) \
			+ "\n	ERR@3win: " + str(win) \
			+ "\n	ERR@3draw: " + str(draw) \
			+ "\n	ERR@3lose: " + str(lose) \
			+ "\n	ERR@3winRatio: " + str((win + draw/2.0)/(win + lose + draw)) \
			+ "\n	testERR@3-onlineERR@3: " + str(testERR3Sum - onlineERR3Sum) \
			+ "\n	DCG@1win: " + str(winDCG1) \
			+ "\n	DCG@1draw: " + str(drawDCG1) \
			+ "\n	DCG@1lose: " + str(loseDCG1) \
			+ "\n	DCG@1winRatio: " + str((winDCG1 + drawDCG1/2.0) / (winDCG1 + loseDCG1 + drawDCG1)) \
			+ "\n2.丢弃未标注的query" \
			+ "\n2.1(考虑前三diff, 其中首条url相同和前二url相同算持平)" \
			+ "\n	Top1_total: " + str(win1+lose1+draw1 + top1sameIntop3diff) + "/" + str(top1difftotal+ top1sameIntop3diff) + "/" + str((win1+lose1+draw1+top1sameIntop3diff) * 1.0 / (top1difftotal + top1sameIntop3diff)) \
			+ "\n	DCG@1win: " + str(win1) \
			+ "\n	DCG@1draw: " + str(draw1 + top1sameIntop3diff) \
			+ "\n	DCG@lose: " + str(lose1) \
			+ "\n	DCG@1winRatio: " + str((win1 + (draw1 + top1sameIntop3diff) / 2.0) / (win1 + lose1 + draw1 + top1sameIntop3diff)) \
			+ "\n	Top2_total: " + str(win2+lose2+draw2 + top2sameIntop3diff) + "/" + str(top2difftotal+ top2sameIntop3diff)+ "/" + str((win2+lose2+draw2+top2sameIntop3diff) * 1.0 / (top2difftotal + top2sameIntop3diff)) \
			+ "\n	ERR@2win: " + str(win2) \
			+ "\n	ERR@2draw: " + str(draw2) \
			+ "\n	ERR@2lose: " + str(lose2) \
			+ "\n	ERR@2winRatio: " + str((win2 + (draw2 + top2sameIntop3diff) / 2.0) / (win2 + lose2 + draw2 + top2sameIntop3diff)) \
			+ "\n	testERR@2-onlineERR@2: " + str(testERR2Sum_ - onlineERR2Sum_) \
			+ "\n	Top3_total: " + str(win3 + lose3 + draw3) + "/" + str(win + draw + lose) + "/" + str((win3 + lose3 + draw3) * 1.0 / (win + draw + lose)) \
			+ "\n	ERR@3win: " + str(win3) \
			+ "\n	ERR@3draw: " + str(draw3) \
			+ "\n	ERR@3lose: " + str(lose3) \
			+ "\n	ERR@3winRatio: " + str((win3 + draw3/2.0) / (win3 + lose3 + draw3)) \
			+ "\n	testERR@3-onlineERR@3: " + str(testERR3Sum_ - onlineERR3Sum_) \
			+ "\n2.2(只考虑diff, 前三同2.1)" \
			+ "\n	Top1_total: " + str(win1+lose1+draw1) + "/" + str(top1difftotal) + "/" + str((win1+lose1+draw1) * 1.0 / top1difftotal) \
			+ "\n	DCG@1win: " + str(win1) \
			+ "\n	DCG@1draw: " + str(draw1) \
			+ "\n	DCG@lose: " + str(lose1) \
			+ "\n	DCG@1winRatio: " + str((win1 + draw1/2.0) / (win1 + lose1 + draw1)) \
			+ "\n	Top2_total: " + str(win2+lose2+draw2) + "/" + str(top2difftotal) + "/" + str((win2+lose2+draw2) * 1.0 / top2difftotal) \
			+ "\n	ERR@2win: " + str(win2) \
			+ "\n	ERR@2draw: " + str(draw2) \
			+ "\n	ERR@2lose: " + str(lose2) \
			+ "\n	ERR@2winRatio: " + str((win2 + draw2 / 2.0) / (win2 + lose2 + draw2)) \
			+ "\n	testERR@2-onlineERR@2: " + str(testERR2Sum_ - onlineERR2Sum_) + "\n"
	
	out_result = sys.stdout;	
	out_result.write(metric_string)	

	metrics_out_result += metric_string
	metrics_out_result += top1NolabelInfo

	out_result.write("LOSE CASE/WIN CASE/DRAW CASE\n")
	out_result.write("\nLOSE CASE:\n")
	for query in loseQ:
		out_result.write("\n".join(diffsBackup[query]) + "\n")
		
	out_result.write("\nWIN CASE:\n\n")
	for query in winQ:
		out_result.write("\n".join(diffsBackup[query]) + "\n")

	out_result.write("\nDRAW CASE:\n\n")
	for query in drawQ:
		out_result.write("\n".join(diffsBackup[query]) + "\n")

def calLabeledAvgPos(testFile, onlineFile, labelall):

	global metrics_out_result
	avg_pos_test = 0.0
	avg_pos = {}
	for line in open(testFile):
		items = line.strip().split("\t")
		query = items[1]
		pos   = int(items[0])
		url   = items[2].split(" | ")[0].strip()
		if labelall.has_key(query+"\t"+url) and labelall[query+"\t"+url] > 0: # 0分结果不算
			if avg_pos.has_key(query):
				avg_pos[query].append(pos)
			else:
				avg_pos[query] = [pos]
	avg_pos_online = 0.0
	avg_pos2 = {}
	for line in open(onlineFile):
		items = line.strip().split("\t")
		query = items[1]
		pos   = int(items[0])
		url   = items[2]
		if labelall.has_key(query+"\t"+url) and labelall[query+"\t"+url] > 0: # 0分结果不算
			if avg_pos2.has_key(query):
				avg_pos2[query].append(pos)
			else:
				avg_pos2[query] = [pos]
	
	out_result = sys.stdout
	out_result.write("\n\nM3. 已标注文档平均位置变化\n")
	# out_result.write("##########################################################################\n\n")
	
	avg_pos_list = []
	avg_pos2_list = []
	win = 0
	draw = 0
	lose = 0

	for query in set(avg_pos.keys()) & set(avg_pos2.keys()):
		avg_test = sum(avg_pos[query]) * 1.0 / len(avg_pos[query])
		avg_online = sum(avg_pos2[query]) * 1.0 / len(avg_pos2[query])
		out_result.write(query + "\tavg_pos_test: " +  str(avg_test) + " labeledcnt: " + str(len(avg_pos[query])) \
				+ "\tavg_pos_online: " + str(avg_online) + " labededcnt: " + str(len(avg_pos2[query])) + "\n")
		avg_pos_list.append(avg_test)
		avg_pos2_list.append(avg_online)
		if avg_test < avg_online:
			win += 1
		elif avg_test == avg_online:
			draw += 1
		else:
			lose += 1
	out_result.write("\n\nMacro avg_pos test: " + str(sum(avg_pos_list)*1.0/len(avg_pos_list)) + " online: " + str(sum(avg_pos2_list)*1.0/len(avg_pos2_list)) +"\n")
	metrics_out_result += "\nM3. 已标注文档平均位置变化\n" \
			+ "	Macro avg_pos test: " + str(sum(avg_pos_list)*1.0/len(avg_pos_list)) \
			+ "	online: " + str(sum(avg_pos2_list)*1.0/len(avg_pos2_list)) + "\n" \
			+ "	win: " + str(win) +"\n" \
			+ "	draw: " + str(draw) + "\n" \
			+ "	lose: "  + str(lose) + "\n" \
			+ "	winRatio: " + str((win + draw/2) *1.0 / (win + draw + lose)) +"\n\n"

def calScoreMetricOnlyLabeled(testFile, onlineFile, labelall):
	global metrics_out_result
	online = {}
	onlineL = {}
	for line in open(onlineFile):
		items = line.strip().split("\t")
		query = items[1]
		pos   = int(items[0])
		url   = items[2].split(" | ")[0].strip()
		if labelall.has_key(query+"\t"+url):
			label = labelall[query+"\t"+url]
			if online.has_key(query):
				online[query].append(str(pos) + "\t" + query + "\t" + url + "\t" + str(label))
				onlineL[query].append(label)
			else:
				online[query] = [str(pos) + "\t" + query + "\t" + url + "\t" + str(label)]
				onlineL[query] = [label]
	test = {}
	testL = {}
	for line in open(testFile):
		items = line.strip().split("\t")
		query = items[1]
		pos   = int(items[0])
		url   = items[2].split(" | ")[0].strip()
		if labelall.has_key(query+"\t"+url):
			label = labelall[query+"\t"+url]
			if test.has_key(query):
				test[query].append(str(pos) + "\t" + query + "\t" + url + "\t" + str(label))
				testL[query].append(label)
			else:
				test[query] = [str(pos) + "\t" + query + "\t" + url + "\t" + str(label)]
				testL[query] = [label]						
	
	win = 0
	winQ = set()
	draw = 0
	drawQ = set()
	lose = 0
	loseQ = set()
	testERR3Sum = 0.0
	onlineERR3Sum = 0.0
	win1  = 0
	draw1 = 0
	lose1 = 0

	for query in onlineL.keys():
		if not testL.has_key(query):
			continue
		if len(onlineL[query]) == 0 or len(testL[query]) == 0:
			continue
		onlineERR = err(onlineL[query], min(3, len(onlineL[query])))
		testERR   = err(testL[query], min(3, len(testL[query])))
		onlineERR3Sum += onlineERR
		testERR3Sum += testERR

		if abs(onlineERR - testERR) < ERR3_DIFF:
			draw += 1
			drawQ.add(query)
		elif onlineERR < testERR:
			win += 1
			winQ.add(query)
		else: 
			lose += 1
			loseQ.add(query)
		
		if onlineL[query][0] < testL[query][0]:
			win1 += 1
		elif onlineL[query][0] == testL[query][0]:
			draw1 += 1
		else:
			lose1 += 1

	line = "\nM2. 前三ERR, 去掉未标注文件\n" \
			+ "Top3_total: " + str(win+draw+lose) \
			+ "\n	ERR@3win: " + str(win) \
			+ "\n	ERR@3draw: " + str(draw) \
			+ "\n	ERR@3lose: " + str(lose) \
			+ "\n	ERR@3winRatio: " + str((win + draw/2.0)/(win + lose + draw)) \
			+ "\n	testERR@3-onlineERR@3: " + str(testERR3Sum - onlineERR3Sum) \
			+ "\n	DCG@1win: " + str(win1) \
			+ "\n	DCG@1draw: " + str(draw1) \
			+ "\n	DCG@1lose: " + str(lose1) \
			+ "\n	DCG@1winRatio: " +  str((win1 + draw1/2.0)/(win1 + lose1 + draw1)) + "\n"
	metrics_out_result += line 
	out_result = sys.stdout;	
	out_result.write(line)
	out_result.write("LOSE CASE/WIN CASE/DRAW CASE\n")
	out_result.write("\nLOSE CASE:\n\n")
	for query in loseQ:
		out_result.write("TEST:" + "\n".join(test[query]) + "\n")
		out_result.write("ONLINE:" + "\n".join(online[query]) + "\n")
		
	out_result.write("\nWIN CASE:\n\n")
	for query in winQ:
		out_result.write("TEST:" + "\n".join(test[query]) + "\n")
		out_result.write("ONLINE:" + "\n".join(online[query]) + "\n")

	out_result.write("\nDRAW CASE:\n\n")
	for query in drawQ:
		out_result.write("TEST:" + "\n".join(test[query]) + "\n")
		out_result.write("ONLINE:" + "\n".join(online[query]) + "\n")

def formatDiffForAnnonation(diffFile):
	'''
	为兼容自测系统接口
	'''
	fout = open(diffFile+".anno", "w")
	querys = []
	querysSet=set()
	queryUrls = {}
	for line in open(diffFile):
		items = line.strip().split("\t")
		if len(items) > 3:
			query = items[0]
			no    = items[1]
			url   = items[2]
			if query not in querysSet:
				querysSet.add(query)
				querys.append(query)
			if queryUrls.has_key(query):
				queryUrls[query].append(url)
			else:
				queryUrls[query] = [url]
	for query in querys:
		urls = queryUrls[query]
		n = len(urls)
		test   = urls[0:3]
		online = urls[n/2:n/2+3]
		for i in range(1,4):
			fout.write(query + "\t" + test[i-1]  + "\t" + str(i)  + "\ttest\n")
		for i in range(1,4):
			fout.write(query + "\t" + online[i-1] + "\t" + str(i)  + "\tonline\n")
	fout.close()

metrics_out_result = "模型自测指标\n"

def main():
	if len(sys.argv) != 6:
		sys.stderr.write("Usage:\n  ./self_evaluate.py labelallFile testFile onlineFile diffFile metricsResultFile > detailResultFile\n")
		return
	global metrics_out_result
	labelallFile = sys.argv[1]
	testFile = sys.argv[2]
	onlineFile = sys.argv[3]
	diffFile = sys.argv[4]
	metricsResultFile = sys.argv[5]
	
	# load labelallFile
	labelall = {}
	for line in open(labelallFile):
		items = line.strip().split("\t")
		if len(items) == 3:
			try:
				labelall[items[0] + "\t" + items[1]] = float(items[2])
			except:
				pass
	
	sys.stdout.write("自测包括三个指标：M1 M2 M3\n")		
	# 计算前三指标
	calScoreMetric(diffFile, labelall) 
	calScoreMetricOnlyLabeled(testFile, onlineFile, labelall)
	# 计算已对出来label的doc平均位置
	calLabeledAvgPos(testFile, onlineFile, labelall)
	open(metricsResultFile,"w").write(metrics_out_result)
	formatDiffForAnnonation(diffFile)

if __name__ == "__main__":
	main()
