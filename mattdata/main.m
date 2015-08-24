
% Load config.m
config

% n = "number of"
n_data_dirs = length(dn_data_list);

% i = "index of" or "i of" (looping var)
for i_data_dir = 1:n_data_dirs
    dn_data = dn_data_list{i_data_dir};
    dp_data = [dp_data_root, dn_data];
    
    a = ArrayRecording(dp_data)
end
