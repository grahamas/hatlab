layers_config

moving_win = round([.1, .01] * lfp_fs);
all_over_time = cell(length(date_list), 1);
all_time = cell(length(date_list),1);
for ii = 1:length(date_list)
    file_name = file_name_list{ii};
    good_chs = good_chs_list{ii};
    fprintf('On %s\n',file_name)
    base_name = [day_dir, file_name];
    phase_shifts_name = [base_name, phase_shifts_ext];
    
    load(phase_shifts_name);
    
    index_by = @(a,b) a(b);
    good_physical = arrayfun(@(a) any(a == good_chs),physical_mapping);
    good_physical_mask = @(a, plane)...
        index_by(a(physical_mapping(vertical_planes{plane}{1}, vertical_planes{plane}{2})),...
        good_physical(vertical_planes{plane}{1}, vertical_planes{plane}{2}));
    
    num_planes = length(vertical_planes);
    over_time = cell(num_planes, 1);
    time = cell(num_planes, 1);
    for plane_num = 1:num_planes
        fprintf('plane num: %d\n', plane_num);
        good_beta_angles = good_physical_mask(beta_lfp_angles, plane_num);
        fprintf('good channels: %d\n', length(good_beta_angles));
        [good_over_time, t] = phase_shift_over_time(good_beta_angles,...
            1, moving_win);
        this_plane = vertical_planes{plane_num};
        full_over_time = nan(length(this_plane{1}), length(this_plane{2}), length(t));
        full_over_time(repmat(good_physical(this_plane{1}, this_plane{2}), 1, 1, length(t))) = good_over_time;
        over_time{plane_num} = full_over_time;
        time{plane_num} = t;
    end
    all_over_time{ii} = over_time;
    all_time{ii} = time;
end

save([base_name, '_phase_shift_over_time_hr.mat'], 'all_over_time','time', '-v7.3')
