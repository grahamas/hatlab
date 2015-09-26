% dp = directory path 
% dn = directory name
% fn = file name

% The FULL PATH to the data directory containing monkey or session directories.
% WARNING: Directory paths should always terminate with the file separator.
dp_data_root = '/home/grahams/git_data/hatlab/mattdata/';

% A list of data directories RELATIVE to the dp_data_root.
% WARNING: Directory names should always terminate with the file separator.
% Note: Each of these directories must contain a data loading script.
% Note: (cont'd) You can find this name in @ArrayRecording/ArrayRecording.
dn_data_list = {'Rockstar/rs1050225/','Raju/040114/'};

% This list corresponds to dn_data_list, giving the cutoff bin numbers for narrow
% vs. broad waveform widths for each data set. This corresponds to the nev waveforms 
% that have bin sizes of ~33ms, and trough-peak waveform width metric.
narrow_cutoff_list = [10, 13];

% There shouldn't be a need to change these variables.
% DO NOT change these variables mid-analysis. These filenames are used both for 
% saving and for loading.
fn_analysis_columns = 'analysis_columns.mat';
fn_array_recording = 'array_recording.mat';

% Honestly I have no idea what this is doing.
raw_data_loading_functions = {};
raw_data_loading_functions.rj_P_clean_LFP = @load_p_data;
raw_data_loading_functions.rs_clean_SNR_LFP = @load_rs_data;

% Define the epochs of interest. 
epoch_name_list = {'instruction_early', 'instruction_late', 'execution'};
% Each trial has a row in the beh matrix, and each row has 8 columns outlined
% in the beh.pdf which should be floating around somewhere. (written by John O'Leary)
% For redundancy:
% 1. Start
% 2. Choice of peripheral target location (no, I have no idea why you would want this)
% 3. Onset of instruction signal
% 4. Onset of go cue
% 5. Start of movement
% 6. End of movement
% 7. Onset of reward
% 8. Direction d, with theta = (d - 1) * 45
epoch_beh_dx_list = {3, 3, 5};
% The index above is the zero of the below windows.
epoch_window_sec_list = {[-1, -.5], [-.5, 0], [0, .5]};

% Bands of interest. Typically I rename one of these on a script-by-script basis
% as some thing silly like USE_band_name_list.
standard_band_name_list = {'delta', 'theta', 'alpha', 'beta', 'gamma'};
beta_quarter_band_name_list = {'q1_beta', 'q2_beta', 'q3_beta', 'q4_beta'};

band_cutoffs.delta = [1 4];
band_cutoffs.theta = [4 8];
band_cutoffs.alpha = [8 12];
band_cutoffs.beta = [12 32];
band_cutoffs.gamma = [32 55];

band_cutoffs.q1_beta = [12 17];
band_cutoffs.q2_beta = [17 22];
band_cutoffs.q3_beta = [22 27];
band_cutoffs.q4_beta = [27 32];
