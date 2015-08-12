
p_file = '040114/P-rj040114_MI2.mat';
lfp_file = '040114/r1040114_clean_lfp.mat';

load('definitions');
session = populate_session(parse_p_file(p_file, lfp_file), definitions);

save('new_session_040114.mat', 'session', '-v7.3')

[consistency, firing_rate, spike_width, epoch, band] = get_analysis_columns(session, definitions); 

save('new_analysis_columns_040114.mat', 'consistency', 'firing_rate', 'spike_width', 'epoch', 'band', '-v7.3')

TARGET_BAND = 'mid_beta';
analysis_script

tbl
