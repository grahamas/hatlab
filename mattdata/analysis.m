
ppc = columns.ppc;
valid = ~isnan(ppc);
ppc = ppc(valid);

epoch = nominal(columns.epoch);
epoch = epoch(valid);
narrow_width = nominal(columns.width < 10);
narrow_width = narrow_width(valid);

[p, tbl, stats, terms] = anovan(ppc, {epoch, narrow_width},...
    'varnames', {'epoch', 'narrow_width'}, 'model', 'interaction');
