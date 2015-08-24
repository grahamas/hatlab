
% Load config.m
config

% n = "number of"
n_data_dirs = length(dn_data_list);

% i = "index of" or "i of" (looping var)
for i_data_dir = 1:n_data_dirs
    dn_data = dn_data_list{i_data_dir};
    
    %fp = "full path" or "file path"
    fp_load_raw_data = [dp_data_root, dn_data, fn_raw_data_vars];
    eval(fp_load_raw_data);
