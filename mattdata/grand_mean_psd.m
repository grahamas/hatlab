function [PSD, F] = grand_mean_PSD(array_recording)
% Calculates a mean PSD across all channels.
    function Pxx_and_F = LFP_periodogram(channel) 
        [Pxx, F] = periodogram(channel.LFP,[],[],channel.parent_array.LFP_fs);
        Pxx_and_F = {Pxx, F};
    end
    array_PSDs = array_recording.map_over_channels(@LFP_periodogram);
    n_channels = length(array_PSDs);

    Pxxs = cellfun(@(c) c{1}, array_PSDs, 'UniformOutput', 0);
    Fs = cellfun(@(c) c{2}, array_PSDs, 'UniformOutput', 0);

    first_F = Fs{1};
    PSD = Pxxs{1};
    for i_channel = 2:n_channels
        assert(all(first_F == Fs{i_channel}))
        PSD = PSD + Pxxs{i_channel};
    end

    PSD = PSD / n_channels;    
    F = first_F;

end
