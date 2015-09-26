% assuming we have delta_phase and delta_pd
% which we get from plot_and_parse_prefdir_vs_phase.m

all_delta_phase = [];
all_delta_pd = [];
all_epoch_name = {};

epoch_names = {'instruction_early', 'instruction_late', 'execution'};
n_epochs = length(epoch_names);

for i_epoch = 1:n_epochs
    epoch_name = epoch_names{i_epoch};
    this_delta_phase = delta_phase.(epoch_name);
    this_delta_pd = delta_pd.(epoch_name);
    this_epoch_name_col = repmat(categorical({epoch_name}), size(this_delta_phase));
    
    all_delta_phase = [all_delta_phase; this_delta_phase];
    all_delta_pd = [all_delta_pd; this_delta_pd];
    all_epoch_name = [all_epoch_name; this_epoch_name_col];
end

tbl = table(all_delta_pd, all_delta_phase, all_epoch_name,...
    'VariableNames', {'delta_d', 'delta_p', 'epoch'});

mdl = fitlm(tbl, 'delta_p ~ delta_d * epoch');
mdl2 = fitlm(tbl, 'delta_p ~ epoch');
mdl3 = fitlm(tbl, 'delta_p ~ delta_d');

x = ((mdl2.SSE - mdl.SSE) * (mdl2.DFE - mdl.DFE)) / (mdl.SSE / mdl.DFE);
1 - fcdf(x, mdl2.DFE - mdl.DFE, mdl.DFE)
    
