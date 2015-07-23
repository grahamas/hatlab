function session = populate_session( base_session, definitions )
%POPULATE_SESSION
% Given base session with minimum:
%       session.beh
%       session.lfp.raw
%       channels.unit.width
%       channels.unit.spike_times
% and a definitions structure.

session = base_session;

% Extract definitions

lfpfs = session.lfpfs;

num_channels = length(session.channel);

broadcast_definitions = repmat(definitions, num_channels, 1);

channels = session.channel;

parfor ii = 1:num_channels
    
    if isempty(channels(ii).lfp)
        continue
    end
    
    band_signals = cell(num_bands, 1);
    band_angles = cell(num_bands, 1);

    definitions = broadcast_definitions(ii);
    
    defined_bands = definitions.bands.list_all;
    num_bands = size(defined_bands, 2);

    defined_epochs = definitions.epochs.list_all;
    num_epochs = size(defined_epochs, 2);
    
    % Filter LFP
    for jj = 1:num_bands
        band_name = defined_bands{jj};
        band_cutoffs = definitions.bands.(band_name);
        band_signals{jj}...
            = bandpass_filt(double(channels(ii).lfp.raw), band_cutoffs);
        band_angles{jj}...
            = angle(hilbert(band_signals{jj}));
    end

    % Populate units
    % Note: This is all screwy in terms of i/j indexing efficiency, but
    % it's clearer this way.
    num_units = length(channels(ii).unit);
    for jj = 1:num_units
        spike_times = channels(ii).unit.spike_times;
        num_behaviors = length(session.beh);
        channels(ii).unit(jj).ppc...
            = zeros(num_bands, num_epochs, num_behaviors);
        channels(ii).unit(jj).firing_rate...
            = zeros(num_bands, num_epochs, num_behaviors);
        for band_num = 1:num_bands
            'Starting band ', num2str(band_num)
            band_name = defined_bands{band_num};
            band_spike_angles = spike_field_angle(spike_times,...
                band_angles{band_num}, lfpfs);
            for kk = 1:num_epochs
                'Starting epoch ', num2str(kk)
                epoch_name = defined_epochs{kk};
                epoch_func = definitions.epochs.(epoch_name);
                epoch_time = epoch_func(session.beh);
                for ll = 1:num_behaviors
                    time = epoch_time(ll,:);
                    epoch_spike_dx = spike_times > time(1)...
                        & spike_times <= time(2);
                    channels(ii).unit(jj)...
                        .firing_rate(band_num, kk, ll)...
                        = sum(epoch_spike_dx);
                    epoch_spike_angles = band_spike_angles(epoch_spike_dx);
                    channels(ii).unit(jj).ppc(band_num, kk, ll)...
                        = ppc_from_spike_angles(epoch_spike_angles);
                end
            end
        end
    end
end
                    
            






end

