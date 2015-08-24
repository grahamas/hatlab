classdef BetaBands < Bands
    
    enumeration
        low_beta        (12, 17)
        low_mid_beta    (17, 22)
        mid_beta        (22, 27)
        high_beta       (27, 32)
    end
    methods
        function obj = BetaBands(start, stop)
            if nargin == 0
                start = NaN;
                stop = NaN;
            end
            obj = obj@Bands(start,stop);
        end
    end
    
end

