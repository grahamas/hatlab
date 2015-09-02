function LOAD_rs_clean_SNR_LFP(obj, dp_data, fn_to_load_list )

EXPECTED_n_data_files = 3;

desired_length = 3;
zero_pad_str = @(num_str)...
    [repmat('0', 1, desired_length-length(num_str)), num_str];

n_data_files = length(fn_to_load_list);
assert(n_data_files == EXPECTED_n_data_files)

for i_data_file = 1:n_data_files
    load([dp_data, fn_to_load_list{i_data_file}])
end

nev = sortedNEV;
nev_ft = nev.MetaTags.TimeRes;
nev_spike_times = nev.Data.Spikes.TimeStamp;
nev_waveforms = nev.Data.Spikes.Waveform';

% renaming for later clarity
good_channel_nums = chans;

obj.beh = beh;
obj.LFP_fs = 1000;
obj.channel_num2physical_map = MIchan2rc;
obj.channel_list = [];

prev_channel_num = 0;

for i_good_channel_num = 1:length(good_channel_nums)
    channel_num = good_channel_nums(i_good_channel_num);
    
    if channel_num < prev_channel_num
        fprintf('Something is wrong! Chan_num decreased!');
        obj = 0;
        return
    else
        if channel_num ~= prev_channel_num
            if i_good_channel_num > 1
                obj.add_channel(new_channel)
            end
            n_units = 1;
            assigned_units = 1;
            lfp_name = ['lfp',num2str(channel_num)];
            new_channel = ChannelRecording(obj, channel_num, eval(lfp_name));
        else
            n_units = n_units + 1;
            assigned_units = assigned_units + 1;
        end

        channel_str = zero_pad_str(num2str(channel_num));
        vn_spike_times = ['Chan',channel_str,char(n_units-1+'a')];
        while ~exist(vn_spike_times,'var')
            n_units = n_units + 1;
            vn_spike_times = ['Chan',channel_str,char(n_units-1+'a')];
            assert(n_units < 26, sprintf('Infinite loop trying to find %s', vn_spike_times))
        end
        these_spike_times = eval(vn_spike_times);
        these_nev_spike_times = these_spike_times * nev_ft;
        
        new_unit = UnitRecording(new_channel, these_spike_times);
        new_unit.set_waveform_width_from_all(nev_waveforms, nev_spike_times, these_nev_spike_times);
        new_unit.unit_number = assigned_units;
        new_channel.add_unit(new_unit);
    end
    prev_channel_num = channel_num;
end
            

end

