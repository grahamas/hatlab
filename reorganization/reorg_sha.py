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


          



#########################
###### Functions ########

# Credit Omnifarious on stack overflow
def hashfile(afile, hasher, blocksize=65536):
        buf = afile.read(blocksize)
        while len(buf) > 0:
                hasher.update(buf)
                buf = afile.read(blocksize)
        return hasher.hexdigest()

def hashdict(copydict):
        """Returns invalids, sha2src."""
        sha2src = dict()
        dupes = dict()
        invalids = dict()
        mysize = 0
        for src in copydict:
                mysize += os.path.getsize(src)
        mysize *= 2
        for src, dst in copydict.items():
                print src
                sname = os.path.basename(src)
                dname = os.path.basename(dst)
                with open(src, 'rb') as fsrc:
                        print "Hashing " + sname
                        HASH = hashlib.sha256()
                        start = timeit.default_timer()
                        print fsrc
                        src_sha = hashfile(fsrc, HASH)
                        elapsed = timeit.default_timer() - start
                        print "Time: " + str(elapsed) + " for " + sname
                        print "Done hashing " + sname
                        mysize -= os.path.getsize(src)
                        print str(mysize / 1000000000.0) + "GB"
                with open(dst, 'rb') as fdst:
                        print "Hashing " + dname
                        HASH = hashlib.sha256()
                        dst_sha = hashfile(fdst, HASH)
                        print "Done hashing " + dname
                        mysize -= os.path.getsize(dst)
                        print str(mysize / 1000000000.0) + "GB"
                if src_sha in sha2src:
                        sha2src[src_sha].append(src)
                        print "Found duplicate: " + sname
                else:
                        sha2src[src_sha] = [src]
                if not src_sha == dst_sha:
                        invalids[src] = dst
                        print "Invalid hash! " + dname
        return (invalids, sha2src)

#########################
####### Classes #########


def run(tid, dct, statusq, retq):
        print "Starting " + str(tid)
        ret = hashdict(dct, statusq)
        retq.put(ret)
        print "Exiting " + str(tid)
        print 'STOP'
                
                        
#########################
######## Setup ##########
        
if __name__ == '__main__':

        NUMPROC = 20

        ##argc = len(sys.argv)
        ##if argc != 3:
        ##       print """Invalid number of arguments\
        ##       \nUsage: reorg_fin.py json log"""
        ##       exit(1)
        ##
        ##jsonname = sys.argv[1]
        ##logname = sys.argv[2]

        jsonname = 'Z:\Data\\all_raw_datafiles_gs\Zizou\\record3.json'
        logname = 'Z:\Data\\all_raw_datafiles_gs\\results7.txt'
        shaname = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\sha2src.json'
        invshaname = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\invsha2src.json'
        invname = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\invalids.json'
        numinv = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\numinv.txt'
        duplistoldname = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\duplistold.txt'
        duplistnewname = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\duplistnew.txt'
        dupmapname = 'Z:\Data\\all_raw_datafiles_gs\\Zizou\\dupmap.txt'

        with open(jsonname, 'r') as jsonfile:
                copydict = json.load(jsonfile)
##
##        (invalids, sha2src) = hashdict(copydict)
##
##        print "Writing sha dict"
##        with open(shaname, 'w') as shafile:
##                json.dump(sha2src, shafile, indent=4)
##        print "done."
##
##        print "Writing invalids"
##        with open(invname, 'w') as invfile:
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
##        with open(numinv, 'w') as numinvf:
##                numinvf.write(str(invc) + ' invalid.')

        with open(shaname, 'r') as shafile:
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

        with open(duplistoldname,'w') as dlofile:
                cnt = 1
                dlofile.write('This file contains the original names of duplicates\n\n')
                for dup in duplistold:
                        dlofile.write('Duplicate ' + str(cnt) + '\n')
                        for el in dup:
                                dlofile.write(el + '\n')
                        dlofile.write('\n')

        with open(duplistnewname,'w') as dlofile:
                cnt = 1
                dlofile.write('This file contains the new names of duplicates\n\n')
                for dup in duplistold:
                        dlofile.write('Duplicate ' + str(cnt) + '\n')
                        for el in dup:
                                dlofile.write(el + '\n')
                        dlofile.write('\n')

        with open(dupmapname,'w') as dmfile:
                cnt = 1
                dmfile.write('This file contains the mappings from old to new duplicate names\n\n')
                for dup in dupmap:
                        dmfile.write('Duplicate ' + str(cnt) + '\n')
                        for src, dst in dup.items():
                                dmfile.write(src + '\n\t => ' + dst + '\n')
                        dmfile.write('\n')
                        

        with open(invname, 'r') as invfile:
                invalids = json.load(invfile)

        invc = 0
        invsize = 0
        for invalid in invalids:
                invc += 1
                invsize += os.path.getsize(invalid)

        log = open(logname, 'w')

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
                                        hashsrc = hashfile(fin, hashlib.sha256())
                                        hashdst = hashfile(fout, hashlib.sha256())
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

        

        
##        count = 0
##        for src, dst in copydict.iteritems():
##                procdicts[count % NUMPROC][src] = dst
##                count += 1
##
##        print "Split dict"

##        pool  = Pool(NUMPROC)
##        retarray = pool.map_async(run, zip(range(NUMPROC), procdicts, [printlock] * NUMPROC, [retlock]*NUMPROC)).get()
##        procs = []
##        statusq = Queue()
##        retq = Queue()
##        for i in range(NUMPROC):
##                p = Process(target=run, args=(i, procdicts[i], statusq, retq))
##                p.start()
##                procs.append(p)
##
##        for p in procs:
##                for status in iter(statusq.get, 'STOP'):
##                        print status
##
##        for p in procs:
##                p.join()
##
##        print "Made queues, about to run"
##        run(0, copydict, statusq, retq)
##        print "Ran."
##
##        invalids = dict()
##        sha2src = dict()
##
##        dupecount = 0

##for i in range(NUMPROC):
##        (retinv, retsha) = retq.get()
##        for src, dst in retinv.items():
##                if src in invalids:
##                        print "PROBLEM: Same source seen twice."
##                else:
##                        invalids[src] = dst
##        for sha, arr in retsha.items():
##                if sha in sha2src:
##                        sha2src[sha] += arr
##                        dupecount += len(arr)
##                else:
##                        sha2src[sha] = arr
##                        dupecount += len(arr) - 1
##
##
##        print "There are " + dupecount + " duplicates."
##        print "Writing results."
##
##        with open('sha2src.json', 'w') as fsha2src:
##                json.dump(sha2src, fsha2src, indent=4)
##
##        with open('invalids.json', 'w') as finv:
##                json.dump(invalids, finv, indent=4)
##
##
##        print "... done."

##src = r"Z:\all_raw_datafiles_5\Unsorted Data\Not Yet Zipped\Zizou\DataE\Z11122012_M1Contra_ECoG2K001.nev"
##dst = r"Z:\Data\all_raw_datafiles_gs\Zizou\2012\11\\z20121101_M1Contra001.nev"
##
##start = timeit.default_timer()
##hashfile(open(src, 'rb'), HASH)
##elapsed = timeit.default_timer() - start
##print elapsed
##
##start = timeit.default_timer()
##
##elapsed = timeit.default_timer() - start
##print elapsed

##for src, dst in copydict.iteritems():
##        sha  = hashfile(open(src, 'rb'), HASH)
##        print('Hashed '  + src)
##        shas.append(sha)
##        expected[dst] = (sha, src)
##
##print "Writing sha256 json..."
##
##with open('shas.json', 'w') as shajson:
##        json.dump(expected, shajson, indent=4)
##
##print "Done writing shas."

##nosha = []
##shac = 0
##for unp in unparsed:
##        sha = hashfile(open(unp, 'rb'), HASH)
##        if sha not in shas:
##                nosha.append(unp)
##        else: shac += 1
##print "Same sha256: " + str(shac)
##print "Unparsed remaining: " + str(len(nosha))
##
##with open('unparsed.txt', 'w') as unpfile:
##        for unp in nosha:
##                unpfile.write(unp)
##
##print "Done writing unparsed list."
##print "Beginning checksums."
##
##corrupt = dict()
##for dst, (sha, src) in expected.iteritems():
##        dsha = hashfile(open(dst, 'rb'), HASH)
##        if not sha == dsha:
##                corrupt[src] = dst
##
##print "Writing json of corrupt files..."
##with open('corrupt.json', 'w') as cjson:
##        json.dump(corrupt, cjson, indent=4)
##print "Done writing corrupt json."
##

