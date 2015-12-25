import sys
import os

if __name__=="__main__":
	trainDir = sys.argv[1]
        datadir = sys.argv[2]
        pairMap = {}
        rootdir=trainDir+"/RelevanceLTRData/codename/" + datadir + "/results/"
	outputfile=rootdir+datadir
        for parent,dirnames,filenames in os.walk(rootdir):
                for filename in filenames:
                        path=rootdir+filename
                        if "all.diff.anno" not in path or "oldmodelresult" in path:
                                continue
                        print '%s' % path
                        fin = open(path,'r')
                        while 1:
                                line = fin.readline()
                                if not line:
                                        break
                                ts = line.strip().split('\t')
                                if len(ts)!=4:
                                        continue
                                key = ts[0].strip() + '\t' + ts[1].strip()
                                if pairMap.has_key(key):
                                        continue
                                pairMap[key] = 1
                        fin.close()

        fout = open(outputfile+'.dat','w')
        for k,v in pairMap.items():
                fout.write(k+'\t'+str(v)+'\n')
        fout.close()
