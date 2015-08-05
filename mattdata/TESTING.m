epoch_list = definitions.epochs.list_all;
num_epochs = length(definitions.epochs.list_all);

fprintf('fprintf works\n')

for chan_num = 1:96

    channel = all_channels(chan_num);

    if isempty(channel.lfp)
        continue
    end

    'Checking LFPs'
 
 
    'Checking filtering'
    filtered = bandpass_filt(channel.lfp, [20, 25]);
    all(channel.mid_beta == filtered);
 
    'Checking old spike angle calculation'
    unit = channel.unit_waveforms(1);
    lfp_fs = 1000;
    lfp_times = (1/lfp_fs):(1/lfp_fs):(length(filtered)/lfp_fs);
    spike_times = unit.timestamp;
    old_calc = OLD_spike_field_ppc( spike_times, channel.mid_beta, lfp_times);
    old_angles = unit.spike_angles;
    isequalwithequalnans(old_calc, old_angles)    
 
    'Checking spike angle calculation'
    unit = channel.unit_waveforms(1);
    spike_times = unit.timestamp;
    field_angle = angle(hilbert(filtered));
    old_angles = unit.spike_angles;
    new_angles = spike_field_angle(spike_times, field_angle, 1000);
    isequalwithequalnans(new_angles, old_angles)
    
    isequalwithequalnans(old_calc, new_angles)
    
    new_firing_rates = squeeze(session.channel(chan_num).unit(1).firing_rate(1,:,:));
    for epoch_num = 1:num_epochs
        epoch_name = [epoch_list{epoch_num}, '_sec'];
        old_spike_times = channel.unit_waveforms(1).regime_spike_times.(epoch_name);
        old_firing_rates = cellfun(@length, old_spike_times) / .500;
        if old_firing_rates ~= new_firing_rates(epoch_num, :)'
            fprintf('Inequal rates chan %d, epoch %s\n', chan_num, epoch_name);
        end
    end
        
    
 
    'Checking ppc'
    epoch_name = 'instruction_early';
    epoch_num = 1;
    epoch_func = definitions.epochs.(epoch_name);
    epoch_time = epoch_func(beh);
    
    new_ppc = zeros(391,1);
    
    num_behaviors = 391;
    for ii = 1:num_behaviors
        time = epoch_time(ii, :);
        epoch_spike_dx = spike_times >= time(1) & spike_times < time(2);
        new_epoch_spike_angles = new_angles(epoch_spike_dx);
        new_ppc(ii) = ppc_from_spike_angles(new_epoch_spike_angles);
    end
    
    old_ppc = unit.regime_ppcs.([epoch_name, '_sec']);

    isequalwithequalnans(old_ppc, new_ppc)
    

end
