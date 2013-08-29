#!/usr/bin/python
"""
   By default, the progrom will only have 2013's users,
   if you want more,please contact with administrator
"""
import gzip
import os
import glob
import sys
import urllib2

#LOGPATH = "/local/home/gerrit2/review_sh/logs"
LOGPATH = "/tmp/logs"
year = "2013"

def generate_log(filename,year,start_month,day):
	for file in glob.glob("{0}_log.{1}-{2}-{3:02}.gz".format(filename,year,start_month,day)):
  			for line in gzip.open(file):
  				output = open('{0}.txt'.format(filename),'aw+')
  				output.writelines(line)
  				output.close()


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
  		generate_log(filename,year,start_month,d)

  else :
  	for d1 in range(int(start_date),32):
  		generate_log(filename,year,start_month,d1)


  	for d2 in range(0,int(end_date)+1):
  		generate_log(filename,year,start_month,d2)


def main():
	ensure_dir()
	if filename == 'sshd':
		date()
		os.system("awk '/FROM/' sshd.txt | awk '{print $5}' | sort -u | sed 's/\[//g' > sshd_user.txt")
		os.system("awk '/FROM/' sshd.txt | awk '{print $1,$5}' | sort -u | sed 's/\[//g' > sshd_log_timestamp.txt")
		print ("Done....")
	elif filename == 'httpd':
		date()
		os.system("awk '{print $3}' httpd.txt | sort -u | sed -e '/127.0.0.1/d' -e '/-/d' -e 's/\[//g' > httpd_user.txt")
		os.system("awk '{print $3,$4}' httpd.txt | sort -u | sed -e '/127.0.0.1/d' -e '/-/d' -e 's/\[//g' > httpd_log_timestamp.txt")
		print ("Done....")
	else:
		print ("Beeeeeeeeeeee.................")




if __name__=="__main__":
	filename = raw_input("Which log you would like to have?(sshd/httpd)")
	main()
