function [consistency, firing_rate, spike_width, epoch, band] = get_analysis_columns(session, definitions)

num_channels = length(session.channel);

num_bands = length(definitions.bands.list_all);

column_names = {'consistency', 'firing_rate', 'spike_width', 'epoch'};
num_columns = length(column_names);

% to_analyze(num_bands) = struct('consistency', [],...
%     'firing_rate', [],...
%     'spike_width', [],...
%     'epoch', []);

consistency = [];
firing_rate = [];
spike_width = [];
epoch = [];
band = [];

for ii = 1:num_channels
    channel = session.channel(ii);
    num_units = length(channel.unit);
    for jj = 1:num_units
        unit = channel.unit(jj);
        width = unit.width;
        if length(width) ~= 1
            fprintf('There is a problem!')
        end
        ppc = unit.ppc; % num_bands, num_epochs, num_behaviors
        unit_firing_rate = unit.firing_rate;
        num_epochs = size(ppc, 2);
        for kk = 1:num_bands
            for ll = 1:num_epochs
                this_consistency = squeeze(ppc(kk, ll, :));
                this_firing_rate = squeeze(unit_firing_rate(kk,ll,:));
                consistency = [consistency;
                    this_consistency];
                epoch = [epoch; 
                    repmat(definitions.epochs.list_all(ll), size(this_consistency))];
                firing_rate = [firing_rate;...
                    this_firing_rate];
                spike_width = [spike_width;...
                    repmat(width, size(this_consistency))]; 
                band = [band;
                    repmat(definitions.bands.list_all(kk), size(this_consistency))];
            end
        end
    end
end

% Removed firing rate because no effect
% tbl = table(consistency,'VariableNames', {'consistency'});
% tbl.narrow_waveform = nominal(narrow_waveform);
% tbl.epoch = nominal(epoch);
% 
% mdl = fitlm(tbl, 'interactions', 'ResponseVar', 'consistency')

% [p, tbl, stats, terms] = anovan(consistency, {firing_rate, spike_width,...
%     epoch}, 'varnames', {'firing_rate', 'spike_width', 'epoch'},...
%     'model', 'interaction');

end
