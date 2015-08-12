% analysis phase shift

band_names={'delta','theta','alpha','beta', 'low_beta', 'low_mid_beta', 'mid_beta', 'high_beta','gamma'};
band_numbers = struct();
for ii = 1:length(band_names)
    band_numbers.(band_names{ii}) = ii;
end

BANDS = band_names;
NUM_CLUSTERS = 6;

layers = [2, 4, 30, 17, 34, 36, 62, 49;...
          13, 3, 29, 31, 45, 35, 61, 63;...
          6, 8, 27, 32, 38, 40, 59, 64;...
          1, 7, 28, 26, 33, 39, 60, 58;...
          14, 12, 19, 25, 46, 44, 51, 57;...
          5, 15, 24, 18, 37, 47, 56, 50;...
          10, 16, 23, 21, 42, 48, 55, 53;...
          9, 11, 20, 22, 41, 43, 52, 54];
      
phase_shift_mat = cellfun(@(band_name) phase_shifts_by_band(band_name));

'clustering by all bands'
clusters_all = cluster_phase_shifts(phase_shifts_by_band, BANDS, NUM_CLUSTERS);
'... done.'

'clustering by beta bands'
BETA_BANDS = {'low_beta', 'low_mid_beta', 'mid_beta', 'high_beta'};
clusters_beta = cluster_phase_shifts(phase_shifts_by_band, BETA_BANDS, NUM_CLUSTERS);
'... done'

cluster_grid_all = clusters_all(layers)
cluster_grid_beta = clusters_beta(layers)