

lfp_fs = 1000;
spike_fs = 30000;

for ii = 1:num_channels
    if isempty(all_channels(ii).unit)
        continue
    end
    
    channel_mid_beta = mid_beta_filt( all_channels(ii).lfp);
    all_channels(ii).mid_beta = channel_mid_beta;
    
    lfp_times = (1/lfp_fs):(1/lfp_fs):(length(channel_mid_beta)/lfp_fs);
    
    num_units = length(all_channels(ii).unit);
    for jj = 1:num_units
        unit = unit_waveforms(all_channels(ii).unit(jj));
        unit.beta_ppc = spike_field_ppc(unit.timestamp, channel_mid_beta,...
            lfp_times);
    end
end