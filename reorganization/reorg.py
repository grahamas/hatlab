#!/usr/bin/env python

#### WOW THIS IS TERRIBLE
#### PLEASE NOTE
#### THIS ASSUMES THAT A UNIX FILESYSTEM
#### HAS THE SHARED DRIVE
#### ROOTED AT THE SECOND LEVEL
#### E.G. /media/nicholab
#### GOD HELP US ALL

#### THIS ASSUMPTION IS MADE IN fix_path

import re
import os
import sys
import time
import itertools
import myshutil
import json
import argparse
import datetime

import safe_file_ops as sop

###### Constants #######

RECORD_FNAME = 'record.json' #oldname
UNPDICT_FNAME = 'unpdict.json' #newname
UNKNOWN_PATH = 'UNKNOWN'

SOURCE_RECORD_FNAME = 'source_record.json'
ORGANIZED_RECORD_FNAME = 'organized_record.json'

DATE_RE_STRS = [r'[0-9]{8}', 
    r'[0-9]{6}', 
    r'\d{2}_\d{2}_\d{2}',
    r'\d{2}_\d{2}_\d{4}',
    r'\d{4}_\d{2}_\d{2}']

DATE_RES = map(re.compile, DATE_RE_STRS)

NON_NUMERIC_RE = re.compile(r'[^\d]+')

MIN_DATE = datetime.datetime.strptime('20120101','%Y%m%d').date()
MAX_DATE = datetime.datetime.now().date()

#########################
####### Functions #######
#########################

def organized_files_from_source_files(source_files, organized_files={}):
    for source_path, source in record.iteritems():
        if source.destination in organized_files.keys():
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
        new_path = new_path[3:] # BAAAAAAD
    elif ':' in new_path[0]:
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

def write_record(record_dict, target_dir, record_fname):
    output = {key: val.to_dict() for key,val in record_dict.iteritems()}
    record_path = os.path.join(target_dir, record_fname)
    with sop.open_no_clobber(record_path, 'w') as f:
        json.dump(output, f)

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

def from_existing_record(monkey_path, source_record_fname=SOURCE_RECORD_FNAME, organized_record_fname=ORGANIZED_RECORD_FNAME):

    return (get_record(target_monkey_dir, SourceFile, source_record_fname), 
            get_record(target_monkey_dir, OrganizedFile, organized_record_fname))

def get_record(monkey_path, class_name, record_fname):
    record_path = os.path.join(monkey_path, record_fname)
    def open_record(path):
            with open(path, 'r') as record_file:
                record = json.load(record_file)
                return {fix_path(key):class_name.from_dict(value) for (key,value) in record.iteritems()}
    record = open_record(record_path)
    return record

def from_new_record(source_monkey_dirs, target_monkey_dir, source_record_fname=SOURCE_RECORD_FNAME, organized_record_fname=ORGANIZED_RECORD_FNAME):
    source_files = get_record(target_monkey_dir, SourceFile, source_record_fname)
    if os.path.isfile(os.path.join(target_monkey_dir, organized_record_fname)):
        organized_files = get_record(target_monkey_dir, OrganizedFile, organized_record_fname)
    else:
        organized_files = organized_files_from_source_files(source_files)
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
    old_write_record_from_source_files(source_files, target_monkey_dir)
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

def copy_files(source_files, target_files, log=sys.stdout):
    size_left = 0
    for source_path,source in source_files.iteritems():
        if source.exists and not os.path.isfile(source.destination):
            size_left += os.path.getsize(source_path)
    log.write('Total movement: {} GB'.format(str(size_left / 1000000000.0)))
    for source_path, source in source_files.iteritems():
        if not source.exists:
            log.write("DOES NOT EXIST:\n\t{}".format(source_path))
            continue
        destination_path = source.destination
        file_size = os.path.getsize(source_path)
        if destination_path not in target_files:
            target_files[destination_path] = OrganizedFile(source_path, destination_path)
            destination = target_files[destination_path]
            if destination.exists:
                destination.origin = UNKNOWN_PATH
                continue
        else:
            destination = target_files[destination_path]
        if os.path.isfile(destination_path):
            destination.source_paths.append(source_path)
            continue
        else:
            if destination.origin != "":
                raise Exception("THIS SHOULD NEVER HAPPEN")
            else:
                destination.origin = source_path
            log.write("{} => {}\n".format(source_path, destination_path))
            log.write("Moving {} GB\n".format(str(file_size / 1000000000.0)))
            if not os.path.isdir(os.path.dirname(destination_path)):
                os.makedirs(os.path.dirname(destination_path))
            myshutil.copy2(source_path, destination_path)
            log.write("... done.\n")
            size_left -= file_size
            log.write("{} GB remaining.\n".format(str(size_left/1000000000.0)))

def double_check(file_obj, metric):
    # This function is useful because hashing is so unlikely to 
    # give the same incorrect result twice.
    previous_result = metric(file_obj)
    current_result = metric(file_obj, force=True)
    while previous_result is not next_result:
        previous_result = current_result
        current_result = metric(file_obj, force=True)
    return current_result

def verification_copy(source, target, metric, log=sys.stdout, only_exts=None):
    attempt_limit = 10
    source_path = source.path
    target_path = target.path
    for count in range(attempt_limit):
        log.write("Attempt {} of {} to write {}".format(str(count), str(attempt_limit), source_path))
        shutil.copy2(source, target)
        if metric(source) == metric(target):
            return True
    return False

def fix_inequal_sources(source_files, organized_files, inequal_sources, metric, log=sys.stdout, only_exts=None):
    to_be_fixed = [OrganizedFileBeingFixed(o_file) for o_file in 
                    [organized_files[path] for path in inequal_sources]
                    if o_file.origin is UNKNOWN_PATH]
    for f in to_be_fixed:
        num_partitions = f.partition_sources(source_files, metric)
        if num_partitions > 1:
            log.write("Different sources have same target!\n")
            log.write("Automatic resolution of this problem is not yet implemented.\n")
            log.write("Details follow:\n")
            log.write("\tDestination: {}".format(f.path))
            log.write("\tSources: {}".format(f.sources))
            log.write("\tEquivalence Classes: {}".format(f.eq_classes))
            raise ValueError("Different sources have same target! See log.")

def verify_organized_files(source_files, organized_files, metric, log=sys.stdout, only_exts=None):
    inequal_sources = []
    equal_sources = []
    for organized_path, organized_file in organized_files.iteritems():
        ext = os.path.splitext(organized_path)[1]
        if only_exts is not None and ext not in only_exts:
            continue
        if not organized_file.sources_equal(source_files, metric):
            inequal_sources.append(organized_path)
        else:
            equal_sources.append(organized_path)
    fix_inequal_sources(source_files, organized_files, inequal_sources, metric)
    for organized_path in equal_sources + inequal_sources:
        organized_file = organized_files[organized_path]
        if not organized_file.first_source_equal(source_files, metric):
            verification_copy(source_files[organized_files.source_paths[0]], organized_file, metric, log=log)

def verify_source_files(source_files, organized_files, metrc, log=sys.stdout, only_exts=None):
    #### NOT DONE #####
    to_copy = []
    for source_path, source in source_files.iteritems():
        target_path = source.destination
        if not checker(source_path, target_path, log):
            if only_exts is not None:
                if os.path.splitext(source_path)[1] in only_exts:
                    to_copy.append(source_path)
            else:
                to_copy.append(source_path)
    log.write("There are {} problems to fix.".format())
    
def check_integrity(source_files, organized_files, log=sys.stdout, only_exts=None):
    # FIRST VERIFY ORGANIZED_FILES SOURCES!!!!!!
    verify_organized_files(source_files, organized_files, log=sys.stdout, only_exts=None)

    def size_metric(f, force='Irrelevant'): 
        return os.path.getsize(f.path) if os.path.isfile(f.path) else 0
    def hash_metric(f, force=False):
        return f.hash(force=force)

    verify_organized_files(source_files, organized_files, size_metric, log=log, only_exts=only_exts)
    #check_hashes(source_files, organized_files)


#########################
######## Class ##########
#########################

class File(object):
    def __init__(self, path):
        self.exists = os.path.isfile(path)
        self.path = path
        self.sha = None
        self.hashedtime = 0
    def hash(self, force=False, log=sys.stdout):
        """
            Hashes this file, using the hash function in SOP.

            PRINTS OUT STATUS
        """
        if self.hashedtime < os.path.getmtime(self.path):
            force = True
        if self.sha and not force:
            return self.sha
        else:
            bname = os.path.basename(self.path)
            log.write("Hashing " + bname)
            start = timeit.default_timer()
            with open(self.path,'rb') as f:
                self.sha = sop.hashfile(f)
            elapsed = timeit.default_timer() - start
            log.write("Done. Time: " + str(elapsed) + " for " + bname)
            self.hashedtime = time.gmtime()
            return self.sha
    def __len__(self):
        return os.path.getsize(self.path)
    def to_dict(self):
        ret = {}
        ret['exists'] = self.exists
        ret['path'] = self.path
        ret['sha'] = self.sha
        ret['hashedtime'] = self.hashedtime
        return ret
    @classmethod
    def populate_from_dict(cls, obj, dct):
        obj.sha = dct['sha']
        obj.hashedtime = dct['hashedtime']
        return obj

class OrganizedFile(File):
    def __init__(self, source_path, path):
        super(OrganizedFile, self).__init__(path)
        self.source_paths = [source_path]
        self.origin = ""
    def sources_equal(self, all_sources, metric, force=False):
        if len(self.sources) == 1:
            return True
        source_objs = map(lambda source_path: all_sources[source_path],self.source_paths)
        return reduce(lambda a,b: metric(a) == metric(b), source_objs)
    def first_source_equal(self, all_sources, force=False):
        first_source = all_sources[self.source_paths[0]]
        return metric(first_source) == metric(self)
    def add_source(self, source):
        if source in self.source_paths:
            return False
        else:
            self.source_paths.append(source)
            return True
    def to_dict(self):
        ret = super(OrganizedFile, self).to_dict()
        ret['source_paths'] = self.source_paths
        ret['origin'] = self.origin
        return ret
    @classmethod
    def from_dict(cls, dct):
        new_self = cls(fix_path(dct['source_paths'][0]), fix_path(dct['path']))
        new_self = File.populate_from_dict(new_self, dct)
        new_self.source_paths = map(fix_path, dct['source_paths'])
        origin = dct['origin']
        if origin is not "" and origin is not UNKNOWN_PATH:
            origin = dct['origin']
        new_self.origin = origin
        return new_self

class SourceFile(File):
    def __init__(self, path, destination):
        super(SourceFile, self).__init__(path)
        self.copied = False
        self.destination = destination
    def to_dict(self):
        ret = super(SourceFile,self).to_dict()
        ret['copied'] = self.copied
        ret['destination'] = self.destination
        return ret
    @classmethod
    def from_dict(cls, dct):
        new_self = cls(fix_path(dct['path']), fix_path(dct['destination']))
        new_self = File.populate_from_dict(new_self, dct)
        new_self.copied = dct['copied']
        return new_self
    @classmethod
    def infer_destination(cls, path, target_path):
        """
            Infers the path of the destination given the source path.
            Returns a SourceFile object with the appropriate destination.
        """
        output_date_format = '%Y%m%d'
        root, basename = os.path.split(path)
        path_time = os.path.getmtime(path)
        match_to_re = lambda r: r.search(basename)
        matches = [x for x in map(match_to_re, DATE_RES) if x is not None]
        remove_non_numerics = lambda match: NON_NUMERIC_RE.sub('',match)
        std_date = None
        date_strs = map(lambda f: f.group(), matches)
        print datetime.datetime.fromtimestamp(path_time).strftime('%Y%m%d')
        print date_strs
        for date_str in date_strs:
            std_date = infer_date(remove_non_numerics(date_str), path_time)
            print std_date
            if std_date is not None: break
        if std_date is None:
            raise ValueError("File name has no date: {}\n".format(path))
            return None
        fst, snd = basename.split(date_str)
        std_date_str = std_date.strftime(output_date_format)
        pad = lambda num: num if len(num) == 2 else '0' + num
        destination = os.path.join(target_path, str(std_date.year), pad(str(std_date.month)), fst + std_date_str + snd)
        return cls(path, destination)

class OrganizedFileBeingFixed(OrganizedFile):
    def __init__(self, organized_file, metric):
        path = organized_file['path']
        source_paths = organized_file['source_paths']
        super(OrganizedFileBeingFixed, self).__init__(source_paths[0], path)
        self.original = organized_file
        self.source_paths = source_paths
        self.origin = organized_file['origin']
        self.eq_classes = {}
        self.my_class = UNKNOWN_PATH
        self.metric_value = double_check(self, metric)
    def partition_sources(self, source_files, metric, log=sys.stdout):
        #sources = map(lambda path: source_files[path], self.source_paths)
        #sources_in_metric = map(lambda f: double_check(f, metric), sources)
        for path in source_paths:
            source = source_files[path]
            source_metric = double_check(source, metric)
            found_eq_class = False
            for eq_path, eq_dict in self.eq_classes.iteritems():
                if eq_dict['eq_metric'] == source_metric:
                    eq_dict['eq_source_paths'].append(path)
                    found_eq_class = True
            if not found_eq_class:
                eq_dict = {}
                eq_dict['eq_metric'] = source_metric
                eq_dict['eq_sources'] = [path]
                self.eq_classes[path] = eq_dict
                if source_metric == self.metric_value:
                    self.my_class = path
        if len(self.eq_classes) == 1:
            if self.my_class is UNKNOWN_PATH:
                path = self.eq_classes.keys()[0]
                eq_class = self.eq_classes[path]
                verification_copy(source_files[path], self.original, metric, log)
        return len(self.eq_classes)

#########################
######### Setup #########
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
parser.add_argument('--fix_records', action='store_true', default=False)
parser.add_argument('--exclude_dirs', action='store', nargs='+',
    help='Exclude directories containing this string.')
args = parser.parse_args()

monkey_name = args.monkey
full_run = args.full_run
use_existing_record = args.use_existing_record
just_validate_records = args.just_validate_records
root = args.root
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
    source_files, organized_files = from_existing_record(target_monkey_dir)
else:
    source_files, organized_files = from_new_record(source_monkey_dirs, target_monkey_dir)

if full_run:
    write_record(source_files, target_monkey_dir, record_fname=SOURCE_RECORD_FNAME)
    copy_files(source_files, organized_files)
    write_record(organized_files, target_monkey_dir, record_fname=ORGANIZED_RECORD_FNAME)

if check_integrity:
    check_integrity(source_files, organized_files)
    write_record(source_files, target_monkey_dir, record_fname=SOURCE_RECORD_FNAME)
    write_record(organized_files, target_monkey_dir, record_fname=ORGANIZED_RECORD_FNAME)

#########################
####### OLD STUFF #######
#########################

# def old_parse_record(record, source_files={}, organized_files={}, log=sys.stdout):
#     source_files = old_add_record_to_source_files(record, source_files, log)
#     organized_files = old_add_record_to_organized_files(record, organized_files, log)
#     return source_files, organized_files

# def old_add_record_to_source_files(record, source_files, log=sys.stdout):
#     for source, destination in record.iteritems():
#         if source in source_files.keys():
#             log.write('Source moved twice: {}\n'.format(source))
#             if source_files[source].destination != destination:
#                 log.write('ERROR: Two destinations!\n')
#                 log.write('\t DESTINATION: {}\n'.format(source_files[source].destination))
#                 log.write('\t DESTINATION: {}\n'.format(destination))
#         else:
#             source_files[source] = SourceFile(source, destination)
#     return source_files

# def old_add_record_to_organized_files(record, organized_files, log=sys.stdout):
#     for source, destination in record.iteritems():
#         if destination in organized_files.keys():
#             log.write('Destination with multiple sources: {}\n'.format(destination))
#             if not organized_files[destination].add_source(source):
#                 log.write('Destination has same source:\n')
#                 log.write('\t DESTINATION: {}\n'.format(destination))
#                 log.write('\t SOURCE: {}\n'.format(source))
#         else:
#             organized_files[destination] = OrganizedFile(source, destination)
#     return organized_files

# def old_write_record_from_source_files(source_files, target_dir, record_fname=RECORD_FNAME):
#     new_record = {k:v.destination for k,v in source_files.iteritems()}
#     record_path = os.path.join(target_dir, record_fname)
#     with sop.open_no_clobber(record_path, 'w') as f:
#         json.dump(new_record, f)

# def old_get_record(monkey_path, record_fname=RECORD_FNAME):
#     record_path = os.path.join(monkey_path, record_fname)
#     def open_record(path):
#             with open(path, 'r') as record_file:
#                 record = json.load(record_file)
#                 return {fix_path(key):fix_path(value) for (key,value) in record.iteritems()}
#     if BAD_RECORDS:
#         all_record_paths = sop.get_all_versions(record_path)
#         all_records = map(open_record, all_record_paths)
#         return all_records
#     else:
#         record = open_record(record_path)
#         return record

# def old_from_old_record(monkey_path, record_fname=RECORD_FNAME):
#     # deprecated
#     return parse_record(get_record(monkey_path, record_fname))


################################
######## OLD OLD STUFF #########
################################

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


