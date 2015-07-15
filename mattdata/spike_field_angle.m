function spike_angle = spike_field_angle( spike_times, field_angle, field_fs )
%SPIKE_FIELD_ANGLE
%   Given
%           spike_times: timestamps of spikes
%           field_angle:  local field angle
%           field_fs: sampling freq of LFP
%

field_step = 1/field_fs;
field_times = field_step:field_step:(length(field_angle)/field_fs);

% Here we compute spike angle
num_spikes = length(spike_times);
spike_angle = zeros(size(spike_times));
for ii = 1:num_spikes
    spike_time = spike_times(ii);
    next_field_dx = find(field_times >= spike_time, 1);
    if isempty(next_field_dx)
        break
    end
    prev_field_dx = next_field_dx - 1;
    spike_angle(ii) = phase_interpolation(field_times(prev_field_dx),...
        field_times(next_field_dx), field_angle(prev_field_dx),...
        field_angle(next_field_dx), spike_time);
end

end

