#!/usr/bin/env python

# This script is very naive. To protect the computer, it will ONLY 
# run if the target directory does not exist at runtime. 
# This proactively prevents clobbering.

import sys
import os
import re
import time
import itertools
import shutil
import json


###### Constants #######

MONKEY = 'zZ' # First value will be standard.

########################
##### Functions ########

def new_target(wd, dir_name):
	"""Create a target_dir if one is not provided"""
	# Make sure target_dir doesn't clobber anything
	target_dir = os.path.join(wd, dir_name + '_reorg')
	if os.path.exists(target_dir):
		valid_target = False;
		for i in xrange(5):
			target_dir = os.path.join(wd, dir_name + '_reorg' + str(i))
			if not os.path.exists(target_dir):
				valid_target = True;
				break
		if not valid_target:
			print """Arbitrary limit of 5 reorgs.
	Rewrite the code or delete some directories"""
			exit(1)

	# Now target_dir points to a non-existent directory
	try:
		os.makedirs(target_dir)
	except OSError:
		print "Error creating target directory"
		exit(1)

	return target_dir

def displaymatch(match):
	if match is None:
		return None
	return '<Match: %r, groups=%r>' % (match.group(), match.groups())

#########################
######## Setup ##########

##argc = len(sys.argv)
##if argc < 2:
##	print "Invalid number of arguments\nUsage: reorg.py [reorg_dir_name]+ target_dir"
##	exit(1)
##elif argc == 2:
##	source_dir = sys.argv[1]
##	if not os.path.isdir(source_dir):
##		print "Argument must be existing directory."
##		exit(1)
##	source_dirs.append(source_dir)
##	target_dir = False
##else:
##	for i in xrange(1,(argc-1)):
##		source_dir = sys.argv[i]
##		if not os.path.isdir(source_dir):
##			print "Argument must be existing directory."
##			exit(1)
##		source_dirs.append(source_dir)
##	target_dir = sys.argv[argc-1]
##

##
##cwd = os.getcwd();	
##
##numdirs = len(source_dirs)
##for i in xrange(numdirs):
##	# Note that join ignores all arguments preceding an absolute path.
##	# This make source_dir an absolute path.
##	source_dirs[i] = os.path.join(cwd, source_dirs[i])
##
##
##if target_dir:
##	if os.path.isdir(target_dir):
##		print "Target must NOT be existing directory (we're being extra careful here)"
##		exit(1)
##	else: 
##		try:
##			target_dir = os.path.join(cwd, target_dir)
##			os.makedirs(target_dir)
##		except OSError:
##			print "Error creating target directory"
##			exit(1)
##elif numdirs == 1:
##	(location_name, dir_name) = os.path.split(source_dirs[0])
##	wd = os.path.join(cwd, location_name)
##	target_dir = new_target(wd, dir_name)
##else:
##	print "Invalid input. Ambiguous target_dir."
##	exit(1)
##



target_dir = r"Z:\\Data\\all_raw_datafiles_gs\\Zizou"
oldname = target_dir + r"\\record2.json"
newname = target_dir + r"\\unpdict.json"

with open(oldname, 'r') as oldjson:
        olddict = json.load(oldjson)

with open(newname, 'r') as newjson:
        newdict = json.load(newjson)

for key, value in newdict.iteritems():
        newdict[key] = os.path.basename(value)

#########################
######## Action #########

remap = dict();
date = re.compile(r'[0-9]{8}')

for src, dst in newdict.iteritems():
        datestr = date.match(dst, 1).group()
        yr = datestr[:4]
        mn = datestr[4:6]
        day = datestr[6:8]
        newname = os.path.join(target_dir, yr, mn, dst)
        if newname in olddict.values():
                key = [key for key,value in olddict.items() if value == newname][0]
                print "{}\n{}\n".format(key, src)
                #exit(1)
        else:
                year_dir = os.path.join(target_dir, yr)
                month_dir = os.path.join(year_dir, mn)
                try:
                        if not os.path.isdir(year_dir):
                                os.makedirs(year_dir)
                        if not os.path.isdir(month_dir):
                                os.makedirs(month_dir)
                except OSError:
                        print "Error creating directory structure."
                        exit(1)
                if os.path.isfile(src):
                        remap[src] = newname
                        olddict[src] = newname
                else:
                        print "Invalid directory: " + src + "\n"

with open(os.path.join(target_dir, 'record3.json'), 'w') as jsonfile:
        json.dump(olddict, jsonfile, indent=4)
                                

# Note: This block was below the copy block when run.
print
print "Writing record"
with open(os.path.join(target_dir, "recordnew.json"), 'w') as jsonfile:
	json.dump(remap, jsonfile, sort_keys=True, indent=4)
print "... done."

print "There are " + str(len(remap)) + " changes to make."

sizeleft = 0
for key, value in remap.items():
        sizeleft += os.path.getsize(key)

print sizeleft / 1000000000.0

newlog = os.path.join(target_dir, 'manualupdate.log')

with open(newlog, 'w') as log:
        for source, target in remap.items():
                if not os.path.isfile(target):
                        print target
                        if not os.path.exists(os.path.dirname(target)):
                                os.makedirs(os.path.dirname(target))
                        with open(source, 'rb') as fin:
                                with open(target, 'wb') as fout:
                                        shutil.copyfileobj(fin, fout, 512*1024)
                        sizeleft -= os.path.getsize(source)
                        log.write(source + ' => ' + target + '\n')
                        print sizeleft / 1000000000.0

print 'done.'
        

# print
# print "Copying files"

# for key, value in remap.items():
# 	print '{} => {}'.format(key,value)
# 	shutil.copy2(key, value) # copy2 preserves modification time, which is useful for later confirmation or categorization.

# print "... done."

