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
import argparse


###### Constants #######

RECORD_FNAME = 'record.txt'

########################
##### Functions ########


### NOTE: This function is only required if there is NOT a record within the new reorg.
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

parser = argparse.ArgumentParser()
parser.add_argument('--source_dirs', nargs='+', required=True,
    description='Name of all source directories.')
parser.add_argument('--target_dir', nargs='1', required=True,
    description="""Name of reorganized directory root.""")
parser.add_argument('--monkey', action='store', required=True,
    description="""Name of monkey. Only one monkey per run.
    NOTE: Monkey name must match exactly a subdirectory of each source_dir.""")
args = parser.parse_args()

monkey_name = args.monkey

def strip_mnky_name(path):
    head, tail = os.path.split(path)
    if tail == monkey_name:
        tail = ''
    return os.path.join(head, tail)
    
source_dirs = [strip_mnky_name(path) for path in args.source_dirs]
target_dir = strip_mnky_name(args.target_dir)

has_mnky_dir = lambda d: return monkey_name in os.listdir(d)

if not all(map(os.path.isabs,source_dirs)):
    raise ValueError("All input dirs must be absolute paths.")

if not os.path.isabs(target_dir):
    raise ValueError("All input dirs must be absolute paths.")

if not all(map(has_monkey_dir, source_dirs)):
    raise ValueError("One or more source_dirs does not contain a monkey dir.")

if not has_monkey_dir(target_dir):
    os.mkdir(os.path.join(target_dir, monkey_name))



reorganized_dir = r"Z:\\Data\\all_raw_datafiles_gs\\Zizou"
oldname = os.path.join(target_dir,"record.json")
newname = os.path.join(target_dir,"unpdict.json")

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
#   print '{} => {}'.format(key,value)
#   shutil.copy2(key, value) # copy2 preserves modification time, which is useful for later confirmation or categorization.

# print "... done."

