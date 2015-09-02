function LOAD_rj_P_clean_LFP(obj, dp_data, fn_to_load_list )

EXPECTED_n_data_files = 2;

n_data_files = length(fn_to_load_list);
assert(n_data_files == EXPECTED_n_data_files)

for i_data_file = 1:n_data_files
    load([dp_data, fn_to_load_list{i_data_file}])
end

obj.beh = beh;
obj.LFP_fs = 1000;
obj.channel_num2physical_map = MIchan2rc;
obj.channel_list = [];

% renaming for later clarity
good_unit_list = goodUnits;

n_good_units = length(good_unit_list);

prev_channel_num = 0;
for i_good_unit = 1:n_good_units
    % Each row of goodUnits has:
    %   1. spike timestamps
    %   2. channel number
    %   3. binned spikes (not used here)
    this_unit = good_unit_list(i_good_unit);
    channel_num = this_unit.chan;
    
    if channel_num < prev_channel_num
        fprintf('Something is wrong!');
        return
    else
        if channel_num == prev_channel_num
            n_units = n_units + 1;
        else
            if i_good_unit > 1
                obj.add_channel(new_channel)
            end
            n_units = 1;
            LFP_name = ['lfp',num2str(channel_num)];
            if exist(LFP_name, 'var')
                new_channel = ChannelRecording( obj, channel_num, double(eval(LFP_name)));
            else
                fprintf('No LFP recording found! Chan %d\n', channel_num)
                continue
            end
        end
        these_spike_times = goodUnits(i_good_unit).stamps;
        
        new_unit = UnitRecording(new_channel, these_spike_times);
        %new_unit.set_waveform_width_from_all(waveforms, spikeTimes, these_spike_times);
        new_unit.spike_width = spikeWidths(i_good_unit);
        new_unit.unit_number = n_units;
        new_channel.add_unit(new_unit);
        
    end
    prev_channel_num = channel_num;
end
    



end

