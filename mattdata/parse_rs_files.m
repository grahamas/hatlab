function base_session = parse_rs_files( snr_file, lfp_file, spike_file )

load(snr_file, lfp_file, spike_file);

nev = sortedNEV;
nev_ft = nev.MetaTags.TimeRes;
nev_timestamp = nev.Data.Spikes.TimeStamp;
nev_waveforms = nev.Data.Spikes.Waveform;

NUM_CHANS = 96;
prev_chan_num = 0;
count = 0;

num_units = length(chans);

base_session = {};
base_session.beh = beh;
base_session.channel = {};

for ii = 1:num_units
    chan_num = chans(ii);
    
    if chan_num < prev_chan_num
        fprintf('Something is wrong! Chan_num decreased!');
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
        chan_str = zero_pad_str(num2str(chan), 3);
        unit_str = char(num_units-1+'a');
        
        timestamp_name = ['Chan',chan_str,unit_str];
        
        if strcmp(timestamp_name, 'Chan078a')
            count = count + 1;
            timestamp_name = 'Chan078b';
        end
        
        these_spike_times = eval(timestamp_name);
        these_nev_spike_times = these_spike_times * nev_ft;
        
        base_session.channel(chan_num).unit(num_units).spike_times...
            = these_spike_times;
        base_session.channel(chan_num).unit(num_units).width...
            = trough_peak_width(nev_waveforms(ismember(nev_timestamp,...
                these_nev_spike_times),:));
    end
    prev_chan_num = chan_num;
    
end
end


