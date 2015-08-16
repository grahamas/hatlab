
num_channels = length(all_channels);

lfp_fs = 1000;

num_behaviors = size(beh, 1);

for ii = 1:num_channels
    'main'
    ii
    if isempty(all_channels(ii).unit)
        continue
    end
    units = all_channels(ii).unit;
    num_units = length(units);
    for jj = 1:num_units
        unit_dx = jj 
        tp_width = trough_peak_width(all_channels(ii).unit_waveforms(unit_dx).waveform);
        all_channels(ii).unit_waveforms(unit_dx).width = tp_width;
    end
    
end
    
        
