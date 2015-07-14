load('analysis_columns.mat')
% 'epoch', 'spike_width', 'firing_rate', 'consistency'

is_narrow = spike_width < 10;
is_number = ~isnan(consistency);

regimes = {'before_start','instruction_early_sec', 'instruction_late_sec', 'execution_sec'};
regime_markers = {'o', 'x', '^', 'd'};

num_points = length(consistency);
num_regimes = length(regimes);

figure
hold all

for kk = num_regimes
    this_regime = regimes{kk};
    is_regime = cellfun(@(reg) strcmp(reg, this_regime), epoch);
    
    narrow_regime = is_narrow & is_regime & is_number;
    wide_regime = (~is_narrow) & is_regime & is_number;
    
    scatter(firing_rate(narrow_regime), consistency(narrow_regime), regime_markers{kk}, 'r')
    scatter(firing_rate(wide_regime), consistency(wide_regime), regime_markers{kk}, 'b')
end

saveas(gcf, 'grand_scatter.fig')
saveas(gcf, 'grand_scatter.png')
    
