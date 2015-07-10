if ~exist('all_channels', 'var')
    load('all_channels_ppc.mat');
end

lfp_fs = 1000;
spike_fs = 30000;

num_channels = length(all_channels);

parfor ii = 1:num_channels
    if isempty(all_channels(ii).unit_waveforms)
        continue
    end
    
    regimes = {'before', 'delay', 'go', 'movement',...
        'after_reward', 'gross'}
    num_regimes = length(regimes);
    num_behaviors = length(all_channels(ii).behavior_spectra);
    
    for jj = 1:length(all_channels(ii).unit_waveforms)
        temp_unit = all_channels(ii).unit_waveforms(jj);
        spike_times = temp_unit.timestamp * lfp_fs ; %%% HERE BE PROBLEM
        spike_angles = temp_unit.spike_angles;
        
        for kk = 1:num_regimes
            regime = regimes{kk};
            
            consistency = zeros(num_behaviors, 1);
            regime_spike_angles = cell(num_behaviors, 1);
            for ll = 1:num_behaviors
                timestamps = all_channels(ii).behavior_spectra(ll).(regime).time;
                start = timestamps(1);
                stop = timestamps(end);
                
                % save some space
                all_channels(ii).behavior_spectra(ll).(regime).time = [start, stop];
                
                these_spike_angles = spike_angles(spike_times >= start &...
                    spike_times < stop);
                
                regime_spike_angles{ll} = these_spike_angles;
                consistency(ll) = ppc_from_spike_angles(these_spike_angles);
            end
            all_channels(ii).unit_waveforms(jj).regime_spike_angles.(regime) = regime_spike_angles;
            all_channels(ii).unit_waveforms(jj).regime_ppcs.(regime) = consistency;
        end
    end
end
       
save('all_channels.mat', 'all_channels', '-v7.3')
            
            
            
        