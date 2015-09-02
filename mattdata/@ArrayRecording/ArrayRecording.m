classdef ArrayRecording < dynamicprops
    %ARRAYRECORDING Abstracts interaction with units.
    
    properties (Constant)
        constructor_vars = {'fn_to_load_list',...
                'data_file_type'};
    end
    
    properties
        LFP_fs
        beh % abbreviation for behavior matrix. Specific format called beh.
        channel_num2physical_map
        channel_list
        band_cutoffs
        epoch_windows
        narrow_cutoff
    end
    
    methods
        function obj = ArrayRecording(dp_data)
            if(nargin > 0)
            % dp_data is the path to the data directory
            run([dp_data,'ArrayRecording_constructor_vars.m'])%,...
               % obj.constructor_vars{:})
            obj.load_data(data_file_type, dp_data, fn_to_load_list);
            end
        end
        function load_data(obj, data_file_type, dp_data, fn_to_load_list)
            % WOW THE HACKS
            eval(['obj.LOAD_',data_file_type,'(dp_data, fn_to_load_list)']);
        end
        function add_channel(obj, new_channel)
            obj.channel_list{end+1} = new_channel;
        end
        function ret_cell = map_over_channels(obj, fxn)
            n_channels = length(obj.channel_list);
            ret_cell = cell(n_channels, 1);
            for i_channel = 1:n_channels
                ret_cell{i_channel} = fxn(obj.channel_list{i_channel});
            end
        end
        function ret_cell = map_over_units(obj, fxn)
            n_channels = length(obj.channel_list);
            ret_cell = cell(n_channels, 1);
            for i_channel = 1:n_channels
                channel = obj.channel_list{i_channel};
                ret_cell{i_channel} = channel.map_over_units(fxn);
            end
            ret_cell = vertcat(ret_cell{:});
        end
        function for_all_channels(obj, fxn)
            n_channels = length(obj.channel_list);
            for i_channel = 1:n_channels
                fxn(obj.channel_list{i_channel});
            end
        end
        function parfor_all_channels(obj, fxn)
            n_channels = length(obj.channel_list);
            parfor i_channel = 1:n_channels
                fxn(obj.channel_list{i_channel});
            end
        end
        function for_all_units(obj, fxn)
            obj.for_all_channels(@(ch) ch.for_all_units(fxn));
        end
    end
end

