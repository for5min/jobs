#!/usr/bin/python
"""
   By default, the progrom will only have 2013's users,
   if you want more,please contact with administrator
"""
import gzip
import os
import glob
import sys

LOGPATH = "/tmp/logs"
year = "2013"


def ensure_dir():
  if os.path.exists(LOGPATH):
      os.chdir(LOGPATH)
  else:
		print ("We don't have working log directory!")

def date():
  #LOGPATH = "/home/atu/logs"
  #os.chdir(LOGPATH)
  smd = raw_input("Start Month Date:(MM-DD)")
  emd = raw_input("End Month Date:(MM-DD)")
  start_month = smd.split('-')[0]
  start_date  = smd.split('-')[1]
  end_month   = emd.split('-')[0]
  end_date    = emd.split('-')[1]
  print ("Processing...")

  if start_month > end_month :
  	print ("Currently, we are not supporting this function!")

  elif start_month == end_month :
  	for d in range(int(start_date),int(end_date)+1):
  		for file in glob.glob("sshd_log.{0}-{1}-{2:02}.gz".format(year,start_month,d)):
  			for line in gzip.open(file):
  				output = open('sshd.txt','aw+')
  				output.writelines(line)
  				output.close()

  else :
  	for d1 in range(int(start_date),32):
  		for file in glob.glob("sshd_log.{0}-{1}-{2:02}.gz".format(year,start_month,d1)):
  			for line in gzip.open(file):
  				output = open('sshd.txt','aw+')
  				output.writelines(line)
  				output.close()


  	for d2 in range(0,int(end_date)+1):
  		for file1 in glob.glob("sshd_log.{0}-{1}-{2:02}.gz".format(year,end_month,d2)):
  			for line1 in gzip.open(file1):
  				output = open('sshd.txt','aw+')
  				output.writelines(line1)
  				output.close()

def main():
	ensure_dir()
	date()


if __name__=="__main__":
	main()
	os.system("awk '/FROM/' sshd.txt | awk '{print $5}' | sort -u | sed 's/\[//g' > sshd_log.txt")
	print "Done...."


