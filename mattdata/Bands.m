classdef Bands
    properties (SetAccess = immutable)
        start
        stop
    end
    methods
        function obj = Bands(start, stop)
            if nargin > 0
                obj.start = start;
                obj.stop = stop;
            end
        end
    end
end

