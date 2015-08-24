classdef ArrayRecording
    %ARRAYRECORDING Abstracts interaction with units.
    
    properties (Constant)
        constructor_vars = {'fn_to_load_list',...
                'data_file_type'};
    end
    
    properties (SetAccess = private)
        LFP_fs
        good_channel_nums
        beh % abbreviation for behavior matrix. Specific format called beh.
        channel_num2physical_map
    end
    
    properties
        channel_list
    end
    
    methods
        function obj = ArrayRecording(dp_data)
            if(nargin > 0)
            % dp_data is the path to the data directory
            run([dp_data,'ArrayRecording_constructor_vars.m'])%,...
               % obj.constructor_vars{:})
            obj.load_data(data_file_type, dp_data, fn_to_load_list);
            clear(obj.constructor_vars{:})
            end
        end
        function load_data(obj, data_file_type, dp_data, fn_to_load_list)
            % WOW THE HACKS
            eval(['obj.LOAD_',data_file_type,'(dp_data, fn_to_load_list)'])
        end
        function add_channel(obj, new_channel)
            obj.channel_list{end+1} = new_channel;
        end
        
    end        
    
end

