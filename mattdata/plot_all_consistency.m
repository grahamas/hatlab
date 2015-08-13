% plots of consistency data

not_isnan = ~isnan(consistency) & (firing_rate > 4);

all_epochs = definitions.epochs.list_all;
num_epochs = length(all_epochs);

narrow_width = spike_width < 10;

epoch_narrow_x = [];
epoch_wide_x = [];
consistency_narrow_y = [];
consistency_wide_y = [];

figure
hold on

subplot(2,3,1)

for epoch_num = 1:num_epochs
    this_epoch = [all_epochs{epoch_num}, '_sec'];
    is_this_epoch = cellfun(@(e) strcmp(e, this_epoch), epoch);
    narrow_consistency = consistency(is_this_epoch & not_isnan & narrow_width);
    wide_consistency = consistency(is_this_epoch & not_isnan & ~narrow_width);
    
    epoch_narrow_x = [epoch_narrow_x; ones(size(narrow_consistency)) * epoch_num];
    consistency_narrow_y = [consistency_narrow_y; narrow_consistency];
    
    epoch_wide_x = [epoch_wide_x; ones(size(wide_consistency)) * epoch_num];
    consistency_wide_y = [consistency_wide_y; wide_consistency];
    
    subplot(2,3,((epoch_num - 1) * 2) + 1)
    hist(narrow_consistency)
    subplot(2,3,((epoch_num - 1) * 2) + 2)
    hist(wide_consistency)
end
