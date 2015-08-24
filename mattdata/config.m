% dp = directory path 
% dn = directory name
% fn = file name
dp_data_root = '/home/grahams/git_data/hatlab/mattdata/';

dn_data_list = {'Rockstar/rs1050225/','Raju/040114/'};
dn_load_data = 'raw_data_loader';

fn_raw_data_vars = 'raw_data_vars.m';

raw_data_loading_functions = {};
raw_data_loading_functions.rj_P_clean_LFP = @load_p_data;
raw_data_loading_functions.rs_clean_SNR_LFP = @load_rs_data;