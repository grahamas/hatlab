if ~exist('all_channels', 'var')
    load('all_channels.mat');
end

lfp_fs = 1000;
spike_fs = 30000;

num_channels = length(all_channels);

regimes = {'before', 'delay', 'go', 'movement',...
        'after_reward'};%, 'gross'};
wide_means = zeros(length(regimes), 1);
narrow_means = zeros(length(regimes), 1);

filter_nan = @(arr) arr(~isnan(arr));
    
for kk = 1:length(regimes)
    regime = regimes{kk};
    wide_mean_accum = 0;
    narrow_mean_accum = 0;
    
    for ii = 1:num_channels
        if isempty(all_channels(ii).unit_waveforms)
            continue
        end
    
        num_regimes = length(regimes);
        num_behaviors = length(all_channels(ii).behavior_spectra);
        num_units = length(all_channels(ii).unit_waveforms);
    
        for jj = 1:num_units
            temp_unit = all_channels(ii).unit_waveforms(jj);
            if temp_unit.width > 10
                wide_mean_accum = wide_mean_accum + mean(filter_nan(temp_unit.regime_ppcs.(regime)));
            else
                narrow_mean_accum = narrow_mean_accum + mean(filter_nan(temp_unit.regime_ppcs.(regime)));
            end
        end
    end
    wide_means(kk) = wide_mean_accum / num_units;
    narrow_means(kk) = narrow_mean_accum / num_units;
end

figure
hold on
plot(wide_means)
plot(narrow_means)
legend('Wide', 'Narrow')