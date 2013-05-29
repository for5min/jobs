#!/usr/bin/python
import gzip
import os
import glob
import sys
def date():
    LOGPATH = "/home/atu/logs"
    os.chdir(LOGPATH)
    print """By default, the progrom will only have 2013's users, if you want more,please contact with administrator"""
    MONTH1 = str(raw_input("Which month you would like to start:(MM)"))
    DATE1 = str(raw_input("Which date you would like to specific:(DD)")) #Could add default value
    MONTH2 = str(raw_input("Which month you would like to end:(MM)"))
    DATE2 = str(raw_input("Which date you would like to specific:(DD)")) #Could add default value
  
    if int(MONTH1) > int(MONTH2):
     print ("Your start period had to greater than end period")
     exit(1)
  
     #print ("your date will start from {0}-{1} to {2}-{3}").format(MONTH1,DATE1,MONTH2,DATE2)
  
    elif int(MONTH1) == int(MONTH2):
      for d in range(int(DATE1),int(DATE2)+1):
          for file in glob.glob("sshd_log.2013-{0}-{1:02}.gz".format(MONTH1,d)):
              for line in gzip.open(file):
                  output = open('sshd.txt','aw+')
                  output.writelines(line)
                  output.close()
    else:
      for d1 in range(int(DATE1),32):
          for file in glob.glob("sshd_log.2013-{0}-{1:02}.gz".format(MONTH1,d1)):
              for line in gzip.open(file):
                  output = open('sshd.txt','aw+')
                  output.writelines(line)
                  output.close()
      for d2 in range(0,int(DATE2)+1):
          for file1 in glob.glob("sshd_log.2013-{0}-{1:02}.gz".format(MONTH2,d2)):
              for line1 in gzip.open(file1):
                  output = open('sshd.txt','aw+')
                  output.writelines(line1)
                  output.close()
    print "Processing..." 
  
if __name__=="__main__":
   date()
   os.system("awk '/FROM/' sshd.txt | awk '{print $5}' | sort -u | sed 's/\[//g' > sshd_log.txt")
   print "Done...."
          
  
  
