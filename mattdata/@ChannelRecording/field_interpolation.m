function interpolated_values = field_interpolation( obj, field, time_list )
% Using obj.LFP_time as reference

lin_interp = @(t1, t2, v1, v2, t) ((v2 - v1) * (t-t1)/(t2 - t1)) + v1;

interpolated_values = nan(size(time_list));
for i_time = 1:length(time_list)
    time = time_list(i_time);
    after_dx = find(time <= obj.LFP_time, 1);
    if isempty(after_dx)
        interpolated_values(i_time) = NaN;
        continue
    end
    before_dx = after_dx - 1;

    before_time = obj.LFP_time(before_dx);
    after_time = obj.LFP_time(after_dx);

    before_val = field(before_dx);
    after_val = field(after_dx);
    
    interpolated_values(i_time) = lin_interp(before_time, after_time,...
        before_val, after_val, time);
end

end

