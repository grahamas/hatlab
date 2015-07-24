
if exist('band', 'var')
    band_select = strcmp(band,TARGET_BAND);
else
    band_select = ones(size(consistency));
end
not_isnan = ~isnan(consistency);
select = not_isnan & band_select;
narrow_width = spike_width < 10;

[p, tbl, stats, terms] = anovan(consistency(select),...
    {narrow_width(select), nominal(epoch(select))},...
    'varnames', {'narrow_width', 'epoch'},...
    'model', 'interaction');
    
