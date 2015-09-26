# Phase Analysis of Center-Out Task
###### Author: Graham Smith
###### Email: grahamas@gmail.com
###### Github: [grahamas/hatlab]

## How to Use 

The program is designed to be run on a slurm cluster (e.g. [midway]) so (locally) there are batch files that call Matlab scripts to accomplish specific tasks. These are not on the development server since they varied by run (depending on cluster availability) but I highly recommend running the program on a cluster if you are using any intensive functions (e.g. calculation of ppc).

The file `config.m` is a script containing most of the variables that are likely to change. The only variables that SHOULD change are `dp_data_root` and `dn_data_list`, both of which will change depending on the local file system. **NB**: make sure that directory names and paths always terminate with the file separator. 

An example of how to load an `ArrayRecording` from scratch can be found in the "outdated" folder (which is not necessarily outdated...). Some analyses have also been confined to the "outdated" folder due to lack of integration or being one-off scripts. 

## How to Incorporate New Data (Even New Formats!)

When adding more data (i.e. a new recording session), the path to the folder containing the data is added to `config.m` as described above and in the file comments. Within the folder, you must place a script with the name stated at the top of `@ArrayRecording/ArrayRecording`. This script must define two variables: `fn_to_load_list` and `data_file_type`. The former is a list of `.mat` files relative to the data directory that are to be loaded. The latter is a string describing the data format. If the program can already handle that data format, then you are done, if not then you must write the parsing function.

The string describing the data format must correspond to a parsing function in `@ArrayRecording`. In particular if the string is 'format' then the parsing function name must be `LOAD_format`. The parsing function takes the object, the data path, and the list of file names to load. The parsing function sets the base variables of the object. In particular: beh, LFP_fs, channel_num2physical_map. Additionally, the parser populates the channels and units of the array (omitting empty channels) such that each channel has defined its LFP and channel_num (which are provided through the `ChannelRecording` constructor. Note that the LFP must be a double), and each unit has defined the spike times (through the constructor) and the waveform_width and the unit_number.

See below for additional information about the necessary directory structure. 


## Structure

The heart of the program is the class division: `ArrayRecording`, `ChannelRecording`, and `UnitRecording`. These are nested classes (meaning, ArrayRecording contains ChannelRecordings contain UnitRecordings). The principal means of interaction with the data structure is through functionals defined in ArrayRecording which allow the mapping of functions over channels or units. These functionals are *not parallelized* which is a major oversight that should be addressed before any attempts to extend the analysis to a larger dataset. See below for thoughts.

The other structural aspect is in the file system. Though it is not hard-coded anywhere, my preference has been to have two parallel structures. One for files/software, and one for data. I do this in part because I use Github (it's not generally a good idea to upload gigabytes of data to Github...) but I find it generally reduces clutter. The only change necessary for this division is in the choice of `dp_data_root`.

More important: Each data directory (meaning, each directory named in `dn_data_list`) must have a data loading file with a particular name. This name is given in `@ArrayRecording/ArrayRecording`. When you provide the `ArrayRecording` constructor with the data directory path, it attempts to run the script which in turn calls a static class function to parse the data structure appropriately.

## Parallelism

This is a bit of a sore spot. The current class hierarchy prohibits parallelization. In principle it should be simple to remedy. The changes are small, but there is an **IMPORTANT NOTE**: Don't attempt to parallelize at the unit-level. That way lies massive memory overheads (i.e. multiple copies of every LFP). Instead, parallelize at the channel-level. I mean, you can try, but think about it more than I have.

The problem is that each nested object contains a reference to its parent (e.g. the `ChannelRecording` class contains a field `parent_array`). This gives Matlab's automatic parallelization a massive headache. I suspect it loops infinitely, attempting to create the cache of shared variables to send to all processes. That is to say, it does its little checking pass on a given channel, finds the `parent_array` reference at some point, notices that the `parent_array` is shared across threads, and so attempts to copy it. In attempting to copy the parent, it attempts to copy the child channel, which of course again leads to the parent. 

The simple solution to this is to replace all references to the parent with a local copy of the desired field (I made sure only to share variables with the parent, nothing else). At that point, you should be able to make small modifications to the mapping function to allow parallelization. Again, only make those changes to the top-level `ArrayRecording.map_over_units` (and `map_over_channels` if you feel like it). Due to the overhead in starting a parallel pool, it might be a good idea to create two versions, one parallel, one single-threaded. First, change `for` to `parfor`. Then, if I currently have it appending to the cell array, set it up to insert at a given index instead. Finally, I'm sure there's at least one other problem I didn't notice. Have fun!



[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does it's job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [grahamas/hatlab]: <https://github.com/grahamas/hatlab>
   [midway]: <https://rcc.uchicago.edu/docs/using-midway/index.html>



