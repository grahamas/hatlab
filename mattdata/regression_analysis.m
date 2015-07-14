if ~exist('spike_width','var')
    load('analysis_columns.mat')
end

narrow_waveform = spike_width < 10;

% Removed firing rate because no effect
tbl = table(consistency,'VariableNames', {'consistency'});
tbl.narrow_waveform = nominal(narrow_waveform);
tbl.epoch = nominal(epoch);

mdl = fitlm(tbl, 'interactions', 'ResponseVar', 'consistency')
