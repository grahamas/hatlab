
% Load config.m
config

USE_band_name_list = {'beta'};
USE_band_cutoffs.beta = [12, 32];

% n = "number of"
n_data_dirs = length(dn_data_list);

% i = "index of" or "i of" (looping var)

results = cell(n_data_dirs, 1);


for i_data_dir = 2:n_data_dirs
    dn_data = dn_data_list{i_data_dir};
    dp_data = [dp_data_root, dn_data];

    
    array_recording = ArrayRecording(dp_data);
    array_recording.band_cutoffs = USE_band_cutoffs;
    
    epoch_fxn = @(beh_dx, window) [array_recording.beh(:,beh_dx) + window(1),...
                                   array_recording.beh(:,beh_dx) + window(2)];    
    epoch_windows = {};
    for i_epoch = 1:length(epoch_name_list)
        epoch_name = epoch_name_list{i_epoch};
        beh_dx = epoch_beh_dx_list{i_epoch};
        window = epoch_window_sec_list{i_epoch};
        epoch_windows.(epoch_name) = epoch_fxn(beh_dx, window);
    end
    
    array_recording.epoch_windows = epoch_windows;

    columns_by_band = {};
    for i_band = 1:length(USE_band_name_list)
        this_band_name = USE_band_name_list{i_band};
        these_columns = {};
        these_columns.firing_rate = [];
        these_columns.width = [];
        these_columns.ppc = [];
        these_columns.epoch = [];
        fprintf('Starting width\n')
        width_cell = array_recording.map_over_units(@(unit)...
            unit.waveform_width);        
        n_units = length(width_cell);
        for i_epoch = 1:length(epoch_name_list)
            this_epoch_name = epoch_name_list{i_epoch};

            % Calculate the per-epoch values
            % The return is in the form of a cell array, with one
            % entry for each unit. Firing rate has one number for 
            % each unit. PPC has one array for each unit.
            fprintf('Starting firing rate\n')
            firing_rate_cell = array_recording.map_over_units(@(unit)...
                unit.compute_epoch_firing_rate(epoch_name));
            fprintf('Starting ppc\n')
            ppc_cell = array_recording.map_over_units(@(unit)...
                unit.compute_band_epoch_ppcs(this_band_name, this_epoch_name));

            % expand replicates the first input to be the size of the second.
            % This is naive, but works in this case because all of my use
            % cases have small as a singleton.
            expand = @(small,large) repmat(small, size(large));
            % expand_all takes a cell matrix (in practice, two cells, but the 
            % second is always ppc_cell) and makes every element of the cell
            % be the same size as the corresponding element in ppc_cell.
            expand_all = @(small_cell) arrayfun(@(ii) expand(small_cell{ii},...
                ppc_cell{ii}), 1:n_units, 'UniformOutput', 0);

            % Intermediate step necessary because you can't index a function result...    
            this_firing_rate_cell = expand_all(firing_rate_cell);
            this_width_cell = expand_all(width_cell);

            % Concatenate all the resized elements into columns that are
            % by design the same length.
            firing_rate_column = vertcat(this_firing_rate_cell{:});
            width_column = vertcat(this_width_cell{:});
            ppc_column = vertcat(ppc_cell{:});
            epoch_column = expand({this_epoch_name}, ppc_column);

            % Concatenate the created columns onto the end of these_columns
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
