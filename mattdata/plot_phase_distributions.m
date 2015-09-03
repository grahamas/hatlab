function [resultants] = plot_phase_distributions( unit, dp_data, band_name, epoch_name_list )
%Also returns resultant vectors for each epoch

'plotting'

channel_number = unit.parent_channel.channel_number;
unit_number = unit.unit_number;

fn_no_ext = ['phase_distribution_', num2str(channel_number),'_',num2str(unit_number)];
fp_fig = [dp_data, 'phase_distribution/', fn_no_ext, '.fig'];
fp_png = [dp_data, 'phase_distribution/', fn_no_ext, '.png'];

set(0,'DefaultTextInterpreter','none'); 
figure
n_epochs = length(epoch_name_list);
subplot(1, n_epochs, 1);
for i_epoch = 1:n_epochs
    subplot(1, n_epochs, i_epoch);
    epoch_name = epoch_name_list{i_epoch};
    epoch_spike_angles = unit.compute_band_epoch_spike_angles(band_name, epoch_name);
    epoch_spike_angles = vertcat(epoch_spike_angles{:});
    epoch_spike_angles = mod(epoch_spike_angles, 2*pi);
    not_nan = ~isnan(epoch_spike_angles);
    [tout, rout] = rose(epoch_spike_angles,20);
    fprintf('%d / %d\n', sum(not_nan), length(not_nan))
    resultants(i_epoch) = mean(cos(epoch_spike_angles(not_nan)) + 1i * sin(epoch_spike_angles(not_nan)));
    [cart_x, cart_y] = pol2cart(angle(resultants(i_epoch)), abs(resultants(i_epoch)));
    polar(tout, rout/trapz(tout,rout))
    hold all
    compass(cart_x, cart_y, 'r')
    title(epoch_name)

end

narrow_cutoff = unit.parent_channel.parent_array.narrow_cutoff;
if unit.waveform_width < narrow_cutoff
    is_narrow = 1;
    width_str = 'NARROW';
else
    is_narrow = 0;
    width_str = 'BROAD';
end
resultants(n_epochs+1) = is_narrow;
suptitle(['Phase distributions by epoch, ', width_str, ' unit'])

saveas(gcf, fp_fig, 'fig')
saveas(gcf, fp_png, 'png')
close

end

