
snr_file = 'rs1050225_clean_SNRgt4.mat';
lfp_file = 'rs1050225_MI_clean_LFP.mat';
spk_file = 'rs1050225_MI_SpikeData.mat';

load('definitions');
session = populate_session(parse_rs_files(snr_file, lfp_file, spk_file), definitions);

save('new_session_050225.mat', 'session', '-v7.3')

[consistency, firing_rate, spike_width, epoch, band] = get_analysis_columns(session, definitions); 

save('new_analysis_columns_050225.mat', 'consistency', 'firing_rate', 'spike_width', 'epoch', 'band', '-v7.3')

TARGET_BAND = 'mid_beta';
analysis_script

tbl
