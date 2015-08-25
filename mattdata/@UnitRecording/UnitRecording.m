classdef UnitRecording < dynamicprops
    
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
    end
    
    methods (Static)
        width = trough_peak_width(waveforms)
    end
    
end

