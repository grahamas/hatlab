#!/usr/bin/env python

# This script intelligently completes making the copies indicated in
# a json file given the existing copies enumerated in a record.

import sys
import os
import re
import time
import itertools
import shutil
import json
import hashlib
import timeit
import threading
from multiprocessing import Process, Lock, Pool, Manager, Queue

# Home-made safe_file_ops module
import safe_file_ops as sop
        
            
#########################
######## Setup ##########
    
if __name__ == '__main__':

    # TODO: Make target_root an argument
    reorganized_root = "Z:\Data\\all_raw_datafiles_gs\\"
    # NOTE: Log goes into parent directory.
    log_fname = os.path.join(reorganized_root,'results.txt')

    # TODO: Make monkey an argument (possibly a list?)
    monkey_name = "Zizou"
    reorganized_monkey_dir = os.path.join(reorganized_root, monkey_name)

    create_output_fname = lambda name: os.path.join(reorganized_monkey_dir,
        name)

    # TODO: Procedurally generate new names to avoid clobbering
    json_fname = create_output_fname('record.json')
    sha_fname = create_output_fname('sha2src.json')
    invalid_sha_fname = create_output_fname('invsha2src.json')
    invalid_files_fname = create_output_fname('invalids.json')
    numinv_fname = create_output_fname('numinv.txt')
    duplistold_fname = create_output_fname('duplistold.txt')
    duplistnew_fname = create_output_fname('duplistnew.txt')
    dupmap_fname = create_output_fname('dupmap.txt')

    with open(json_fname, 'r') as jsonfile:
        copydict = json.load(jsonfile)

##        (invalids, sha2src) = hashdict(copydict)
##
##        print "Writing sha dict"
##        with sop.open_no_clobber(sha_fname, 'w') as shafile:
##                json.dump(sha2src, shafile, indent=4)
##        print "done."
##
##        print "Writing invalids"
##        with sop.open_no_clobber(invname, 'w') as invfile:
##                json.dump(invalids, invfile, indent=4)
##        print "done."
##        
##        dupc = 0
##        for sha, srcs in sha2src.items():
##                if len(srcs)> 1:
##                        dupc += 1
##
##        print "There are " + str(dupc) + " duplicate files."
##

##
##        invsha2src = dict()
##
##        with sop.open_no_clobber(numinv, 'w') as numinvf:
##                numinvf.write(str(invc) + ' invalid.')

    # Check to see if a sha2src file already exists
    if os.f

    with open(sha_fname, 'r') as shafile:
        sha2src = json.load(shafile)

    invsha2src = dict()

    duplistold = []
    duplistnew = []
    dupmap = []
    for sha, sources in sha2src.items():
        if len(sources) > 1:
            old = []
            new = []
            mapping = dict()
            for src in sources:
                old.append(src)
                dst = copydict[src]
                new.append(dst)
                mapping[src] = dst
            duplistold.append(old)
            duplistnew.append(new)
            dupmap.append(mapping)

    with sop.open_no_clobber(duplistold_fname,'w') as dlofile:
        cnt = 1
        dlofile.write('This file contains the original names of duplicates\n\n')
        for dup in duplistold:
            dlofile.write('Duplicate ' + str(cnt) + '\n')
            for el in dup:
                dlofile.write(el + '\n')
            dlofile.write('\n')

    with sop.open_no_clobber(duplistnew_fname,'w') as dlofile:
        cnt = 1
        dlofile.write('This file contains the new names of duplicates\n\n')
        for dup in duplistnew:
            dlofile.write('Duplicate ' + str(cnt) + '\n')
            for el in dup:
                dlofile.write(el + '\n')
            dlofile.write('\n')

    with sop.open_no_clobber(dupmap_fname,'w') as dmfile:
        cnt = 1
        dmfile.write('This file contains the mappings from old to new duplicate names\n\n')
        for dup in dupmap:
            dmfile.write('Duplicate ' + str(cnt) + '\n')
            for src, dst in dup.items():
                dmfile.write(src + '\n\t => ' + dst + '\n')
            dmfile.write('\n')
            

    with sop.open_no_clobber(invalids_fname, 'r') as invfile:
        invalids = json.load(invfile)

    invc = 0
    invsize = 0
    for invalid in invalids:
        invc += 1
        invsize += os.path.getsize(invalid)

    log = sop.open_no_clobber(log_fname, 'w')

    print "Beginning correction process (if necessary)."
    print "File size to process is " + str( invsize / 1000000000.0) + "GB"
    for src, dst in invalids.items():
        corrupt = True
        while corrupt:
            print src + " => " + dst
            os.remove(dst)
            with open(src, 'rb') as fin:
                with open(dst, 'wb') as fout:
                    shutil.copyfileobj(fin, fout, 512*1024)
            with open(src, 'rb') as fin:
                with open(dst, 'rb') as fout:
                    hashsrc = sop.hashfile(fin, hashlib.sha256())
                    hashdst = sop.hashfile(fout, hashlib.sha256())
                    if hashsrc == hashdst:
                        corrupt = False
                        invsha2src[hashsrc] = src
                    else:
                        print "Hashes do not match"
                        print "\t " + hashsrc
                        print "\t " + hashdst
        invsize -= os.path.getsize(src)
        log.write(src + ' => ' + dst + '\n')
        print str(invsize / 1000000000.0) + "GB remaining"
    close(log)

    print "all done."
        

    print "Writing invsha dict"
    with open(invshaname, 'w') as invshafile:
        json.dump(invsha2src, invshafile, indent=4)
    print "done."


