load('definitions')

snr_file = 'rs1050225_clean_SNRgt4.mat';
lfp_file = 'rs1050225_MI_clean_LFP.mat';
spike_file = 'rs1050225_MI_SpikeData.mat';

new_session_name = 'session050225.mat';
new_columns_name = 'analysis_columns_050225.mat';

base_session = parse_rs_files(snr_file, lfp_file, spike_file);
session = populate_session(base_session, definitions);

save(new_session_name, 'session', '-v7.3');

[consistency, firing_rate, spike_width, epoch, band] = get_analysis_columns(session, definitions);

save(new_columns_name, 'consistency', 'firing_rate', 'spike_width', 'epoch', 'band', '-v7.3');
