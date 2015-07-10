function ppc = ppc_from_spike_angles( spike_angles )
%SPIKE_FIELD_PPC
%   Given
%           spike_angles: angles of spikes
%
% Computes pairwise phase consistency, based on Vinck et al, 2010.
%

num_spikes = length(spike_angles);

phase_dot = @(a1, a2) cos(a1) * cos(a2) + sin(a1) * sin(a2);

ppc = 0;
for ii = 1:num_spikes-1
    angle_i = spike_angles(ii);
    for jj = ii+1:num_spikes
        angle_j = spike_angles(jj);
        ppc = ppc + phase_dot(angle_i, angle_j);
    end
end

ppc = ppc * (2 / (num_spikes * (num_spikes - 1)));

end