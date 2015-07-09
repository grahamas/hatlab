
num_channels = length(all_channels);

lfp_fs = 1000;
global_moving_win = [2, .1];
local_moving_win = [.1, .01];
params = struct('Fs', lfp_fs, 'tapers', [3 5], 'fpass', [0 80]);

relevant_behaviors = [1, 3, 4, 5, 6, 7, 8];
relevant_beh = beh(:, relevant_behaviors) * lfp_fs;
num_behaviors = size(beh, 1);
before_start = 2 * lfp_fs;
after_reward = .5 * lfp_fs;

for ii = 1:num_channels
    if isempty(all_channels(ii).unit)
        continue
    end
    units = all_channels(ii).unit;
    num_units = length(units);
    for jj = 1:num_units
        unit_dx = units(jj);
        tp_width = trough_peak_width(unit_waveforms(unit_dx).waveform);
        unit_waveforms(unit_dx).width = tp_width;
    end
    %[S, t, f] = mtspecgramc(all_channels(ii).lfp, global_moving_win, params);
    %all_channels(ii).lfp_spectrum = S;
    %all_channels(ii).lfp_spectrum_t = t;
    %all_channels(ii).lfp_spectrum_f = f;
    lfp = all_channels(ii).lfp;
    behavior_spectra = repmat(struct('before', {},...
        'delay', {}, 'go', {}, 'movement', {},...
        'after_reward', {}, 'gross', {}), 1, num_behaviors);
    for jj = 1:num_behaviors
        this_behavior = relevant_beh(jj, :);
        this_behavior = arrayfun(@round, this_behavior);
        
        before_time = (this_behavior(1)-before_start):this_behavior(1);
        %before_lfp = lfp(before_time);
        %behavior_spectra(jj).before = spectra_struct(before_lfp, local_moving_win, params);
        behavior_spectra(jj).before.time = before_time;

%         start_lfp = lfp(this_behavior(1):this_behavior(2));
%         behavior_spectra(jj).start = spectra_struct(start_lfp, local_moving_win, params);
        
        delay_time = this_behavior(2):this_behavior(3);
        %delay_lfp = lfp( delay_time );
        %behavior_spectra(jj).delay = spectra_struct(delay_lfp, local_moving_win, params);
        behavior_spectra(jj).delay.time = delay_time;
        
        go_time = this_behavior(3):this_behavior(4);
        %go_lfp = lfp(go_time);
        %behavior_spectra(jj).go = spectra_struct(go_lfp, local_moving_win, params);
        behavior_spectra(jj).go.time = go_time;
        
        movement_time = this_behavior(4):this_behavior(5);
        %movement_lfp = lfp(movement_time);
        %behavior_spectra(jj).movement = spectra_struct(movement_lfp, local_moving_win, params);
        behavior_spectra(jj).movement.time = movement_time;
        
%         reward_wait_lfp = lfp(this_behavior(5):this_behavior(6));
%         behavior_spectra(jj).after = spectra_struct(reward_wait_lfp, local_moving_win, params);
        
        after_reward_time = this_behavior(6):min((this_behavior(6)+after_reward), length(lfp));
        %after_reward_lfp = lfp(after_reward_time);
        %behavior_spectra(jj).after_reward = spectra_struct(after_reward_lfp, local_moving_win, params);
        behavior_spectra(jj).after_reward.time = after_reward_time;
        
        gross_time = (this_behavior(1)-before_start) :...
            min(this_behavior(6)+after_reward,length(lfp));
        gross_lfp = lfp( gross_time );
        %behavior_spectra(jj).gross = mt_struct(gross_lfp, local_moving_win, params);
        behavior_spectra(jj).gross.time = gross_time;
        
        mid_beta = mid_beta_filt(gross_lfp);
        behavior_spectra(jj).mid_beta = mid_beta;
        behavior_spectra(jj).mid_beta_pt = get_phase_transitions(gross_time, mid_beta);
        
        behavior_spectra(jj).direction = this_behavior(7)/1000;
    end
    all_channels(ii).behavior_spectra = behavior_spectra;
        
end
    
        