function output_value = phase_interpolation( t1, t2, v1, v2, t )
% Interpolate phase. Assumes phase to be monotonically increasing. Note
% also that t2 > t1.

lin_interp = @(t1, t2, v1, v2, t) ((v2 - v1) * (t-t1)/(t2 - t1)) + v1;

% Account for edge case where we are instantaneously moving from pi to -pi
if v2 < v1
    if t - t1 < t2 - t
        output_value = v1;
        return
    else
        output_value = v2;
        return
    end
else
    output_value = lin_interp(t1, t2, v1, v2, t);
    return
end


end

