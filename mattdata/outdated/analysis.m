
% This is very outdated, but gives an idea of how I conducted the analysis.
% In particular, note that the cutoff in narrow_width should vary depending
% on which dataset is being analyzed (the whole script should be a loop over
% the datasets.

ppc = columns.ppc;
n_spikes = columns.n_spikes;
valid = ~isnan(ppc) & (n_spikes > 2);
ppc = ppc(valid);

epoch = nominal(columns.epoch);
epoch = epoch(valid);

narrow_width = nominal(columns.width < 13);
narrow_width = narrow_width(valid);

firing_rate = columns.firing_rate(valid);
fast_firing = nominal(firing_rate > median(firing_rate));
rate = firing_rate > 20;

[p, tbl, stats, terms] = anovan(ppc, {epoch, narrow_width, fast_firing},...
    'varnames', {'epoch', 'narrow_width', 'fast_firing'}, 'model', 'interaction');
%[p, tbl, stats, terms] = anovan(ppc(rate), {epoch(rate), narrow_width(rate)},...
%    'varnames', {'epoch', 'narrow_width'}, 'model', 'interaction');
