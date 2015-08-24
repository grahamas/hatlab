classdef ArrayRecording
    %ARRAYRECORDING Abstracts interaction with units.
    
    properties (Constant)
        constructor_vars = {'fn_to_load_list',...
                'data_file_type'};
    end
    
    properties (SetAccess = immutable)
        LFP_fs
    end
    
    properties
        good_channels
        channel_list
    end
    
    methods
        function obj = ArrayRecording(dp_data)
            if(nargin > 0)
            % dp_data is the path to the data directory
            load([dp_data,'ArrayRecording_constructor_vars.m'],...
                obj.constructor_vars{:})
            load_function = ArrayRecording.get_load_function(data_file_type);
            load_function(dp_data, fn_to_load_list)
            end
        end
    end
    
    methods (Static)
        function load_function = get_load_function(data_file_type)
            load_function = str2function(['obj.LOAD_',data_file_type]);
        end
    end
    
end

