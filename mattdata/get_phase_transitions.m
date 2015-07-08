function phase_transitions = get_phase_transitions( time, line )
% Returns an N x 2 matrix where (n, 1) is the time of the nth phase
% transition and (n, 2) is the phase transitioned into.

phase_transitions = [];

num_points = length(line);
cur_point = 1;

line_phase = phase(line);

if line_phase(1) == 0
   if line(1) >= line(2)
       cur_phase = 1;
   else
       cur_phase = 2;
   end
else
    if line(1) <= line(2)
        cur_phase = 3;
    else
        cur_phase = 4;
    end
end
phase_transitions = [1, cur_phase];
start_dx = 1;
prev_phase = cur_phase;
prev_point = 1;
cur_point = 2;

while cur_point <= num_points
   if line_phase(cur_point) == 0
       if line(cur_point) < line(prev_point)
           cur_phase = 1;
       else
           cur_phase = 2;
       end
   else
       if line(cur_point) > line(prev_point)
           cur_phase = 3;
       else
           cur_phase = 4;
       end
   end
   
   if prev_phase ~= cur_phase
       phase_transitions = [phase_transitions; time(prev_point), cur_phase];
   end
   prev_point = cur_point;
   cur_point = cur_point + 1;
   prev_phase = cur_phase;
end


end
