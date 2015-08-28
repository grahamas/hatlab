
ppc = columns.ppc;
n_spikes = columns.n_spikes;
valid = ~isnan(ppc) & n_spikes > 2;
ppc = ppc(valid);

epoch = nominal(columns.epoch);
epoch = epoch(valid);

narrow_width = nominal(columns.width < 10);
narrow_width = narrow_width(valid);

firing_rate = columns.firing_rate(valid);
fast_firing = nominal(firing_rate > median(firing_rate));

[p, tbl, stats, terms] = anovan(ppc, {epoch, narrow_width, fast_firing},...
    'varnames', {'epoch', 'narrow_width', 'fast_firing'}, 'model', 'interaction');
