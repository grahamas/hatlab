function direction_phase_pairs = direction_phase_unit_pairs(channel, band_name, epoch_name)
    unit_list = channel.unit_list;
    n_units = length(unit_list);

    pref_dir_model_fun = @(b, x) b(1)+ b(2) .* cos(x - b(3));
    
    if (n_units < 2)
        direction_phase_pairs = struct('models', [], 'resnorms', [], 'firing_rates', [], 'resultant_angles', []);
        return
    end

    directions = (channel.parent_array.beh(:,8) - 1) * (pi/4);
    options = optimoptions('lsqcurvefit','Display','off');

    delta_preferred_direction = [];
    delta_mean_spike_angle = [];

    models = cell(n_units, 1);
    resnorms = cell(n_units, 1);
    firing_rates = cell(n_units, 1);
    resultant_angles = cell(n_units, 1);
    preferred_direction = cell(n_units, 1);

    for i_unit = 1:n_units
        unit = unit_list{i_unit};
        epoch_spike_angles = unit.compute_band_epoch_spike_angles(band_name, epoch_name);
        n_trials = length(epoch_spike_angles);
        firing_rate = zeros(n_trials, 1);
        resultant_angle = zeros(n_trials, 1);
        for trial = 1:n_trials
            trial_spike_angles = epoch_spike_angles{trial};
            firing_rate(trial) = length(trial_spike_angles);
            resultant_angle(trial) = angle(mean(cos(trial_spike_angles) + 1i * sin(trial_spike_angles)));
        end
        [beta, resnorm]  = lsqcurvefit(pref_dir_model_fun, ones(3,1), directions, firing_rate, [], [], options);

        models{i_unit} = beta;
        resnorms{i_unit} = resnorm;
        firing_rates{i_unit} = firing_rate;
        resultant_angles{i_unit} = resultant_angle;
    end

    %for i_unit = 1:(n_units-1)
    %    for j_unit = i_unit:n_units
    %    end
    %end

    direction_phase_pairs = struct('models', models, 'resnorms', resnorms, 'firing_rates', firing_rates, 'resultant_angles', resultant_angles);

end



            
