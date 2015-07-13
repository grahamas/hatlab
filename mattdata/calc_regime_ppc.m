if ~exist('all_channels', 'var')
    load('all_channels_new.mat');
end

if ~exist('beh', 'var')
    load('beh.mat');
end

lfp_fs = 1000;
spike_fs = 30000;

num_channels = length(all_channels);
        


parfor ii = 1:num_channels
    if isempty(all_channels(ii).unit_waveforms)
        continue
    end
    
    regimes = {'instruction_early_sec', 'instruction_late_sec', 'execution_sec'}
    
    num_regimes = length(regimes);
    num_behaviors = length(all_channels(ii).behavior_spectra);
    
    for jj = 1:length(all_channels(ii).unit_waveforms)
        temp_unit = all_channels(ii).unit_waveforms(jj);
        spike_times = temp_unit.timestamp ; %%% HERE BE PROBLEM
                    %%%% NOTE THAT THIS ASSUMES REGIMES IN SECONDS
                    %%%% NOT THE CASE!!!!
        spike_angles = temp_unit.spike_angles;
        
        for kk = 1:num_regimes
            regime = regimes{kk};
            
            consistency = zeros(num_behaviors, 1);
            regime_spike_angles = cell(num_behaviors, 1);
            regime_spike_times = cell(num_behaviors, 1);
            regime_spike_rates = cell(num_behaviors, 1);
            for ll = 1:num_behaviors
                timestamps = all_channels(ii).behavior_spectra(ll).(regime).time;
                start = timestamps(1);
                stop = timestamps(2);
                
                these_spike_dx = (spike_times >= start & spike_times < stop);
                these_spike_angles = spike_angles(these_spike_dx);
                these_spike_times = spike_times(these_spike_dx);
                
                
                regime_spike_angles{ll} = these_spike_angles;
                regime_spike_times{ll} = these_spike_times;
                regime_spike_rates{ll} = length(these_spike_times) / (stop - start) % SECONDS DEPENDENCE
                consistency(ll) = ppc_from_spike_angles(these_spike_angles);
            end
            all_channels(ii).unit_waveforms(jj).regime_spike_angles.(regime) = regime_spike_angles;
            all_channels(ii).unit_waveforms(jj).regime_spike_times.(regime) = regime_spike_times;
            all_channels(ii).unit_waveforms(jj).regime_spike_rates.(regime) = regime_spike_rates
            all_channels(ii).unit_waveforms(jj).regime_ppcs.(regime) = consistency;
        end
    end
end
'...done.'
       
save('all_channels.mat', 'all_channels', '-v7.3')
            
            
            
        
