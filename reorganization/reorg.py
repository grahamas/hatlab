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

import datetime

from validate_records import validate_records


###### Constants #######

RECORD_FNAME = 'record.json' #oldname
UNPDICT_FNAME = 'unpdict.json' #newname

########################
##### Functions ########

def displaymatch(match):
    if match is None:
        return None
    return '<Match: %r, groups=%r>' % (match.group(), match.groups())

def get_copy_dict(monkey_path, copy_dict_name='record.json'):
    pass

def new_copy_dict(source_monkey_dirs, target_monkey_dir,
        copy_dict_name='record.json'):
    pass



#########################
######## Class ##########

class File:
    def __init__(self, path):
        if not os.isfile(path):
            raise ValueError("Only use File class for existing files.")
        self.path = path
        self.sha = None
        self.hashedtime = 0
    def hash(self, force_check=False):
        if self.hashedtime < os.path.getmtime(self.path):
            force_check = True
        if self.sha and not force_check:
            return self.sha
        else:
            bname = os.path.basename(self.path)
            print "Hashing " + bname
            start = timeit.default_timer()
            with open(self.path,'rb') as f:
                self.sha = sop.hashfile(f)
            elapsed = timeit.default_timer() - start
            print "Done. Time: " + str(elapsed) + " for " + bname
            self.hashedtime = time.gmtime()
            return self.sha
    def __len__(self):
        return os.path.getsize(self.path)


class OrganizedFile(File):
    def __init__(self, path, source_path):
        super(OrganizedFile, self).__init__(self, path)
        self.source_paths = [source_path]
    def sources_hash_equal(self, all_sources, force_check=False):
        if len(self.sources) == 1:
            return True
        source_objs = map(lambda source_path: all_sources[source_path],self.source_paths)
        return reduce(operator.eq, map(lambda source: return source.hash(force_check), 
            source_objs))
    def first_source_hashes_equal(self, all_sources, force_check=False):
        first_source = all_sources[self.source_paths[0]]


class SourceFile(File):
    def __init__(self, path):
        super(SourceFile, self).__init__(self, path)
        self.copied = False
        self.destination = None

#########################
######## Setup ##########
#########################

parser = argparse.ArgumentParser()
parser.add_argument('--source_dirs', nargs='+', required=True,
    description='Name of all source directories.')
parser.add_argument('--target_dir', nargs='1', required=True,
    description="""Name of reorganized directory root.""")
parser.add_argument('--monkey', action='store', required=True,
    description="""Name of monkey. Only one monkey per run.
    NOTE: Monkey name must match exactly a subdirectory of each source_dir.""")
parser.add_argument('--full_run', action='store-const', const=True,
    default=False, description='If this flag is present, will copy files.')
parser.add_argument('--use_existing_copy_dict', action='store-const', const=True,
    default=False, description='If this flag is present, will look for a copy_dict')
args = parser.parse_args()

monkey_name = args.monkey
full_run = args.full_run
use_existing_copy_dict = args.use_existing_copy_dict

# Validation functions
def strip_mnky_name(path):
    head, tail = os.path.split(path)
    if tail == monkey_name:
        tail = ''
    return os.path.join(head, tail)

has_mnky_dir = lambda d: return monkey_name in os.listdir(d)
    
source_dirs = [strip_mnky_name(path) for path in args.source_dirs]
target_dir = strip_mnky_name(args.target_dir)

if not all(map(os.path.isabs,source_dirs)):
    raise ValueError("All input dirs must be absolute paths.")

if not os.path.isabs(target_dir):
    raise ValueError("All input dirs must be absolute paths.")

if not all(map(has_monkey_dir, source_dirs)):
    raise ValueError("One or more source_dirs does not contain a monkey dir.")

if not has_monkey_dir(target_dir):
    os.mkdir(os.path.join(target_dir, monkey_name))

#########################
######## Action #########
#########################

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

#############################################################################
####################### HERE LIES THE CONTROL FLOW ##########################
#############################################################################

### These are the names of the directories where the files will move from/to
source_monkey_dirs = map(lambda d: return os.path.join(d, monkey_name), 
    source_dirs)
target_monkey_dir  = os.path.join(target_dir, monkey_name)

if use_existing_copy_dict:
    copy_dict = get_copy_dict(target_monkey_dir)
else:
    copy_dict = new_copy_dict(source_monkey_dirs, target_monkey_dir)

if full_run:
    copy_files(copy_dict)
