

import shutil
import hashlib

DEFAULT_BACKUP = '.backup_records'

# I would not call these functions "tested"

#########################
###### Functions ########

# Credit Omnifarious on stack overflow
def hashfile(afile, hasher=hashlib.sha256(), blocksize=65536):
    """
        Hashes afile using hasher, reading in blocksize.
        Default blocksize is an experimentally determined optimal value
        that is ONLY likely to be optimal for hashes from the HatLab
        network drive (which has a TERRIBLE connection).
        YMMV
    """
    buf = afile.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = afile.read(blocksize)
    return hasher.hexdigest()

def hashdict(copydict):
    """
        Returns invalids, sha2src.

        Specifically, hashdict takes a copydict. A copydict is a dictionary
        which maps source files to destination files (already copied). This 
        function hashes all source and destination files. 

        It stores each source hash in the dictionary sha2src as a key to a 
        list containing the file paths of all files with that sha-hash.

        If the source hash does not equal the destination hash, then it adds
        the source file path as a key pointing to the destination file path
        in the invalids dict.
    """
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
            #print fsrc # ??????
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

def get_highest_version_number(full_path):
    """
        Gets the highest version number of files named as full_path
        in the very particular (and stupid) numbering scheme I am using.
    """
    highest_num_suffix = -1
    path, filename = os.path.split(full_path)
    basename, ext = os.path.splitext(filename)
    baselength = len(basename)
    for this_filename in target_dir.listdir():
        this_basename, this_ext = os.path.splitext(this_filename)
        if this_ext == ext and this_basename[:baselength] == basename:
            this_num_suffix = this_basename[baselength:]
            highest_num_suffix = max(highest_number, f_num_suffix)
    highest_fname = os.path.join(path, basename, str(highest_num_suffix), ext)

def gen_next_numeric_filename(full_path):
    """
        Finds filename similar to full_path with lowest possible numeric suffix.
        E.g: /home/myname/iamapumpkin.rng -> /home/myname/iamapumpkin0.rng 
            (if there is no such existing file)
        Subsequently:
            /home/myname/iamapumpkin.rng -> /home/myname/iamapumpkin1.rng
        NOTE THAT THIS IS BADLY BEHAVED FOR NUMERIC FILENAMES
        Throws error in case of mischievious filename
    """
    highest_num_suffix = get_highest_version_number(full_path)
    return_val = os.path.join(target_dir, basename + str(highest_num_suffix+1) + ext)
    if os.isfile(return_val):
        raise ValueError("YOU CHEATED: " + full_path)
    return return_val

def create_local_backup(full_path, backup_dir=DEFAULT_BACKUP):
    """ 
        Move file indicated by full_path to the backup_dir, with num attached.
    """
    path, filename = os.path.split(full_path)
    backup_path = os.path.join(path, backup_dir)
    if not isdir(backup_path):
        os.mkdir(backup_path)
    full_backup_path = gen_next_numeric_filename(os.path.join(backup_path, filename))
    shutil.move(full_path, full_backup_path)


def open_no_clobber(full_path, mode, backup_dir=DEFAULT_BACKUP):
    """
        Open given file without clobbering.
        If opening to write (clobbering), move existing file to local backup.
    """
    if os.path.isfile(full_path) and 'w' in mode:
        create_local_backup(full_path, backup_dir)
    return open(full_path, mode)

def find_numeric_versions(full_path):
    directory, basename = os.path.split(full_path)
    filename, ext = os.path.splitext(basename)
    nonnumeric_base_len = len(filename)
    all_files = os.listdir(directory)
    possible_files = filter(lambda f: return f[:nonnumeric_base_len] == filename, all_files)
    possible_files = filter(lambda f: return os.path.splitext(f)[1] == ext, possible_files)
    correct_files = filter(lambda f: 
        return os.path.splitext(f)[0][nonnumeric_base_len:].isnumeric(), possible_files)
    complete_paths = map(lambda f: return os.path.join(directory, f), correct_files)
    return complete_paths


def get_all_versions(full_path, backup_dir=DEFAULT_BACKUP):
    """ 
        Like find numeric versions, but includes the non-numeric 'original'
        (which could be the most recent) and any copies in the local
        backup directory.
    """
    local_copies = find_numeric_versions(full_path)
    directory, basename = os.path.split(full_path)
    backup_path = os.path.join(directory, backup_dir, basename)
    backup_copies = find_numeric_versions(backup_path)
    if os.isfile(full_path):
        return [full_path] + local_copies + backup_copies
    else:
        return local_copies + backup_copies
