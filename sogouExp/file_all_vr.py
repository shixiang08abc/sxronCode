import os
import os.path
import sys

rootdir=sys.argv[1]
oldresult=sys.argv[2]

for parent,dirnames,filenames in os.walk(rootdir):
	for filename in filenames:
		path=rootdir+filename
		if "all" not in path:
			continue
		command="sh compare.sh "+"\t"+path+"\t"+oldresult
		print command
		os.system(command)

file=open("q.tmp","r")
wfile=open("q.tmp.uniq","w")
dic={}
while 1:
	line=file.readline()
	if not line:
		break
	line=line.strip()
	if line not in dic:
		wfile.write(line+"\n")
		dic[line]=1
wfile.close()

command="sh getVR.sh "+"\t"+"q.tmp.uniq"+"\t""vr"
print command
os.system(command)


for parent,dirnames,filenames in os.walk(rootdir):
	for filename in filenames:
		path=rootdir+filename
		if ".diff" not in path:
			continue
		command="cat "+"\t"+path+"|perl insert_vr.pl vr|perl filter_ann.pl >"+rootdir+filename+".anno"
		print command
		os.system(command)


