classdef StandardBands < Bands
    
    enumeration
        delta   (1, 4)
        theta   (4, 8)
        alpha   (8, 12)
        beta    (12, 32)
        gamma   (32, 55)
    end
    methods
        function obj = StandardBands(start, stop)
            obj@Bands(start,stop);
        end
    end
    
end

