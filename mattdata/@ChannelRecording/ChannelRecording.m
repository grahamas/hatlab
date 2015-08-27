classdef ChannelRecording < dynamicprops
    
    properties (Constant)
        band_property_prefix = 'LFP_band_';
        angles_property_prefix = ['LFP_band_', 'angles_'];
    end
    
    properties (SetAccess = immutable)
        parent_array
        channel_number
        LFP
        LFP_time
    end

    properties
        unit_list
    end
    
    methods
        function obj = ChannelRecording(parent_array, channel_number, LFP)
            obj.parent_array = parent_array;
            obj.channel_number = channel_number;
            LFP_fs = parent_array.LFP_fs;
            obj.LFP_time = 0:(1/LFP_fs):((length(LFP)-1)/LFP_fs);
            obj.LFP = LFP;
            obj.unit_list = [];
        end
        function add_unit(obj, new_unit)
            obj.unit_list{end+1} = new_unit;
        end
        function ret_cell = map_over_units(obj, fxn)
            n_units = length(obj.unit_list);
            ret_cell = cell(n_units, 1);
            for i_unit = 1:n_units
                ret_cell{i_unit} = fxn(obj.unit_list{i_unit});
            end
        end
        function for_all_units(obj, fxn)
            n_units = length(obj.unit_list);
            for i_unit = 1:n_units
                fxn(obj.unit_list(i_unit));
            end
        end
        function band = compute_band(obj, band_name)
            band_cutoffs = obj.parent_array.band_cutoffs.(band_name);
            band = bandpass_filt(obj.LFP, band_cutoffs);
        end
        function band_angles = compute_band_angles(obj, band_name)
            band_angles = unwrap(angle(hilbert(obj.get_band(band_name))));
        end
    end
    
    %% GETTERS AND SETTERS
    methods
        function band = get_band(obj, band_name)
            band_property_name = obj.get_band_property_name(band_name);
            if ~isprop(band_property_name, obj)
                obj.addprop(band_property_name);
                obj.(band_property_name) = ...
                    obj.compute_band(band_name);
            end
            band = obj.(band_property_name);
        end
        function angles = get_band_angles(obj, band_name)
            angles_property_name = obj.get_angles_property_name(band_name);
            if ~isprop(angles_property_name, obj)
                obj.addprop(angles_property_name);
                obj.(angles_property_name) = obj.compute_band_angles(band_name);
            end
            angles = obj.(angles_property_name);
        end
        function set_band(obj, band_name, band)
            band_property_name = obj.band_property_name(band_name);
            if ~isprop(band_property_name, obj)
                obj.addprop(band_property_name);
            end
            obj.(band_property_name) = band;
        end
        function set_band_angles(obj, band_name, band_angles)
            angles_property_name = obj.get_angles_property_name(band_name);
            if ~isprop(angles_property_name, obj)
                obj.addprop(angles_property_name);
            end
            obj.(angles_property_name) = band_angles;
        end
    end
    
    methods %%% THIS IS STUPID
        function pn = get_band_property_name(obj, band_name)
            pn = [obj.band_property_prefix, band_name];
        end
        function pn = get_angles_property_name(obj, band_name) 
            pn = [obj.angles_property_prefix, band_name];
        end
    end
end

