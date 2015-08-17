%% ARBITRARY CONSTANTS
MAX_PASS = 55;
REFERENCE_DX = 1;

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

for day_num = 1:length(date_list)
    name = file_name_list{ii};
    good_chs = good_chs_list{ii};
    reference = good_chs(REFERENCE_DX);
    
    base_name = [day_dir,name];
    phase_shifts_name = [base_name, phase_shifts_ext];
    load(phase_shifts_name);
    
    phase_shift_mat = cell2mat(cellfun(@(band_name) phase_shifts_by_band.(band_name),...
        band_names, 'UniformOutput', false));
    NUM_COLS = size(phase_shifts_by_band.(band_names{1}), 2);

    for ii = 1:num_bands
        % Renormalize [0, 2pi] -> [-pi, pi] -> [0, pi]
        band_name = band_names{ii};
        band_start = ((ii - 1) * NUM_COLS) + 1;
        band_stop = band_start + NUM_COLS - 1;
        period_sec = 1 / max(bands.(band_name));
        period_bin_num = period_sec * params.Fs;
        half_max_bin = period_bin_num / 2;
        phase_shift_mat(:, band_start:band_stop) = ...
            abs(phase_shift_mat(:,band_start:band_stop) - half_max_bin) / half_max_bin;
    end


    'clustering by all bands'
    clusters_all = kmeans(good_phase_shift_mat, NUM_CLUSTERS);
    '... done.'

    'clustering by beta bands'
    BETA_BANDS = [4,5,6,7];
    clusters_beta = kmeans(good_phase_shift_mat(:, BETA_BANDS), NUM_CLUSTERS);
    '... done'

    cluster_grid_all = clusters_all(layers)
    cluster_grid_beta = clusters_beta(layers)
end
