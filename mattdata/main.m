
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
    
    epoch_fxn = @(beh_dx, window) [beh(:,beh_dx) + window(1),...
                                   beh(:,beh_dx) + window(2)];
    
    epoch_windows = {};
    for i_epoch = 1:length(epoch_name_list)
        epoch_name = epoch_name_list(i_epoch);
        beh_dx = epoch_beh_dx_list(i_epoch);
        window = epoch_window_sec_list(i_epoch);
        epoch_windows.(epoch_name) = epoch_fxn(beh_dx, window);
    end
    
    array_recording = ArrayRecording(dp_data);
    array_recording.band_cutoffs = USE_band_cutoffs;
    array_recording.epoch_windows = epoch_windows;
    columns_by_band = {};
    for i_band = 1:length(USE_band_name_list)
        this_band_name = USE_band_name_list{i_band};
        these_columns = {};
        fprintf('Starting width\n')
        width_cell = array_recording.map_over_units(@(unit)...
            unit.width);        
        n_units = length(width_cell);
        for i_epoch = 1:length(epoch_name_list)
            this_epoch_name = epoch_name_list{i_epoch};
            fprintf('Starting firing rate\n')
            firing_rate_cell = array_recording.map_over_units(@(unit)...
                unit.get_epoch_firing_rate(epoch_name));
            fprintf('Starting ppc\n')
            ppc_cell = array_recording.map_over_units(@(unit)...
                unit.get_band_epoch_ppcs(this_band_name, this_epoch_name));
            expand = @(small,large) repmat(small, size(large));
            expand_all = @(small_cell) cellfun(@(ii) expand(small_cell{ii},...
                ppc_cell{ii}), 1:n_units, 'UniformOutput', 0);
            firing_rate_column = cell2mat(vertcat(expand_all(firing_rate_cell){:}));
            width_column = cell2mat(vertcat(expand_all(width_cell){:}));
            ppc_column = cell2mat(vertcat(ppc_cell));
            epoch_column = expand({this_epoch_name}, ppc_column);
            these_columns.firing_rate = vertcat(these_columns.firing_rate, firing_rate_column);
            these_columns.width = vertcat(these_columns.width, width_column);
            these_columns.ppc = vertcat(these_columns.ppc, ppc_column);
            these_columns.epoch = vertcat(these_columns.epoch, epoch_column);
        end
        columns_by_band.(this_band_name) = these_columns;
    end
    fp_analysis_columns = [dp_data, fn_analysis_columns];
    fp_array_recording = [dp_data, fn_array_recording];
    save(fp_analysis_columns, 'columns_by_band', '-v7.3')
    save(fp_array_recording, 'array_recording', '-v7.3')
        
end
