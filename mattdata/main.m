
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
    
    resultants = array_recording.map_over_units(@(unit) plot_phase_distributions(unit, dp_data, 'beta', epoch_name_list));
    resultants = vertcat(resultants{:});
    save([dp_data, 'resultants.mat'], 'resultants', '-v7.3');
    %%
    figure
    n_epochs = length(epoch_name_list);
    subplot(1, n_epochs, 1);
    for i_epoch = 1:n_epochs
        subplot(1, n_epochs, i_epoch)
        [t, r] = rose(angle(resultants(:,i_epoch)));
        polar(t, r/trapz(t,r))
        title(epoch_name_list(i_epoch))
    end
        

    
    %%
    save(fp_array_recording, 'array_recording', '-v7.3')
        
end
