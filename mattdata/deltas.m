
% Load config.m
config

USE_band_name_list = {'max_beta'};
MAX_beta_cutoffs = {[13.5,19.5],[12, 18]};

% n = "number of"
n_data_dirs = length(dn_data_list);

% i = "index of" or "i of" (looping var)

results = cell(n_data_dirs, 1);


for i_data_dir = n_data_dirs:n_data_dirs
    dn_data = dn_data_list{i_data_dir};
    dp_data = [dp_data_root, dn_data];
    
    fp_analysis_columns = [dp_data, fn_analysis_columns];
    fp_array_recording = [dp_data, fn_array_recording];

    load(fp_array_recording)
    
    array_recording.band_cutoffs.max_beta = MAX_beta_cutoffs{i_data_dir};

    by_epoch = {};

    for i_epoch = 1:length(epoch_name_list)
        epoch_name = epoch_name_list{i_epoch};
        by_epoch.(epoch_name) = array_recording.map_over_channels(@(ch) direction_phase_unit_pairs(ch,'max_beta', epoch_name));
    end
    save([dp_data, 'delta_direction_phase_pairs.mat'], 'by_epoch', '-v7.3');

    
    %%
    %save(fp_array_recording, 'array_recording', '-v7.3')
        
end
