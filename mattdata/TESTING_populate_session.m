%Testing modified version of populate_session.
%Also load all_channels.

% Extract definitions

lfp_fs = session.lfpfs;
assert(lfp_fs == 1000);

num_channels = length(session.channel);

broadcast_definitions = repmat(definitions, num_channels, 1);
broadcast_beh = repmat(session.beh, 1,1,num_channels);

channels = session.channel;
num_behaviors = length(session.beh);



%parpool('local', 16)
for ii = 1:num_channels
    
    if isempty(channels(ii).lfp)
        continue
    end

    these_definitions = broadcast_definitions(ii);
    
    defined_bands = these_definitions.bands.list_all;
    num_bands = 1;%size(defined_bands, 2);

    defined_epochs = these_definitions.epochs.list_all;
    num_epochs = size(defined_epochs, 2);
    
    band_signals = cell(num_bands, 1);
    band_angles = cell(num_bands, 1);
    
    % Filter LFP
    for jj = 1:num_bands
        band_name = defined_bands{jj};
        assert(strcmp(band_name,'mid_beta'))
        band_cutoffs = these_definitions.bands.(band_name);
        band_signals{jj}...
            = bandpass_filt(channels(ii).lfp.raw, band_cutoffs);
        band_angles{jj}...
            = angle(hilbert(band_signals{jj}));
    end
    
    lfp_times = (1/lfp_fs):(1/lfp_fs):(length(band_signals{1})/lfp_fs);

    % Populate units
    % Note: This is all screwy in terms of i/j indexing efficiency, but
    % it's clearer this way.
    num_units = length(channels(ii).unit);
    for jj = 1:num_units
         spike_times = channels(ii).unit(jj).spike_times;
%         channels(ii).unit(jj).ppc...
%             = zeros(num_bands, num_epochs, num_behaviors);
%         channels(ii).unit(jj).firing_rate...
%             = zeros(num_bands, num_epochs, num_behaviors);
        for band_num = 1:num_bands
            band_name = defined_bands{band_num};
            assert(lfp_fs == 1000)
            assert(all(spike_times == all_channels(ii).unit_waveforms(jj).timestamp))
            assert(all(band_angles{band_num} == angle(hilbert(all_channels(ii).mid_beta))))
            %band_spike_angles = spike_field_angle(spike_times,...
            %    band_angles{band_num}, lfpfs);
            band_spike_angles = OLD_spike_field_angle( spike_times,...
                band_signals{band_num}, lfp_times);
            ii
            jj
            assert(all(band_spike_angles == all_channels(ii).unit_waveforms(jj).spike_angles))
            assert(all(spike_times == all_channels(ii).unit_waveforms(jj).timestamp))
            for kk = 1:num_epochs
                epoch_name = defined_epochs{kk};
                epoch_func = these_definitions.epochs.(epoch_name);
                epoch_time = epoch_func(broadcast_beh(:,:,ii));
                assert(size(epoch_time, 1) == 391)
                for ll = 1:num_behaviors
%                     ii
%                     jj
%                     epoch_name
%                     ll
                    time = epoch_time(ll,:);
                    %old_time = all_channels(ii).behavior_spectra(ll).([epoch_name,'_sec']).time;
                    epoch_spike_dx = spike_times >= time(1)...
                        & spike_times < time(2);
                    %%%new_spike_times = spike_times(epoch_spike_dx);
                    %%%old_spike_times = all_channels(ii).unit_waveforms(jj)...
                    %%%    .regime_spike_times.([epoch_name, '_sec']){ll};
                    %%%assert(all(spike_times(epoch_spike_dx) == old_spike_times))
%                     channels(ii).unit(jj)...
%                         .firing_rate(band_num, kk, ll)...
%                         = sum(epoch_spike_dx) / .5;
                     epoch_spike_angles = band_spike_angles(epoch_spike_dx);
                     assert(all(epoch_spike_angles == all_channels(ii).unit_waveforms(jj).regime_spike_angles.([epoch_name, '_sec']){ll}))
%                     channels(ii).unit(jj).ppc(band_num, kk, ll)...
%                         = ppc_from_spike_angles(epoch_spike_angles);
                end
            end
        end
    end
end

                    
session.channel = channels;
            



