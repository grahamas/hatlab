%% ARBITRARY CONSTANTS
MAX_PASS = 55;
REFERENCE_DX = 1;

%addpath(genpath('/home/grahams/chronux'))

%% CONFIGURATION
day_dir = '/home/grahams/jaco_injections/';

% A flimsy attempt at generalization. Should be extracted and loaded.
date_list = {'20140505', '20140514'};
file_name_list = {'20140505/J05052014001',...
    '20140514/J20140514_M1Contra'};
good_chs_list = {[3:32, 35:64],...
    [9:31, 39:63]};

lfp_ext = '_LFP.mat';
phase_shifts_ext = '_phase_shifts.mat';

physical_mapping = [2, 4, 30, 17, 34, 36, 62, 49;...
          13, 3, 29, 31, 45, 35, 61, 63;...
          6, 8, 27, 32, 38, 40, 59, 64;...
          1, 7, 28, 26, 33, 39, 60, 58;...
          14, 12, 19, 25, 46, 44, 51, 57;...
          5, 15, 24, 18, 37, 47, 56, 50;...
          10, 16, 23, 21, 42, 48, 55, 53;...
          9, 11, 20, 22, 41, 43, 52, 54];
vertical_planes = {[1:8, 1:4], [1:8, 5:8]};
% so raw_data(physical_mapping(vertical_planes{1})) would get 
% the data from the first horizontal layer.

band_names={'delta','theta','alpha','beta', 'low_beta', 'low_mid_beta', 'mid_beta', 'high_beta','gamma'};
num_bands = length(band_names);
band_numbers = struct();
for ii = 1:num_bands
    band_numbers.(band_names{ii}) = ii;
end

bands.delta = [1,4];
bands.theta = [4,8];
bands.alpha = [8,12];
bands.beta = [12,32];
bands.low_beta = [12,17];
bands.low_mid_beta = [17,22];
bands.mid_beta = [22,27];
bands.high_beta = [27,32];
bands.gamma = [32,maxpass];

lfp_fs = 2000;

%%%%%%%%

calc_phase_shift = @(angles1, angles2, shifts)...
    arrayfun(@(shift) sum(abs(angles1(1:end-shift) - angles2(shift+1:end))), shifts);
parpool('local', 16)
for ii = 1:length(date_list)
    name = file_name_list{ii};
    good_chs = good_chs_list{ii};
    reference = good_chs(REFERENCE_DX);
    
    base_name = [day_dir,name];
    lfp_name = [base_name, lfp_ext];
    load(lfp_name);
    num_lfps = length(lfpdeci);
    
    phase_shifts_by_band = {};

    for band_num = 1:num_bands
        band_name = band_names{band_num};
        band_cutoffs = bands.(band_name);
        lfp_angles = cell(1,num_lfps);
        parfor lfp_num = good_chs
            lfp = lfpdeci{lfp_num};
            filtered_lfp = bandpass_filt(lfp, band_cutoffs);
            lfp_angles{lfp_num} = angle(hilbert(filtered_lfp));
        end
        period_sec = 1/max(band_cutoffs);
        period_bin_num = period_sec * params.Fs;
        possible_bin_shifts = 1:period_bin_num;
        phase_shifts = nans(num_lfps,1); % num_lfps);
        lfp_angles_ref = lfp_angles{reference};
        parfor jj = good_chs
            [max_angle, max_angle_dx] = ...
                max(calc_phase_shift(lfp_angles_ref, lfp_angles{jj}, possible_bin_shifts));
            phase_shifts(jj) = possible_bin_shifts(max_angle_dx);
        end
        phase_shifts_by_band.(band_name) = phase_shifts;
    end
    save([base_name,phase_shifts_ext], 'phase_shifts_by_band', '-v7.3');
end
                
        

