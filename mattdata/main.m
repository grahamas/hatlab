
% Load config.m
config

USE_band_name_list = {'beta'};
USE_band_cutoffs.beta = [12, 32];

% n = "number of"
n_data_dirs = length(dn_data_list);

% i = "index of" or "i of" (looping var)

results = cell(n_data_dirs, 1);

for i_data_dir = 1:n_data_dirs
    dn_data = dn_data_list{i_data_dir};
    dp_data = [dp_data_root, dn_data];
    
    array_recording = ArrayRecording(dp_data);
    for i_band = 1:length(USE_band_name_list)
        this_band_name = USE_band_name_list{i_band};
        these_band_cutoffs = USE_band_cutoffs.(this_band_name);
        array_recording.parfor_all_channels(@(ch)...
            ch.compute_LFP_band(this_band_name, these_band_cutoffs));
    end
    
        
end
