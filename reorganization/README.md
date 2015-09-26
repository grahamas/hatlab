# Reorganization of Files with Particular Names by Date, Robust to Duplicates
###### Author: Graham Smith
###### Email: grahamas@gmail.com
###### Github: [grahamas/hatlab]

I'm really bad at organizing these things, so please read through the whole document before running, especially if you want to verify the integrity of the transfer.

## Caveats

First, know that I had to make a few last minute changes that I couldn't really test. So there are almost certainly bugs (of the crashy sort, not the clobber files sort). Please feel free to email me when you find them. It's because I changed the flags.

This is, relatively speaking, a terrible piece of software. However, it functions well within current limitations. In particular, this program has been adapted to deal with the horrific connection with biocloud.uchicago.edu. Should that change, the completely absurd block size specified within safe_file_ops.py should be changed. It is the default blocksize specified for the function `hashfile`. I arrived at the specified number through empirical tests, against all reason. It appears that samba interface does really wierd things.  

The following guide assumes a Unix environment. I'm sure it's fairly easy to adapt to Windows, but I don't know exactly how.

## How to Use 

Before we run anything, first look inside `reorg.py` and ensure that all configuration variables are correct. The only two that should be of concern are `DATE_RE_STRS` and `MIN_DATE`. Add to the former if you are introducing any new naming conventions. Change the latter if you are introducing any datafiles produced prior to January 1, 2012. 

Note: The variable `ONLY_THESE_EXTS' should have been replaced by a commandline option, but I haven't run enough tests to be sure. Same with the `DEPTH` 

You can also change `WINDOWS_ROOT` and `UNIX_ROOT` in `safe_file_ops.py`, but they should be unnecessary. 
Note that you can type:

```./reorg.py -h```

This shows all the options for the program. I have attempted to remove non-essential options, but some remain. On the first run, the invocation should be roughly

```./reorg.py --source_dirs SOURCE_DIR1 SOURCE_DIR2 --target_dir SEND_FILES_HERE --monkey MonkeyName --root Z:```

Both `source_dirs` and `target_dir` have to be full paths. The option `root` specifies the mount point of the shared drive (I assume use of a shared drive, but honestly you can use whatever mount point you feel like). 

The previous command did not actually move any files (I hope!). This should have produced a records file in the target directory. Briefly review this file to ensure that nothing bad is going to happen, and that the mapping seems appropriate. 

To actually move files, add the flag `--full_run` to the previous command, and run again. Please note that the average file transfer speed using the shared drive is perhaps 4 MB/s. So set up the move on a computer that will be on overnight, and be prepared to wait. I would highly recommend also using the `--check_integrity` flag as this file transfer method has a *remarkably* high failure rate.

## Integrity Checking

Integrity checking hasn't quite been fully exposed to the command line interface. Everything is there, but at the moment it requires manual editing of a variable. It should be easy to fix. I just added in the --check_integrity flag, but adding in the necessary mechanics to switch between metrics was a bit beyond me. All that needs to happen is the switch inside the function `check_integrity`.

There are two built-in metrics: `size_metric` and `hash_metric`. The `size_metric` simply ensures that the copied files are the same size as the original files. I haven't yet seen a case where this wasn't sufficient, but I'm not optimistic. The `hash_metric` does a SHA-256 hash of both files and compares. 

I consider the `size_metric` integrity check to be **necessary**. If you're copying more than a few dozen gigabytes of files, there is sure to be a corruption, and the size check is likely to catch it with little overhead. The `hash_metric` is probably a good idea if you have the time, but it essentially recopies the files, so in fact takes more than twice as long as the copy itself.


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does it's job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [grahamas/hatlab]: <https://github.com/grahamas/hatlab>
   [midway]: <https://rcc.uchicago.edu/docs/using-midway/index.html>



