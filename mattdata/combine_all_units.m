
nev = sortedNEV;
nev_fs = nev.MetaTags.SampleRes;
nev_ft = nev.MetaTags.TimeRes;
nev_timestamp = nev.Data.Spikes.TimeStamp;
nev_waveform = nev.Data.Spikes.Waveform;

NUM_CHANS = 96;
prev_chan = 0;
count = 0;

num_units = length(chans);

unit_waveforms = repmat( struct('chan', 0, 'unit', 0, 'timestamp', [],...
    'waveform', [], 'width', 0), 1, num_units);

all_channels = repmat( struct('unit', [], 'lfp', [],...
    'behavior_spectra', {}), 1, NUM_CHANS);

for ii = 1:num_units
    chan = chans(ii);
    if prev_chan == chan
        count = count + 1;
    else
        count = 1;
    end
    prev_chan = chan;
    
    chan_str = zero_pad_str(num2str(chan), 3);
    unit_str = char(count+'a'-1);
    
    timestamp_name = ['Chan',chan_str,unit_str];
    
    if strcmp(timestamp_name, 'Chan078a')
        count = count + 1;
        timestamp_name = 'Chan078b';
    end
    
    all_channels(chan).unit = [all_channels(chan).unit, ii];
    if isempty(all_channels(chan).lfp)
       lfp_name = ['lfp', num2str(chan)];
       all_channels(chan).lfp = eval(lfp_name);
    end
    unit_waveforms(ii).chan = chan;
    unit_waveforms(ii).unit = count;
    
    my_timestamp = eval(timestamp_name);
    my_nev_timestamp = my_timestamp * nev_ft;
    
    unit_waveforms(ii).timestamp = my_timestamp;
    unit_waveforms(ii).waveform = nev_waveform(:, ismember(nev_timestamp,my_nev_timestamp));
end
    