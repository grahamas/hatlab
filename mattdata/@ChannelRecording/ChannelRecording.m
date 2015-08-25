classdef ChannelRecording < dynamicprops
    
    properties (Constant)
        band_property_prefix = 'LFP_band_';
    end
    
    properties (SetAccess = immutable)
        parent_array
        channel_number
        LFP
    end
    
    properties
        unit_list
    end
    
    methods
        function obj = ChannelRecording(parent_array, channel_number, LFP)
            obj.parent_array = parent_array;
            obj.channel_number = channel_number;
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
                ret_cell{i_unit} = fxn(obj.unit_list(i_unit));
            end
        end
        function compute_LFP_band(obj, band_name, band_cutoffs)
            new_property_name = [band_property_prefix, band_name];
            if ~isprop(new_property_name, obj)
                obj.addprop(new_property_name)
            end
            obj.(new_property_name) = bandpass_filt(obj.LFP, band_cutoffs);
        end
    end
end

