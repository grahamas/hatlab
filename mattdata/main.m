
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

    columns_by_band = {};
    for i_band = 1:length(USE_band_name_list)
        this_band_name = USE_band_name_list{i_band};
        n_units = length(width_cell);
        array_recording.for_all_channels(@add_unit_numbers);
    end
    save(fp_array_recording, 'array_recording', '-v7.3')
        
end
