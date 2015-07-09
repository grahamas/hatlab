load('chans_and_units.mat');

num_channels = length(all_channels)

for ii = 1:num_channels
    ['Starting channel ', num2str(ii)]
    if isempty(all_channels(ii).unit)
        continue
    end
    
    all_channels(ii).unit_waveforms = unit_waveforms(all_channels(ii).unit);
end
'Outside?'
save('all_channels.mat', 'all_channels', '-v7.3')
