classdef UnitRecording < dynamicprops
    
    properties (Constant)
        spike_angles_property_prefix = 'spike_angles_';
        epoch_ppcs_property_prefix = 'epoch_ppcs_';
    end
    
    properties (SetAccess = immutable)
        parent_channel
        spike_times
    end
    
    properties
        waveform_width = NaN;
    end
    
    methods
        function obj = UnitRecording(parent_channel, spike_times)
            obj.parent_channel = parent_channel;
            obj.spike_times = spike_times;
        end
        
        function set_waveform_width_from_all(obj,waveforms,all_spike_times,these_spike_times)
            obj.waveform_width = UnitRecording.trough_peak_width(waveforms(...
                ismember(all_spike_times, these_spike_times),:));
        end
        function spike_angles = compute_spike_angles(obj, band_name)
            channel = obj.parent_channel;
            band_angles = channel.get_band_angles(band_name);
            spike_angles = channel.field_interpolation(band_angles, obj.spike_times);
        end
        function epoch_ppcs = compute_band_epoch_ppcs(obj, band_name, epoch_name)
            epoch_spike_angles = obj.compute_band_epoch_spike_angles(band_name, epoch_name);
            epoch_ppcs = cellfun(@ppc_from_spike_angles, epoch_spike_angles);
        end
        function firing_rate = compute_epoch_firing_rate(obj, epoch_name)
            % This is basically a duplicate of the below function. There
            % must be a way to avoid duplication while still preserving
            % modularity...
            epoch_window_list = obj.parent_channel.parent_array.epoch_windows.(epoch_name);
            n_windows = size(epoch_window_list, 1);
            window_firing_rate_list = nan(n_windows, 1);
            for i_window = 1:n_windows
                window = epoch_window_list(i_window, :);
                windowed_spikes = (obj.spike_times >= window(1)) & (obj.spike_times < window(2));
                window_firing_rate_list(i_window) = length(windowed_spikes) / (window(2) - window(1));
            end
            firing_rate = mean(window_firing_rate_list);
        end
        function epoch_spike_angles = compute_band_epoch_spike_angles(obj, band_name, epoch_name)
           epoch_window_list = obj.parent_channel.parent_array.epoch_windows.(epoch_name);
           n_windows = size(epoch_window_list, 1);
           epoch_spike_angles = cell(n_windows, 1);
           for i_window = 1:n_windows
               window = epoch_window_list(i_window, :);
               epoch_spike_angles{i_window} = obj.window_spike_angles(band_name, window);
           end
        end
        function windowed_angles = window_spike_angles(obj, band_name, window)
            spike_angles = obj.get_spike_angles(band_name);
            window_dx = (obj.spike_times >= window(1)) & (obj.spike_times < window(2));
            windowed_angles = spike_angles(window_dx);
        end
            
    end
    
    %% GETTERS AND SETTERS
    methods
        function spike_angles = get_spike_angles(obj, band_name)
            spike_angles_property_name = obj.get_spike_angles_property_name(band_name);
            if ~isprop(obj,spike_angles_property_name)
                obj.addprop(spike_angles_property_name);
                obj.(spike_angles_property_name) = obj.compute_spike_angles(band_name);
            end
            spike_angles = obj.(spike_angles_property_name);
        end
        function set_spike_angles(obj, band_name, spike_angles)
            spike_angles_property_name = obj.get_spike_angles_property_name(band_name);
            if ~isprop(obj,spike_angles_property_name)
                obj.addprop(spike_angles_property_name);
            end
            obj.([obj.spike_angles_prefix, band_name]) = spike_angles;
        end
        function epoch_ppcs = get_band_epoch_ppcs(obj, band_name,epoch_name)
            epoch_ppcs_property_name = obj.get_epoch_ppcs_property_name(band_name,epoch_name);
            if ~isprop(obj,epoch_ppcs_property_name)
                obj.add_prop(epoch_ppcs_property_name);
                obj.(epoch_ppcs_property_name) = obj.compute_epoch_ppcs(band_name,epoch_name);
            end
            epoch_ppcs = obj.(epoch_ppcs_property_name);
        end
        function set_band_epoch_ppcs(obj, band_name, epoch_name, epoch_ppcs)
            epoch_ppcs_property_name = obj.get_epoch_ppcs_property_name(band_name,epoch_name);
            if ~isprop(obj,epoch_ppcs_property_name)
                obj.add_prop(epoch_ppcs_property_name);
            end
            obj.(epoch_ppcs_property_name) = epoch_ppcs;
        end
    end
    
    methods %%% THIS IS STUPID
        function pn = get_epoch_ppcs_property_name(obj,band_name,epoch_name) 
            pn = [obj.epoch_ppcs_property_prefix, band_name,'_', epoch_name];
        end
        function pn = get_spike_angles_property_name(obj,band_name)
            pn = [obj.spike_angles_property_prefix, band_name];
        end
    end
    
        
    %% STATIC
    methods (Static)
        width = trough_peak_width(waveforms)
    end
    
end

