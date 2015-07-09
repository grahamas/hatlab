

lfp_fs = 1000;
spike_fs = 30000;

parfor ii = 1:num_channels
    if isempty(all_channels(ii).unit_waveforms)
        continue
    end
    
    channel_mid_beta = mid_beta_filt( all_channels(ii).lfp);
    all_channels(ii).mid_beta = channel_mid_beta;
    
    lfp_times = (1/lfp_fs):(1/lfp_fs):(length(channel_mid_beta)/lfp_fs);
    
    num_units = length(all_channels(ii).unit_waveforms);
    for jj = 1:num_units
        [beta_ppc, spike_angles] = spike_field_ppc(...
            all_channels(ii).unit_waveforms(jj).timestamp,...
            channel_mid_beta, lfp_times);
        all_channels(ii).unit_waveforms(jj).beta_ppc = beta_ppc;
        all_channels(ii).unit_waveforms(jj).spike_angles = spike_angles;
    end
end