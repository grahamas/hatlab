function spike_angle = spike_field_angles( spike_times, field, field_times )
%SPIKE_FIELD_PPC
%   Given
%           spike_times: timestamps of spikes
%           field:  local field potential
%           field_times: timestamps indexically related to field,
%               temporally to spikes
%
% Computes pairwise phase consistency, based on Vinck et al, 2010.
%


% If there are problems, maybe no angle?
field_angle = angle(hilbert(field));

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

