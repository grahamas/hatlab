%% ARBITRARY CONSTANTS
MAX_PASS = 55;
REFERENCE_DX = 1;

% Including below comment for reference. 
% Include actual command on a case-by-case basis.
%addpath(genpath('/home/grahams/chronux'))

%% CONFIGURATION
day_dir = '/home/grahams/jaco_injections/';

lfp_ext = '_LFP.mat';
spec_ext = '_spec.mat';

bpowfig_ext = '_bandpow.fig';
bpowpng_ext = '_bandpow.png';

npowfig_ext = '_nodeltapow.fig';
npowpng_ext = '_nodeltapow.png';

lpowfig_ext = '_logpow.fig';
lpowpng_ext = '_logpow.png';

betapowfig_ext = '_betapow.fig';
betapowpng_ext = '_betapow.png';

phase_shifts_ext = '_phase_shifts.mat';

% A flimsy attempt at generalization. Should be extracted and loaded.
date_list = {'20140505', '20140514'};
file_name_list = {'20140505/J05052014001',...
    '20140514/J20140514_M1Contra'};
good_chs_list = {[3:32, 35:64],...
    [9:31, 39:63]};

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
psd_band_names={'delta','theta','alpha','beta','gamma'};
band_numbers = struct();
for ii = 1:length(band_names)
    band_numbers.(band_names{ii}) = ii;
end

bands.delta = [1,4];
bands.theta = [4,8];
bands.alpha = [8,12];
bands.beta = [12,32];
bands.gamma = [32,MAX_PASS];

psd_bands = bands;

bands.low_beta = [12,17];
bands.low_mid_beta = [17,22];
bands.mid_beta = [22,27];
bands.high_beta = [27,32];

% IN MINUTES
windows_list = {{[2,8],[9,14],[14.5,17],[18,23]},...
    {[7,13.5], [14,19.5], [20,25.5], [26,35]}};

lfp_fs = 2000;

