# Phase Analysis of Center-Out Task
###### Author: Graham Smith
###### Email: grahamas@gmail.com
###### Github: [grahamas/hatlab]

## How to Use 

The program is designed to be run on a slurm cluster (e.g. [midway]) so (locally) there are batch files that call Matlab scripts to accomplish specific tasks. These are not on the development server since they varied by run (depending on cluster availability) but I highly recommend running the program on a cluster if you are using any intensive functions (e.g. calculation of ppc).

The file `config.m` is a script containing most of the variables that are likely to change. The only variables that SHOULD change are `dp_data_root` and `dn_data_list`, both of which will change depending on the local file system. **NB**: make sure that directory names and paths always terminate with the file separator. 

## Data Structure

The heart of the program is the class division: `ArrayRecording`, `ChannelRecording`, and `UnitRecording`. These are nested classes (meaning, ArrayRecording contains ChannelRecordings contain UnitRecordings). The principal means of interaction with the data structure is through functionals defined in ArrayRecording which allow the mapping of functions over channels or units. These functionals are *not parallelized* which is a major oversight that should be addressed before any attempts to extend the analysis to a larger dataset. See below for thoughts.

## Parallelism

This is a bit of a sore spot. The current class hierarchy prohibits parallelization. In principle it should be simple to remedy. The changes are small, but there is an **IMPORTANT NOTE**: Don't attempt to parallelize at the unit-level. That way lies massive memory overheads (i.e. multiple copies of every LFP). Instead, parallelize at the channel-level. I mean, you can try, but think about it more than I have.

The problem is that each nested object contains a reference to its parent (e.g. the `ChannelRecording` class contains a field `parent_array`). This gives Matlab's automatic parallelization a massive headache. I suspect it loops infinitely, attempting to create the cache of shared variables to send to all processes. That is to say, it does its little checking pass on a given channel, finds the `parent_array` reference at some point, notices that the `parent_array` is shared across threads, and so attempts to copy it. In attempting to copy the parent, it attempts to copy the child channel, which of course again leads to the parent. 

The simple solution to this is to replace all references to the parent with a local copy of the desired field (I made sure only to share variables with the parent, nothing else). At that point, you should be able to make small modifications to the mapping function to allow parallelization. Again, only make those changes to the top-level `ArrayRecording.map_over_units` (and `map_over_channels` if you feel like it). Due to the overhead in starting a parallel pool, it might be a good idea to create two versions, one parallel, one single-threaded. First, change `for` to `parfor`. Then, if I currently have it appending to the cell array, set it up to insert at a given index instead. Finally, I'm sure there's at least one other problem I didn't notice. Have fun!



[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does it's job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [grahamas/hatlab]: <https://github.com/grahamas/hatlab>
   [midway]: <https://rcc.uchicago.edu/docs/using-midway/index.html>



