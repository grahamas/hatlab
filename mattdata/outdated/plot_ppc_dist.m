% As with other scripts referring to the "columns" variable, this script is
% outdated. However, I suspect there is no more recent script so I leave it
% to demonstrate how I generated the pcc distribution plots.

YLIM = 4;

ppc = columns.ppc;
valid_ppc = ~isnan(ppc) & (columns.n_spikes > 2);

epoch = nominal(columns.epoch);

width = columns.width;
narrow_width = width < 10;

n_epochs = length(epoch_name_list);
figure
subplot(2, n_epochs, 1)
for i_epoch = 1:n_epochs
    epoch_name = epoch_name_list{i_epoch};
    this_epoch = epoch == epoch_name;
    subplot(2, n_epochs, i_epoch)
    [f,x]=hist(ppc(valid_ppc & narrow_width & this_epoch),50);
    bar(x,f/trapz(x,f))
    ylim([0 YLIM])
    title(epoch_name)
    subplot(2, n_epochs, i_epoch + n_epochs)
    [f,x]=hist(ppc(valid_ppc & ~narrow_width & this_epoch),50);
    bar(x,f/trapz(x,f))
    ylim([0 YLIM])
end
subplot(2, n_epochs, 1)
ylabel('narrow')
subplot(2,n_epochs, n_epochs+1)
ylabel('wide')
    
    
    
