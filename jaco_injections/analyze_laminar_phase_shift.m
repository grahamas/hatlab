% Load all configuration.
layers_config

%%%%%%%%
num_bands = length(bands);
num_windows = length(windows);
calc_phase_shift = @(angles1, angles2, shifts)...
    arrayfun(@(shift) sum(abs(angles1(1:end-shift) - angles2(shift+1:end))), shifts);
parpool('local', 16)
for ii = 1:length(date_list)
    fprintf('\n%d\n',ii)
    name = file_name_list{ii};
    good_chs = good_chs_list{ii};
    reference = good_chs(REFERENCE_DX);
    
    base_name = [day_dir,name];
    lfp_name = [base_name, lfp_ext];
    load(lfp_name);
    num_lfps = length(lfpdeci);
    num_lfp_bins = length(lfpdeci{1});
    lfp_time = (1/lfp_fs):(1/lfp_fs):(num_lfp_bins/lfp_fs);
    window_lfp_dx = cell(num_windows, 1);
    for window_num = 1:num_windows
        window = windows{window_num};
        start = window(1);
        stop = window(2);
        window_lfp_dx{window_num} = (start <= lfp_time) ...
            & (lfp_time < stop);
    end
    
    phase_shifts_by_band = {};

    for band_num = 1:num_bands
        band_name = band_names{band_num};
        fprintf('%s\n', band_name)
        band_cutoffs = bands.(band_name);
        band_lfp_angles = cell(1,num_lfps);
        band_lfp_amplitudes = cell(1,num_lfps);

        fprintf('hilbert\n')
        parfor lfp_num = 1:num_lfps
            if ~any(lfp_num == good_chs)
                continue
            end
            lfp = lfpdeci{lfp_num};
            filtered_lfp = bandpass_filt(lfp, band_cutoffs);
            lfp_hilbert = hilbert(filtered_lfp);
            band_lfp_angles{lfp_num} = angle(lfp_hilbert);
            band_lfp_amplitudes{lfp_num} = abs(lfp_hilbert);
        end
        period_sec = 1/max(band_cutoffs);
        period_bin_num = period_sec * lfp_fs;
        possible_bin_shifts = 1:period_bin_num;
        phase_shifts = nan(num_lfps,num_windows+1); % num_lfps);
        lfp_angles_ref = band_lfp_angles{reference};
        
        fprintf('phase shifts\n')
        parfor jj = 1:num_lfps
            if ~any(jj == good_chs)
                continue
            end
            these_phase_shifts = nan(1,num_windows+1)
            [max_angle, max_angle_dx] = ...
                max(calc_phase_shift(lfp_angles_ref, band_lfp_angles{jj}, possible_bin_shifts));
            these_phase_shifts(num_windows+1) = possible_bin_shifts(max_angle_dx);
            for kk = 1:num_windows
                window = windows{kk} * 60;
                [max_angle, max_angle_dx] = ...
                    max(calc_phase_shift(lfp_angles_ref(window_lfp_dx{kk}),...
                        band_lfp_angles{jj}(window_lfp_dx{kk}), possible_bin_shifts));
                these_phase_shifts(kk) = possible_bin_shifts(max_angle_dx);
            end
            phase_shifts(jj,:) = these_phase_shifts;
        end
        phase_shifts_by_band.(band_name) = phase_shifts;
        if strcmp(band_name, 'beta')
            beta_lfp_angles = band_lfp_angles;
            beta_lfp_amplitudes = band_lfp_amplitudes;
        end
    end
    message = 'Phase shifts stored by band then window, plus full span at num_windows + 1';
    'saving...'
    save([base_name,phase_shifts_ext], 'phase_shifts_by_band',...
        'beta_lfp_angles', 'beta_lfp_amplitudes', 'windows', 'message', '-v7.3');
end
                
        

