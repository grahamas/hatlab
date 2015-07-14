if ~exist('all_channels', 'var')
    load('all_channels_new.mat');
end

lfp_fs = 1000;
spike_fs = 30000;

num_channels = length(all_channels);

epoch = {};
spike_width = [];
firing_rate = [];
consistency = [];

for ii = 1:num_channels
    if isempty(all_channels(ii).unit_waveforms)
        continue
    end
    
    regimes = {'instruction_early_sec', 'instruction_late_sec', 'execution_sec'};
    
    num_regimes = length(regimes);
    num_behaviors = length(all_channels(ii).behavior_spectra);
    
    for jj = 1:length(all_channels(ii).unit_waveforms)
        this_unit = all_channels(ii).unit_waveforms(jj);
        for kk = 1:num_regimes
            this_regime = regimes{kk};
            these_rates = this_unit.regime_spike_rates.(this_regime);
            these_ppcs = this_unit.regime_ppcs.(this_regime);
            for ll = 1:num_behaviors
                %could be flattened, but complexity.
                
                this_width = this_unit.width;
                this_rate = these_rates(ll);
                this_ppc = these_ppcs(ll);
                
                epoch{end+1} = this_regime;
                spike_width(end+1) = this_width;
                firing_rate(end+1) = this_rate;
                consistency(end+1) = this_ppc;
            end
        end
    end
end

epoch = epoch';
spike_width = spike_width';
firing_rate = firing_rate';
consistency = consistency';

save('analysis_columns.mat', 'epoch', 'spike_width', 'firing_rate', 'consistency', '-v7.3')
                
                
