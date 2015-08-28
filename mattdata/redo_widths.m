

n_units = length(goodUnits);
current_channel = array_recording.channel_list{1};
current_channel_num = 1;
current_unit = current_channel.unit_list{1};
current_unit_num = 1;
for i_good_unit = 1:n_units
    current_channel = array_recording.channel_list{current_channel_num};
    current_unit = current_channel.unit_list{current_unit_num};
    this_unit = goodUnits(i_good_unit);
    if this_unit.chan == 42
        fprintf('Skipping Channel 42\n')
        current_unit_num = 1;
    else
        this_width = spikeWidths(i_good_unit);
        current_unit.waveform_width = this_width;
        if current_unit_num == length(current_channel.unit_list)
            current_channel_num = current_channel_num + 1;
            current_unit_num = 1;
        else
            current_unit_num = current_unit_num + 1;
        end
    end
end
    
width_cell = array_recording.map_over_units(@(unit)...
            unit.waveform_width);    
    
      