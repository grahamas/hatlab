classdef UnitRecording
    
    properties (SetAccess = immutable)
        parent_channel
        waveform_width
        spike_times
    end
    
    methods
        function obj = UnitRecording(parent_channel, waveform_width, ...
                                     spike_times)
            obj.parent_channel = parent_channel;
            obj.waveform_width = waveform_width;
            obj.spike_times = spike_times;
        end
    end
    
end

