function resultants = plot_phase_distributions( unit, dp_data, band_name, epoch_name_list )
%Also returns resultant vectors for each epoch

channel_number = unit.parent_channel.channel_number;
unit_number = unit.unit_number;

fn_no_ext = ['phase_distribution_', num2str(channel_number),'_',num2str(unit_number)];
fn_fig = [fn_no_ext, '.fig'];
fn_png = [fn_no_ext, '.png'];

figure
n_epochs = length(epoch_name_list);
subplot(1, n_epochs, 1);
for i_epoch = 1:n_epochs
    
end
suptitle['Phase distributions by epoch, 

end

