% dp = directory path 
% dn = directory name
% fn = file name
dp_data_root = '/home/grahams/git_data/hatlab/mattdata/';

dn_data_list = {'Rockstar/rs1050225/','Raju/040114/'};
dn_load_data = 'raw_data_loader';

fn_analysis_columns = 'analysis_columns.mat';
fn_array_recording = 'array_recording.mat';

raw_data_loading_functions = {};
raw_data_loading_functions.rj_P_clean_LFP = @load_p_data;
raw_data_loading_functions.rs_clean_SNR_LFP = @load_rs_data;

epoch_name_list = {'instruction_early', 'instruction_late', 'execution'};
epoch_beh_dx_list = {3, 3, 5};
epoch_window_sec_list = {[-1, -.5], [-.5, 0], [0, .5]};

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
