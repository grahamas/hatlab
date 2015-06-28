#!/usr/bin/env python

#### WOW THIS IS TERRIBLE
#### PLEASE NOTE
#### THIS ASSUMES THAT A UNIX FILESYSTEM
#### HAS THE SHARED DRIVE
#### ROOTED AT THE SECOND LEVEL
#### E.G. /media/nicholab
#### GOD HELP US ALL

import re
import os
import sys
import time
import itertools
import shutil
import json
import argparse
import datetime

import safe_file_ops as sop

###### Constants #######

RECORD_FNAME = 'record.json' #oldname
UNPDICT_FNAME = 'unpdict.json' #newname
UNKNOWN_PATH = 'UNKNOWN'

DATE_RE_STRS = [r'[0-9]{8}', 
    r'[0-9]{6}', 
    r'\d{2}_\d{2}_\d{2}',
    r'\d{2}_\d{2}_\d{4}',
    r'\d{4}_\d{2}_\d{2}']

DATE_RES = map(re.compile, DATE_RE_STRS)

NON_NUMERIC_RE = re.compile(r'[^\d]+')

MIN_DATE = datetime.datetime.strptime('20120101','%Y%m%d').date()
MAX_DATE = datetime.datetime.now().date()

########################
##### Functions ########

def add_record_to_source_files(record, source_files, log=sys.stdout):
    for source, destination in record.iteritems():
        if source in source_files.keys():
            log.write('Source moved twice: {}\n'.format(source))
            if source_files[source].destination != destination:
                log.write('ERROR: Two destinations!\n')
                log.write('\t DESTINATION: {}\n'.format(source_files[source].destination))
                log.write('\t DESTINATION: {}\n'.format(destination))
        else:
            source_files[source] = SourceFile(source, destination)
    return source_files

def add_record_to_organized_files(record, organized_files, log=sys.stdout):
    for source, destination in record.iteritems():
        if destination in organized_files.keys():
            log.write('Destination with multiple sources: {}\n'.format(destination))
            if not organized_files[destination].add_source(source):
                log.write('Destination has same source:\n')
                log.write('\t DESTINATION: {}\n'.format(destination))
                log.write('\t SOURCE: {}\n'.format(source))
        else:
            organized_files[destination] = OrganizedFile(source, destination)
    return organized_files

def fix_path(path):
    new_path = sop.split_path(path)
    if new_path[0] == '':
        # unix path
        #print 'Found UNIX path. Attempting to fix.'
        new_path = new_path[3:] # BAAAAAAD
    elif ':' in new_path[0]:
        # windows path
        #print 'Found bad WINDOWS path. Attempting to fix.'
        new_path = new_path[1:] # BAAAAAAD
    else:
        raise ValueError("Ambiguous (or relative) path: " + path)
    return os.path.join(root,*new_path)

def verify_destinations_exist(source_files, organized_files,log=sys.stdout):
    """
        For each destination, ensure it exists.
    """
    all_exist = True
    for source,source_file in source_files.iteritems():
        destination = source_file.destination
        organized_file = organized_files[destination]
        if not organized_file.exists:
            all_exist = False
            log.write('Destination file does not exist\n')
            log.write('\t SOURCE: {}\n'.format(source))
            log.write('\t DESTINATION: {}\n'.format(destination))
    return all_exist

def ensure_organized_record_completeness(organized_files, log=sys.stdout):
    """
        Find any un-sourced files and add them to the organized_files dictionary.
        Note that this introduces a lot of irrelevant cruft due to not excluding
        non-date directory structures.
    """
    for root, dirs, files in os.walk(target_monkey_dir):
        monkey_files = filter(lambda f: f[0] == target_monkey_prefix, files)
        full_monkey_paths = map(lambda f: os.path.join(root, f), monkey_files)
        unexpected_files = filter(lambda f: f in organized_files, full_monkey_paths)
        for f in unexpected_files:
            log.write('{}\n'.format(f))
            organized_files[f] = OrganizedFile(source_path=UNKNOWN_PATH,path=f)
    return organized_files

def write_record_from_source_files(source_files, target_dir, record_fname=RECORD_FNAME):
    new_record = {k:v.destination for k,v in source_files.iteritems()}
    record_path = os.path.join(target_dir, record_fname)
    with sop.open_no_clobber(record_path, 'w') as f:
        json.dump(new_record, f)

def parse_record(record, source_files={}, organized_files={}, log=sys.stdout):
    source_files = add_record_to_source_files(record, source_files, log)
    organized_files = add_record_to_organized_files(record, organized_files, log)
    return source_files, organized_files

def validate_record(monkey_path, record_fname=RECORD_FNAME, log=sys.stdout):
    record = get_record(monkey_path, record_fname)
    if BAD_RECORDS:
        all_records = record
        source_files = {}
        organized_files = {}
        for record in all_records:
            source_files, organized_files = parse_record(record, source_files, organized_files) 
    #organized_files = ensure_organized_record_completeness(organized_files, log)
    if FIX_RECORDS:
        write_record_from_source_files(source_files)
    return verify_destinations_exist(source_files, organized_files, log)

def get_record(monkey_path, record_fname=RECORD_FNAME):
    record_path = os.path.join(monkey_path, record_fname)
    def open_record(path):
            with open(path, 'r') as record_file:
                record = json.load(record_file)
                return {fix_path(key):fix_path(value) for (key,value) in record.iteritems()}
    if BAD_RECORDS:
        all_record_paths = sop.get_all_versions(record_path)
        all_records = map(open_record, all_record_paths)
        return all_records
    else:
        record = open_record(record_path)
        return record

def from_old_record(monkey_path, record_fname=RECORD_FNAME):

    return parse_record(get_record(monkey_path, record_fname))

def from_new_record(source_monkey_dirs, target_monkey_dir, record_fname=RECORD_FNAME):
    current_record = get_record(target_monkey_dir, record_fname)
    source_files, organized_files = parse_record(current_record)
    for source_dir in source_monkey_dirs:
        for root, dirs, files in os.walk(source_dir):
            exclude_me = False
            for string in EXCLUDE_STRS:
                if string in root:
                    exclude_me = True
            if exclude_me:
                continue
            monkey_files = filter(lambda f: f[0] in source_monkey_prefices, files)
            full_monkey_paths = map(lambda f: os.path.join(root, f), monkey_files)
            for monkey_path in full_monkey_paths:
                if monkey_path not in source_files:
                    print 'New file: {}\n'.format(monkey_path)
                    source_files[monkey_path] = SourceFile.infer_destination(monkey_path, target_monkey_dir)
    write_record_from_source_files(source_files, target_monkey_dir)
    return source_files, organized_files

def infer_date(ambiguous, mod_time_epoch):
    """
        Infers an eight digit date of the form "YYYYmmdd" from either
        a six or eight digit date input of any (reasonable) similar format,
        plus the modification time in seconds since Unix epoch.
    """
    if len(ambiguous) == 6:
        year_case = 'y'
    else:
        year_case = 'Y'
    possible_formats = ['%{}%m%d'.format(year_case), '%d%m%{}'.format(year_case),
        '%m%d%{}'.format(year_case)]
    mod_date = datetime.datetime.fromtimestamp(mod_time_epoch).date()

    def to_date(dt, fmt):
        try:
            return datetime.datetime.strptime(dt, fmt).date()
        except ValueError:
            return datetime.datetime.fromtimestamp(0).date()

    possible_dates = map(lambda fmt: to_date(ambiguous, fmt), possible_formats)
    possible_dates = filter(lambda dt: dt > MIN_DATE and dt < MAX_DATE, possible_dates)
    possible_dates = filter(lambda dt: dt <= mod_date, possible_dates)

    if len(possible_dates) == 1:
        return possible_dates[0]

    possible_dates = filter(lambda dt: mod_date - dt < datetime.timedelta(30), possible_dates)

    if len(possible_dates) == 1:
        return possible_dates[0]

    possible_dates = list(set(possible_dates))

    if len(possible_dates) == 1:
        return possible_dates[0]

    possible_dates = filter(lambda dt: mod_date == dt, possible_dates)

    if len(possible_dates) == 1:
        return possible_dates[0]

#########################
######## Class ##########

class File(object):
    def __init__(self, path):
        self.exists = os.path.isfile(path)
        self.path = path
        self.sha = None
        self.hashedtime = 0
    def hash(self, force_check=False):
        """
            Hashes this file, using the hash function in SOP.

            PRINTS OUT STATUS
        """
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
    def __init__(self, source_path, path):
        super(OrganizedFile, self).__init__(path)
        self.source_paths = [source_path]
    def sources_hash_equal(self, all_sources, force_check=False):
        if len(self.sources) == 1:
            return True
        source_objs = map(lambda source_path: all_sources[source_path],self.source_paths)
        return reduce(operator.eq, map(lambda source: source.hash(force_check), 
            source_objs))
    def first_source_hash_equal(self, all_sources, force_check=False):
        first_source = all_sources[self.source_paths[0]]
    def add_source(self, source):
        if source in self.source_paths:
            return False
        else:
            self.source_paths.append(source)
            return True

class SourceFile(File):
    def __init__(self, path, destination):
        super(SourceFile, self).__init__(path)
        self.copied = False
        self.destination = destination
    @classmethod
    def infer_destination(cls, path, target_path):
        """
            Infers the path of the destination given the source path.
            Returns a SourceFile object with the appropriate destination.
        """
        output_date_format = '%Y%m%d'
        root, basename = os.path.split(path)
        path_time = os.path.getmtime(path)
        match_to_re = lambda r: r.match(basename, 1)
        matches = [x for x in map(match_to_re, DATE_RES) if x is not None]
        remove_non_numerics = lambda match: NON_NUMERIC_RE.sub('',match.group())
        date_strs = map(remove_non_numerics, matches)
        std_date = None
        print datetime.datetime.fromtimestamp(path_time).strftime('%Y%m%d')
        for date_str in date_strs:
            print date_str
            std_date = infer_date(date_str, path_time)
            print std_date
            if std_date is not None: break
        if std_date is None:
            raise ValueError("File name has no date: {}\n".format(path))
            return None
        fst, snd = basename.split(date_str)
        std_date_str = std_date.strftime(output_date_format)
        destination = os.path.join(target_path, str(std_date.year), str(std_date.month), fst + std_date_str + snd)
        return cls(path, destination)


#########################
######## Setup ##########
#########################

parser = argparse.ArgumentParser()
parser.add_argument('--source_dirs', action='store', nargs='+',
    help='Name of all source directories.')
parser.add_argument('--target_dir', action='store', required=True,
    help="""Name of reorganized directory root.""")
parser.add_argument('--monkey', action='store', required=True,
    help="""Name of monkey. Only one monkey per run.
    NOTE: Monkey name must match exactly a subdirectory of each source_dir.""")
parser.add_argument('--full_run', action='store_true',
    default=False, help='If this flag is present, will copy files.')
parser.add_argument('--use_existing_record', action='store_true',
    default=False, help='If this flag is present, will not generate a new record')
parser.add_argument('--just_validate_records', action='store_true',
    default=False, help="""If this flag is present, 
    will only validate existing record.""")
parser.add_argument('--root', action='store', required=True,
    help="Indicates the shared drive root (e.g. Z:)")
parser.add_argument('--bad_records', action='store_true',
    help="Use this to reconcile old records.")
parser.add_argument('--fix_records', action='store_true', default=False)
parser.add_argument('--exclude_dirs', action='store', nargs='+',
    help='Exclude directories containing this string.')
args = parser.parse_args()

monkey_name = args.monkey
full_run = args.full_run
use_existing_record = args.use_existing_record
just_validate_records = args.just_validate_records
root = args.root
BAD_RECORDS = args.bad_records
FIX_RECORDS = args.fix_records
EXCLUDE_STRS = args.exclude_dirs

# Validation functions
def strip_mnky_name(path):
    head, tail = os.path.split(path)
    if tail == monkey_name:
        tail = ''
    return os.path.join(head, tail)

has_monkey_dir = lambda d: monkey_name in os.listdir(d)

# Validate source_dirs    
if not just_validate_records:
    source_dirs = [strip_mnky_name(path) for path in args.source_dirs]
    if not all(map(os.path.isabs,source_dirs)):
        raise ValueError("All input dirs must be absolute paths.")
    if not all(map(has_monkey_dir, source_dirs)) or just_validate_records:
        raise ValueError("One or more source_dirs does not contain a monkey dir.")

# Validate target_dir
target_dir = strip_mnky_name(args.target_dir)
if not os.path.isabs(target_dir):
    raise ValueError("All input dirs must be absolute paths.")
if not has_monkey_dir(target_dir):
    os.mkdir(os.path.join(target_dir, monkey_name))

### These are the names of the directories where the files will move to
target_monkey_dir  = os.path.join(target_dir, monkey_name)
target_monkey_prefix = monkey_name[0].lower()
source_monkey_prefices = target_monkey_prefix + target_monkey_prefix.upper()


#############################################################################
####################### HERE LIES THE CONTROL FLOW ##########################
#############################################################################

if just_validate_records:
    validate_records(target_monkey_dir)
    sys.exit(0)

### These are the names of the directories where the files will move from
source_monkey_dirs = map(lambda d: os.path.join(d, monkey_name), 
    source_dirs)
if use_existing_record:
    source_files, organized_files = from_old_record(target_monkey_dir)
else:
    source_files, organized_files = from_new_record(source_monkey_dirs, target_monkey_dir)

if full_run:
    copy_files(source_files, organized_files)

#########################
######## Action #########
#########################

# remap = dict();
# date = re.compile(r'[0-9]{8}')

# for src, dst in newdict.iteritems():
#     datestr = date.match(dst, 1).group()
#     yr = datestr[:4]
#     mn = datestr[4:6]
#     day = datestr[6:8]
#     newname = os.path.join(target_dir, yr, mn, dst)
#     if newname in olddict.values():
#         key = [key for key,value in olddict.items() if value == newname][0]
#         print "{}\n{}\n".format(key, src)
#         #exit(1)
#     else:
#         year_dir = os.path.join(target_dir, yr)
#         month_dir = os.path.join(year_dir, mn)
#         try:
#             if not os.path.isdir(year_dir):
#                 os.makedirs(year_dir)
#             if not os.path.isdir(month_dir):
#                 os.makedirs(month_dir)
#         except OSError:
#             print "Error creating directory structure."
#             exit(1)
#         if os.path.isfile(src):
#             remap[src] = newname
#             olddict[src] = newname
#         else:
#             print "Invalid directory: " + src + "\n"

# with open(os.path.join(target_dir, 'record3.json'), 'w') as jsonfile:
#     json.dump(olddict, jsonfile, indent=4)
                

# # Note: This block was below the copy block when run.
# print
# print "Writing record"
# with open(os.path.join(target_dir, "recordnew.json"), 'w') as jsonfile:
#     json.dump(remap, jsonfile, sort_keys=True, indent=4)
# print "... done."

# print "There are " + str(len(remap)) + " changes to make."

# sizeleft = 0
# for key, value in remap.items():
#     sizeleft += os.path.getsize(key)

# print sizeleft / 1000000000.0

# newlog = os.path.join(target_dir, 'manualupdate.log')

# with open(newlog, 'w') as log:
#     for source, target in remap.items():
#         if not os.path.isfile(target):
#             print target
#             if not os.path.exists(os.path.dirname(target)):
#                 os.makedirs(os.path.dirname(target))
#             with open(source, 'rb') as fin:
#                 with open(target, 'wb') as fout:
#                     shutil.copyfileobj(fin, fout, 512*1024)
#             sizeleft -= os.path.getsize(source)
#             log.write(source + ' => ' + target + '\n')
#             print sizeleft / 1000000000.0

# print 'done.'
    

# print
# print "Copying files"

# for key, value in remap.items():
#   print '{} => {}'.format(key,value)
#   shutil.copy2(key, value) # copy2 preserves modification time, which is useful for later confirmation or categorization.

# print "... done."


