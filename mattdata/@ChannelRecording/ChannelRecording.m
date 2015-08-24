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
        end
    end
    
end

