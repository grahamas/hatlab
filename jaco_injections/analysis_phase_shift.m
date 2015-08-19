%% ARBITRARY CONSTANTS
MAX_PASS = 55;
REFERENCE_DX = 1;
NUM_CHS = 64;


%% CONFIGURATION
day_dir = '/home/grahams/jaco_injections/';

% A flimsy attempt at generalization. Should be extracted and loaded.
date_list = {'20140505'};%, '20140514'};
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
bands.gamma = [32,MAX_PASS];

lfp_fs = 2000;

all_channels_ones = ones(NUM_CHS,1);

for day_num = 1:length(date_list)
    name = file_name_list{day_num};
    good_chs = good_chs_list{day_num};
    good_chs_ones = zeros(NUM_CHS, 1);
    good_chs_ones(good_chs) = all_channels_ones(good_chs);
    physical_good_chs_ones = logical(good_chs_ones(physical_mapping));
    
    reference = good_chs(REFERENCE_DX);
    
    base_name = [day_dir,name];
    phase_shifts_name = [base_name, phase_shifts_ext];
    %load(phase_shifts_name);
    
    phase_shift_mat = cell2mat(cellfun(@(band_name) phase_shifts_by_band.(band_name),...
        band_names, 'UniformOutput', false));
    NUM_COLS = size(phase_shifts_by_band.(band_names{1}), 2);

    for ii = 1:num_bands
        % Renormalize [0, 2pi] -> [-pi, pi] -> [0, pi]
        band_name = band_names{ii};
        band_start = ((ii - 1) * NUM_COLS) + 1;
        band_stop = band_start + NUM_COLS - 1;
        period_sec = 1 / max(bands.(band_name));
        period_bin_num = period_sec * lfp_fs;
        half_max_bin = period_bin_num / 2;
        phase_shift_mat(:, band_start:band_stop) = ...
            abs(phase_shift_mat(:,band_start:band_stop) - half_max_bin) / half_max_bin;
        normed_phase_shift_by_band.(band_name) = phase_shift_mat(:, band_start:band_stop);
    end
    
    phase_shift_beta = normed_phase_shift_by_band.(band_name);
    num_windows = size(phase_shift_beta,2);

    figure
    hold on
    subplot(1, num_windows, 1)
    width = size(physical_mapping, 2);
    height = size(physical_mapping, 1);
    [X, Y] = meshgrid(1:width,1:height);
    Y = flipud(Y);
    X = X(:);
    Y = Y(:);
    for window_num = 1:num_windows
        this_phase_shift_beta = phase_shift_beta(:,window_num);
        this_physical = this_phase_shift_beta(physical_mapping);
        
        this_good_chs_physical = this_physical(physical_good_chs_ones);
        good_X = X(physical_good_chs_ones);
        good_Y = Y(physical_good_chs_ones);
        subplot(1, num_windows, window_num)
        hold on
        scatter(X,Y, 300, 'k', 'filled')
        scatter(good_X(:), good_Y(:), 300, this_good_chs_physical, 'filled')
        colorbar('southoutside')
        xlim([0, 9]); ylim([0, 9]); caxis([0, 0.5])
        hold off
        hist(this_good_chs_physical)
    end


%     'clustering by all bands'
%     clusters_all = kmeans(good_phase_shift_mat, NUM_CLUSTERS);
%     '... done.'
% 
%     'clustering by beta bands'
%     BETA_BANDS = [5,6,7,8];
%     clusters_beta = kmeans(good_phase_shift_mat(:, BETA_BANDS), NUM_CLUSTERS);
%     '... done'
% 
%     cluster_grid_all = clusters_all(layers)
%     cluster_grid_beta = clusters_beta(layers)
end
