classdef ChannelRecording
    
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
    end
    
end

