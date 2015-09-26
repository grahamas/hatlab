% This parses the structure returned by direction_phase_unit_pairs.m,
% plots the result, and puts the pairs into a better format (delta_pd
% and delta_phase) for use by a later script. NOTE THAT THEY ARE NOT
% SAVED. So to use the result of this script, the subsequent script
% must be called in the same job.
% The next script is analyze_prefdir_vs_phase_regressions.m

epochs = {'instruction_early', 'instruction_late', 'execution'};
%epochs = {'instruction_early'};
n_epochs = length(epochs);

get_mean_angles = @(resultant_angles) cellfun(@(angles)...
    angle(mean(cos(angles(~isnan(angles))) + 1i * sin(angles(~isnan(angles))))), resultant_angles);

ternary = @(cond, t, f) (cond .* t) + (~cond .* f);
diff_substitution = @(diff) ternary(diff < pi, diff, 2*pi - diff);
angle_diff = @(angle1, angle2) diff_substitution(abs(angle1-angle2));

delta_pd = {};
delta_phase = {};

for i_epoch = 1:n_epochs
    epoch = epochs{i_epoch};
    
    epoch_structs_and_cells = by_epoch.(epoch);
    only_structs_dx = cellfun(@isstruct, epoch_structs_and_cells);
    only_structs = {epoch_structs_and_cells{only_structs_dx}};
    
    finding_resnorms = vertcat(epoch_structs_and_cells{only_structs_dx});
    resnorms = [finding_resnorms.resnorms];
    resnorm_cutoff = median(resnorms);  
    
    n_channels = length(only_structs);
    
    this_delta_pd = [];
    this_delta_phase = [];
    
    for i_channel = 1:n_channels
        this_channel = only_structs{i_channel};
        good_resnorms = [this_channel.resnorms] < resnorm_cutoff;
        n_good = sum(good_resnorms);
        if n_good < 2
            continue
        end
        this_channel = this_channel(good_resnorms);
        phase_angles = {this_channel(:).resultant_angles};
        mean_phase_angles = get_mean_angles(phase_angles);
        pref_dirs = cellfun(@(beta) mod(beta(3), 2*pi), {this_channel(:).models});
        for i_good = 1:(n_good-1)
            phase_i = mean_phase_angles(i_good);%phase_angles{i_good};
            pref_i = pref_dirs(i_good);
            for j_good = (i_good+1):n_good
                phase_j = mean_phase_angles(j_good); %phase_angles{j_good};
                this_delta_pd = [this_delta_pd; angle_diff(pref_i, pref_dirs(j_good))];%repmat(angle_diff(pref_i, pref_dirs(j_good)), size(phase_j))];
                this_delta_phase = [this_delta_phase; angle_diff(phase_i, phase_j)];% bsxfun(angle_diff, phase_i, phase_j)];
            end
        end
    end
    scatter(this_delta_pd, this_delta_phase)
    title(epoch)
    ylim([0, pi])
    ylabel('Delta mean phase pref')
    xlabel('Delta prefered direction')
    xlim([0, pi])
    pause
    
    delta_pd.(epoch) = this_delta_pd;
    delta_phase.(epoch) = this_delta_phase;
    
end
    
    
        
