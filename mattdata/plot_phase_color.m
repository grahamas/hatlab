function plot_phase_color( phase_transitions, time, line )

% y = 0
% b = pi/2
% r = pi
% g = 3pi/2
colors = {'y', 'b', 'r', 'g'};
 
% num_points = length(line);
% cur_point = 1;
% 
% line_phase = phase(line);
% 
% if line_phase(1) == 0
%    if line(1) >= line(2)
%        cur_phase = 1;
%    else
%        cur_phase = 2;
%    end
% else
%     if line(1) <= line(2)
%         cur_phase = 3;
%     else
%         cur_phase = 4;
%     end
% end
% start_dx = 1;
% prev_phase = cur_phase;
% prev_point = 1;
% cur_point = 2;
% 
% while cur_point <= num_points
%    if line_phase(cur_point) == 0
%        if line(cur_point) < line(prev_point)
%            cur_phase = 1;
%        else
%            cur_phase = 2;
%        end
%    else
%        if line(cur_point) > line(prev_point)
%            cur_phase = 3;
%        else
%            cur_phase = 4;
%        end
%    end
%    
%    if prev_phase ~= cur_phase
%        plot(time(start_dx:cur_point), line(start_dx:cur_point),...
%            colors{prev_phase})
%        start_dx = cur_point;
%    end
%    prev_point = cur_point;
%    cur_point = cur_point + 1;
%    prev_phase = cur_phase;
% end
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

