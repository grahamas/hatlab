function base_session = parse_p_file( p_file, lfp_file )

load(p_file)
load(lfp_file)

base_session = {};
base_session.beh = beh;
base_session.channel = {};

base_session.lfpfs = 1000;

num_good_units = length(goodUnits);

prev_chan_num = 0;
num_units = 1;
for ii = 1:num_good_units
    % Each row of goodUnits has:
    %   1. spike timestamps
    %   2. channel number
    %   3. binned spikes (not used here)
    chan_num = goodUnits(ii).chan;
    
    if chan_num < prev_chan_num
        fprintf('Something is wrong!');
        base_session = 0;
        return
    else
        if chan_num == prev_chan_num
            num_units = num_units + 1;
        else
            num_units = 1;
            lfp_name = ['lfp',num2str(chan_num)];
            if exist(lfp_name, 'var')
                base_session.channel(chan_num).lfp.raw = eval(lfp_name);
            else
                continue
            end
        end
        these_spike_times = goodUnits(ii).stamps;        
        base_session.channel(chan_num).unit(num_units).spike_times...
            = these_spike_times;
        base_session.channel(chan_num).unit(num_units).width...
            = trough_peak_width(waveforms(ismember(spikeTimes,these_spike_times),:));
    end
    prev_chan_num = chan_num;
end

end



