function [return_phase_shifts_over_time,bin_times] = phase_shift_over_time( angles, ref_dx, moving_win )
% Assumes angles is a cell.

window_width = moving_win(1);
window_step = moving_win(2);

num_units = length(angles);
num_angles = length(angles{end});

ref_angles = angles{ref_dx};

window_ends = window_width:window_step:num_angles;
num_windows = length(window_ends);

return_phase_shifts_over_time = zeros(num_windows,num_units);
bin_times = zeros(num_windows, 1);

for ii = 1:num_windows
    window_end = window_ends(ii);
    window_start = window_end - window_width + 1;
    window = window_start:window_end;
    bin_times(ii) = (window_end + window_start) / 2;
    
    ref_window = ref_angles(window);
    
    return_phase_shifts_over_time(ii,:) = cellfun(...
        @(a) phase_difference(a(window), ref_window),...
        angles, 'UniformOutput', 1);
end


end

