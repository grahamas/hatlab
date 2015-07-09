
num_channels = length(all_channels);

lfp_fs = 1000;
global_moving_win = [2, .1];
local_moving_win = [.1, .01];
params = struct('Fs', lfp_fs, 'tapers', [3 5], 'fpass', [0 80]);

relevant_behaviors = [1, 3, 4, 5, 6, 7];
relevant_beh = beh(:, relevant_behaviors) * lfp_fs;
num_behaviors = size(beh, 1);
before_start = 2 * lfp_fs;
after_reward = .5 * lfp_fs;

WIDTH_CUT = 10;

figure
subplot(2,2,1);

for ii = 1:4
    if isempty(all_channels(ii).unit)
        continue
    end
    units = all_channels(ii).unit;
    num_units = length(units);
    for jj = 1:num_units
        unit_dx = units(jj);
        spike_times = unit_waveforms(unit_dx).timestamp;
        width = unit_waveforms(unit_dx).width;
        if width > WIDTH_CUT
            base = 1;
        else
            base = 0;
        end
        
        
    end
    
end
    
        