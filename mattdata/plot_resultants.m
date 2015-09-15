
config

n_data_dirs = length(dn_data_list);


for i_data_dir = 1:n_data_dirs
    dn_data = dn_data_list{i_data_dir};
    dp_data = [dp_data_root, dn_data];
    fp_resultants = [dp_data, 'resultants_max_beta.mat'];
    
    load(fp_resultants);
    
    figure
    n_epochs = length(epoch_name_list);
    is_narrow = logical(resultants(:,n_epochs+1));
    subplot(2, n_epochs, 1);
    for i_epoch = 1:n_epochs
        subplot(2, n_epochs, i_epoch)
        [t, r] = rose(angle(resultants(is_narrow,i_epoch)));
        polar(t, r/trapz(t,r))
        title(epoch_name_list(i_epoch))
        subplot(2, n_epochs, n_epochs + i_epoch)
        [t, r] = rose(angle(resultants(~is_narrow,i_epoch)));
        polar(t, r/trapz(t,r))    
    end
    subplot(2, n_epochs, 1);
    ylabel('Narrow')
    subplot(2, n_epochs, n_epochs+1);
    ylabel('Broad')
    suptitle(dn_data)
    saveas(gcf, [dp_data, 'resultants_max_beta_plotted.fig'])
    saveas(gcf, [dp_data, 'resultants_max_beta_plotted.png'])
end
