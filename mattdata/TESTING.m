
epoch_list = definitions.epochs.list_all;
num_epochs = length(definitions.epochs.list_all);

beh = session.beh;

for chan_num = 1:96
    chan_num
    old_channel = all_channels(chan_num);
    new_channel = session.channel(chan_num);

    if isempty(old_channel.lfp)
%         spike_angles_are_equal(chan_num) = 1;
%         ppcs_are_equal(chan_num) = 1;
        continue
    end

    
    
%     %'Checking LFPs'
%  
%  
%     %'Checking filtering'
%     %filtered = bandpass_filt(channel.lfp, [20, 25]);
%     %all(channel.mid_beta == filtered);
%  
%     %'Checking old spike angle calculation'
%     %unit = channel.unit_waveforms(1);
%     %lfp_fs = 1000;
%     %lfp_times = (1/lfp_fs):(1/lfp_fs):(length(filtered)/lfp_fs);
%     %spike_times = unit.timestamp;
%     %old_calc = OLD_spike_field_ppc( spike_times, channel.mid_beta, lfp_times);
%     %old_angles = unit.spike_angles;
%     %isequalwithequalnans(old_calc, old_angles)    
%  
%     %'Checking spike angle calculation'
%     old_unit = old_channel.unit_waveforms(1);
%     new_unit = new_channel.unit(1);
%     %old_spike_times = old_unit.timestamp;
%     %new_spike_times = new_unit.spike_times;
%     %old_filtered = old_channel.mid_beta;
%     %new_filtered = new_channel.
%     %field_angle = angle(hilbert(filtered));
%     %spike_angles = unit.spike_angles;
%     %new_angles = spike_field_angle(spike_times, field_angle, 1000);
%     %spike_angles_are_equal(chan_num) = isequalwithequalnans(new_angles, spike_angles);
%     
%     %isequalwithequalnans(old_calc, new_angles)
%     %
%     %new_firing_rates = squeeze(session.channel(chan_num).unit(1).firing_rate(1,:,:));
%     %for epoch_num = 1:num_epochs
%     %    epoch_name = [epoch_list{epoch_num}, '_sec'];
%     %    old_spike_times = channel.unit_waveforms(1).regime_spike_times.(epoch_name);
%     %    old_firing_rates = cellfun(@length, old_spike_times) / .500;
%     %    if old_firing_rates ~= new_firing_rates(epoch_num, :)'
%     %        fprintf('Inequal rates chan %d, epoch %s\n', chan_num, epoch_name);
%     %    end
%     %end
% 
%     band_num = 1;
%     
%  
%     epoch_name = 'instruction_early';
%     epoch_num = 1;
%     epoch_func = definitions.epochs.(epoch_name);
%     epoch_time = epoch_func(beh);
%     
%     %new_ppc = zeros(391,1);
%     %
%     %num_behaviors = 391;
%     %for ii = 1:num_behaviors
%     %    time = epoch_time(ii, :);
%     %    epoch_spike_dx = spike_times >= time(1) & spike_times < time(2);
%     %    epoch_spike_angles = spike_angles(epoch_spike_dx);
%     %    new_ppc(ii) = ppc_from_spike_angles(epoch_spike_angles);
%     %end
%    
%     new_ppc = squeeze(new_unit.ppc(1,epoch_num,:));
%     old_ppc = old_unit.regime_ppcs.([epoch_name, '_sec']);
% 
%     ppcs_are_equal(chan_num) = isequalwithequalnans(old_ppc, new_ppc);
end

%fprintf('Are the spike angles equal? %d', all(spike_angles_are_equal));
%fprintf('Are the ppcs equal? %d\n', all(ppcs_are_equal));
