function ppc = spike_field_ppc( spike_times, field, field_times )
%SPIKE_FIELD_PPC
%   Given
%           spike_times: timestamps of spikes
%           field:  local field potential
%           field_times: timestamps indexically related to field,
%               temporally to spikes
%
% Computes pairwise phase consistency, based on Vinck et al, 2010.
%

% Linearly interpolate the value at t given values v2 and v1 at times t2
% and t1 respectively (t2 > t1?)
lin_interp = @(t1, t2, v1, v2, t) ((v2 - v1) * (t-t1)/(t2 - t1)) + v1;
phase_dot = @(a1, a2) cos(a1) * cos(a2) + sin(a1) * sin(a2);

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
    spike_angle(ii) = lin_interp(field_times(prev_field_dx),...
        field_times(next_field_dx), field_angle(prev_field_dx),...
        field_angle(next_field_dx), spike_time);
end

ppc = 0;
for ii = 1:num_spikes-1
    angle_i = spike_angle(ii);
    for jj = ii+1:num_spikes
        angle_j = spike_angle(jj);
        ppc = ppc + phase_dot(angle_i, angle_j);
    end
end

ppc = ppc * (2 / (num_spikes * (num_spikes - 1)));

end

