classdef ChannelRecording < dynamicprops
    
    properties (Constant)
        band_property_prefix = 'LFP_band_';
        band_timeseries_suffix = '_timeseries';
    end
    
    properties (SetAccess = immutable)
        parent_array
        channel_number
        LFP_timeseries
    end
    
    properties (Dependent)
        LFP
    end

    properties
        unit_list
    end
    
    methods
        function obj = ChannelRecording(parent_array, channel_number, LFP)
            obj.parent_array = parent_array;
            obj.channel_number = channel_number;
            LFP_fs = parent_array.LFP_fs;
            LFP_time = 0:(1/LFP_fs):((length(LFP)-1)/LFP_fs);
            obj.LFP_timeseries = timeseries(LFP, LFP_time);
            obj.LFP_timeseries.TimeInfo.Units = 'seconds';
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
            new_property_name = [obj.band_property_prefix, band_name];
            new_timeseries_name = [new_property_name, obj.band_timeseries_suffix];
            if ~isprop(new_property_name, obj)
                obj.addprop(new_property_name);
                obj.addprop(new_timeseries_name);
            end
            new_data = bandpass_filt(obj.LFP, band_cutoffs);
            new_timeseries = timeseries(new_data, obj.LFP_timeseries.Time);
            new_timeseries
        end
    end

    methods
        function data = get.LFP(obj)
            data = LFP_timeseries.Data
        end
    end
end

