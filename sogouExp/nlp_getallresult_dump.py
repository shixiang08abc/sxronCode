import os
import os.path
import sys

CacheDir=sys.argv[1]
trainDir=sys.argv[2]
datadir=sys.argv[3]
locateip=sys.argv[4]
queryterm=sys.argv[5]
leafmin=int(sys.argv[6])
leafmax=int(sys.argv[7])
leafgap=int(sys.argv[8])

rootdir=trainDir + "/RelevanceLTRData/codename/" + datadir + "/models"
print rootdir
print 'leafmin:%d\tleafmax:%d\tleafgap:%d' % (leafmin,leafmax,leafgap)

leaf = range(leafmin,leafmax,leafgap) 

for parent,dirnames,filenames in os.walk(rootdir):
	for filename in filenames:
		label=filename[filename.rindex(".")+1:]
		if ".f." not in filename:
			continue
		if int(label) in leaf:
			command="sh nlp_getcompare_dump.sh" + "\t" + CacheDir + "\t" + trainDir + "\t" + datadir + "\t" + "\t" + locateip + "\t" + queryterm +"\t" + filename
			print command
			os.system(command)
