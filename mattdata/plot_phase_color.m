function plot_phase_color( phase_transitions, time, line )

% y = 0
% b = pi/2
% r = pi
% g = 3pi/2
colors = {'y', 'b', 'r', 'g'};
 
start_dx = 1;
phase = phase_transitions(1,2);
for t_num = 2:size(phase_transitions, 1)
    pt_time = phase_transitions(t_num, 1);
    new_phase = phase_transitions(t_num, 2);
   
    next_dx = find(time == pt_time, 1);
    plot(time(start_dx:next_dx), line(start_dx:next_dx), colors{phase})
    start_dx = next_dx;
    phase = new_phase;
end
plot(time(start_dx:end), line(start_dx:end), colors{phase})


end

