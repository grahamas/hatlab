
% Load config.m
config

USE_band_name_list = {'beta'};
USE_band_cutoffs.beta = [12, 32];

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
    
    length(array_recording.channel_list)
    resultants = array_recording.map_over_units(@(unit) plot_phase_distributions(unit, dp_data, 'beta', epoch_name_list));
    resultants = vertcat(resultants{:})
    save([dp_data, 'resultants.mat'], 'resultants', '-v7.3');

    
    %%
    %save(fp_array_recording, 'array_recording', '-v7.3')
        
end
