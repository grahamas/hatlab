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
broadcast_beh = repmat(session.beh, 1,1,num_channels);

channels = session.channel;
num_behaviors = length(session.beh);

parpool('local', 16)
parfor ii = 1:num_channels
    
    if isempty(channels(ii).lfp)
        continue
    end

    these_definitions = broadcast_definitions(ii);
    
    defined_bands = these_definitions.bands.list_all;
    num_bands = size(defined_bands, 2);

    defined_epochs = these_definitions.epochs.list_all;
    num_epochs = size(defined_epochs, 2);
    
    band_signals = cell(num_bands, 1);
    band_angles = cell(num_bands, 1);
    
    % Filter LFP
    for jj = 1:num_bands
        band_name = defined_bands{jj};
        band_cutoffs = these_definitions.bands.(band_name);
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
        channels(ii).unit(jj).ppc...
            = zeros(num_bands, num_epochs, num_behaviors);
        channels(ii).unit(jj).firing_rate...
            = zeros(num_bands, num_epochs, num_behaviors);
        for band_num = 1:num_bands
            band_name = defined_bands{band_num};
            band_spike_angles = spike_field_angle(spike_times,...
                band_angles{band_num}, lfpfs);
            for kk = 1:num_epochs
                epoch_name = defined_epochs{kk};
                epoch_func = these_definitions.epochs.(epoch_name);
                epoch_time = epoch_func(broadcast_beh(:,:,ii));
                for ll = 1:num_behaviors
                    time = epoch_time(ll,:);
                    epoch_spike_dx = spike_times > time(1)...
                        & spike_times <= time(2);
                    channels(ii).unit(jj)...
                        .firing_rate(band_num, kk, ll)...
                        = sum(epoch_spike_dx) / .5;
                    epoch_spike_angles = band_spike_angles(epoch_spike_dx);
                    channels(ii).unit(jj).ppc(band_num, kk, ll)...
                        = ppc_from_spike_angles(epoch_spike_angles);
                end
            end
        end
    end
end

                    
session.channel = channels;
            






end

