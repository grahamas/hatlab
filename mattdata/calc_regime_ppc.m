spike_fs = 30000;

num_channels = length(all_channels);
        
regimes = {'instruction_early', 'instruction_late', 'execution'};
    
num_regimes = length(regimes);
num_behaviors = length(beh);

%parpool('local', 16)
%parfor ii = 1:num_channels
for ii = 1:num_channels
    if isempty(all_channels(ii).unit_waveforms)
        continue
    end

    %all_channels(ii).behavior_spectra(num_behaviors) = {};
    lfp_times = (1/lfp_fs):(1/lfp_fs):(all_channels(ii).lfp);
    all_channels(ii).mid_beta = mid_beta_filt(all_channels(ii).lfp);

    for jj = 1:length(all_channels(ii).unit_waveforms)
        temp_unit = all_channels(ii).unit_waveforms(jj);
        spike_times = temp_unit.timestamp ; %%% HERE BE PROBLEM
                    %%%% NOTE THAT THIS ASSUMES REGIMES IN SECONDS
                    %%%% NOT THE CASE!!!!
        spike_angles = spike_field_angles(...
            spike_times, all_channels(ii).mid_beta, lfp_times);
        all_channels(ii).unit_waveforms(jj).spike_angles = spike_angles;
        
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
                regime_spike_rates{ll} = length(these_spike_times) / (stop - start); % SECONDS DEPENDENCE
                consistency(ll) = ppc_from_spike_angles(these_spike_angles);
            end
            all_channels(ii).unit_waveforms(jj).regime_spike_angles.(regime) = regime_spike_angles;
            all_channels(ii).unit_waveforms(jj).regime_spike_times.(regime) = regime_spike_times;
            all_channels(ii).unit_waveforms(jj).regime_spike_rates.(regime) = regime_spike_rates;
            all_channels(ii).unit_waveforms(jj).regime_ppcs.(regime) = consistency;
        end
    end
end
'...done.'
       
            
            
            
        
