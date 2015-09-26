%ASSUMES ARRAY_RECORDING EXISTS

% A typical top-level script.
% However, this assumes that the raw data has already been processed and
% saved as an array_recording.

% The purpose of this is to get the psd and save it.

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
    
    fp_analysis_columns = [dp_data, fn_analysis_columns];
    fp_array_recording = [dp_data, fn_array_recording];

    load(fp_array_recording)
    
    length(array_recording.channel_list)
    [psd, f] = grand_mean_psd(array_recording);
    save([dp_data, 'psd.mat'], 'psd', 'f', '-v7.3');

    
    %%
    %save(fp_array_recording, 'array_recording', '-v7.3')
        
end
