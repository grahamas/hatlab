function resultants = plot_phase_distributions( unit, dp_data, band_name, epoch_name_list )
%Also returns resultant vectors for each epoch

channel_number = unit.parent_channel.channel_number;
unit_number = unit.unit_number;

fn_no_ext = ['phase_distribution_', num2str(channel_number),'_',num2str(unit_number)];
fp_fig = [dp_data, 'phase_distribution/', fn_no_ext, '.fig'];
fp_png = [dp_data, 'phase_distribution/', fn_no_ext, '.png'];

figure
n_epochs = length(epoch_name_list);
subplot(1, n_epochs, 1);
for i_epoch = 1:n_epochs
    subplot(1, n_epochs, i_epoch);
    epoch_name = epoch_name_list{i_epoch};
    epoch_spike_angles = unit.compute_band_epoch_spike_angles(band_name, epoch_name);
    epoch_spike_angles = vertcat(epoch_spike_angles{:});
    epoch_spike_angles = mod(epoch_spike_angles, 2*pi);
    [tout, rout] = rose(epoch_spike_angles,20);
    domain = (0:pi:(19*pi))./10;-
    hold on;
    polar(tout, rout/trapz(domain,rout))
    title(epoch_name)
    resultants(i_epoch) = mean(cos(epoch_spike_angles) + i * sin(epoch_spike_angles));
    compass(pol2cart(angle(resultants(i_epoch)), abs(resultants(i_epoch))), 'color', 'r')
end

narrow_cutoff = unit.parent_channel.parent_array.narrow_cutoff;
if unit.waveform_width < narrow_cutoff
    width_str = 'NARROW';
else
    width_str = 'BROAD';
end
suptitle(['Phase distributions by epoch, ', width_str, ' unit'])

saveas(gcf, fp_fig, 'fig')
saveas(gcf, fp_png, 'png')

end

