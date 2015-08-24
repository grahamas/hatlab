function LOAD_rj_P_clean_LFP(obj, dp_data, fn_to_load_list )

    disp('HI THERE')

EXPECTED_n_data_files = 2;

n_data_files = length(fn_to_load_list);
assert(n_data_files == EXPECTED_n_data_files)

for i_data_file = 1:n_data_files
    load([dp_data, fn_to_load_list{i_data_file}])
end



end

