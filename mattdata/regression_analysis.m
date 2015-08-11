
narrow_waveform = spike_width < 10;
fast_fire = firing_rate > median(firing_rate);
% Removed firing rate because no effect
tbl = table(consistency,'VariableNames', {'consistency'});
tbl.narrow_waveform = nominal(narrow_waveform);
tbl.epoch = nominal(epoch);

%mdl = fitlm(tbl, 'interactions', 'ResponseVar', 'consistency')-


if exist('single_band', 'var')
    this_band_dx = cellfun(@(a) strcmp(a,single_band), band) & fast_fire;
    [p, tbl, stats, terms] = anovan(consistency(this_band_dx), {nominal(narrow_waveform(this_band_dx)), nominal(epoch(this_band_dx))}, 'model', 'interaction', 'varnames', {'narrow_waveform', 'epoch'});%, 'fast_fire'});
    [epoch_p, epoch_tbl, epoch_stats, epoch_terms] = anovan(consistency(this_band_dx), {nominal(epoch(this_band_dx))}, 'varnames', {'epoch'});
elseif exist('band', 'var')
    [p, tbl, stats, terms] = anovan(consistency, {nominal(narrow_waveform), nominal(epoch), nominal(band), nominal(fast_fire)}, 'model', 'interaction', 'varnames', {'narrow_waveform', 'epoch', 'band', 'fast_fire'});
else
    [p, tbl, stats, terms] = anovan(consistency, {nominal(narrow_waveform), nominal(epoch), nominal(fast_fire)}, 'model', 'interaction', 'varnames', {'narrow_waveform', 'epoch', 'fast_fire'});
end
