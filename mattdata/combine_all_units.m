
nev = sortedNEV;
nev_fs = nev.MetaTags.SampleRes;
nev_ft = nev.MetaTags.TimeRes;
nev_timestamp = nev.Data.Spikes.TimeStamp;
nev_waveform = nev.Data.Spikes.Waveform;

NUM_CHANS = 96;
prev_chan = 0;
count = 0;

num_units = length(chans);

%unit_waveforms(num_units) = struct('chan', 0, 'unit', 0, 'timestamp', [],...
%    'waveform', [], 'width', 0);

%all_channels(NUM_CHANS) = struct('unit', [], 'lfp', [],...
%   'behavior_spectra', {});

all_channels(NUM_CHANS) = struct();

for ii = 1:num_units
    chan = chans(ii)
    if prev_chan == chan
        count = count + 1;
    else
        count = 1;
    end
    all_channels(chan).unit_waveforms(count) = struct('chan', 0, 'unit', 0,...
        'timestamp', [], 'waveform', [], 'width', 0);
    prev_chan = chan;
    all_channels(chan).behavior_spectra(391) = struct();
    
    chan_str = zero_pad_str(num2str(chan), 3);
    unit_str = char(count+'a'-1);
    
    timestamp_name = ['Chan',chan_str,unit_str];
    
    if strcmp(timestamp_name, 'Chan078a')
        timestamp_name = 'Chan078b';
    end
    cur_num_chans = length(all_channels);
    if count == 1
        all_channels(chan).unit = [ii];
    else
        all_channels(chan).unit = [all_channels(chan).unit, ii];
    end
    if ~isfield(all_channels(chan),'lfp')
       lfp_name = ['lfp', num2str(chan)];
       all_channels(chan).lfp = eval(lfp_name);
    end
    all_channels(chan).unit_waveforms(count).chan = chan;
    all_channels(chan).unit_waveforms(count).unit = count;
    
    my_timestamp = eval(timestamp_name);
    my_nev_timestamp = my_timestamp * nev_ft;
    
    all_channels(chan).unit_waveforms(count).timestamp = my_timestamp;
    all_channels(chan).unit_waveforms(count).waveform = nev_waveform(:, ismember(nev_timestamp,my_nev_timestamp));
end
    
