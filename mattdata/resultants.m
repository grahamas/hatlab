
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

    length(array_recording.channel_list)
    resultants = array_recording.map_over_units(@(unit) plot_phase_distributions(unit, dp_data, 'max_beta', epoch_name_list));
    resultants = vertcat(resultants{:})
    save([dp_data, 'resultants_max_beta.mat'], 'resultants', '-v7.3');

    
    %%
    %save(fp_array_recording, 'array_recording', '-v7.3')
        
end
