for ii = 1:num_channels
    if isempty(all_channels(ii).unit)
        continue
    end
    
    all_channels(ii).unit_waveforms = unit_waveforms(all_channels(ii).unit);
end