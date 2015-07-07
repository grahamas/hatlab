
nev = sortedNEV;
nev_fs = nev.MetaTags.SampleRes;
nev_ft = nev.MetaTags.TimeRes;
nev_timestamp = nev.Data.Spikes.TimeStamp;
nev_waveform = nev.Data.Spikes.Waveform;

prev_chan = 0;
count = 0;

num_units = length(chans);

all_units = repmat( struct('chan', 0, 'unit', 0, 'timestamp', [],...
    'waveform', []), 1, num_units);


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
    
    var_name = ['Chan',chan_str,unit_str];
    
    if strcmp(var_name, 'Chan078a')
        continue
    end
    
    all_units(ii).chan = chan;
    all_units(ii).unit = count;
    
    my_timestamp = eval([var_name]);
    my_nev_timestamp = my_timestamp * nev_ft;
    
    all_units(ii).timestamp = my_timestamp;
    all_units(ii).waveform = nev_waveform(:, ismember(nev_timestamp,my_nev_timestamp));
end
    