addpath(genpath('/home/grahams/chronux'))
layers_config

%%%%%%%%

band_names = psd_band_names;
bands = psd_bands;

%%%%%%%%

for day_num = 1:length(date_list)

    file_name = file_name_list{day_num};
    good_chs = good_chs_list{day_num};
    windows = windows_list{day_num};

    is_good = @(ch) any(ch == good_chs);

    % Printing for tracking purposes
    fprintf('\nOn %s\n',file_name)

    base_name = [day_dir,file_name];
    lfp_name = [base_name, lfp_ext];
    
    load(lfp_name)
    lfpmat = cell2mat(lfpdeci)'; % samples x channels


    [Pxx, F] = periodogram(lfpmat);

    fprintf('calculating psd...')

    layer_psd = {};
    for l_num = 1:8
        this_layer = physical_mapping(l_num, :);
        good_layer = this_layer(arrayfun(is_good, this_layer));
        for w_num = 1:4
            window = windows{w_num};
            window_dx = (window(1)*60*lfp_fs):min(window(2)*60*lfp_fs,size(lfpmat,1));
            [Pxx, F] = periodogram(lfpmat(window_dx, good_layer),[],[],2000);%,'ConfidenceLevel',.95);
            layer_psd{l_num}{w_num}.Pxx = squeeze(mean(Pxx,2));
            layer_psd{l_num}{w_num}.F = F;
            %layer_psd{l_num}{w_num}.Pxxc = squeeze(mean(Pxxc,));
        end
    end
    
    fprintf(' done calculating.\n')
    colors = jet(8);

    figure
    for w_num = 1:4
        subplot(1,4,w_num);
        hold all;
        for l_num = 1:8
           plot(layer_psd{l_num}{w_num}.F, smooth(10*log10(layer_psd{l_num}{w_num}.Pxx),5000),'Color', colors(l_num,:))
        end 
        xlim([0,MAX_PASS])
        ylim([0,80])
    end
    legend({'1','2','3','4','5','6','7','8(deep)'})
    subplot(1,4,1)
    xlabel('f')
    ylabel('log power')
    saveas(gcf, [base_name,'_layers_psd.png'],'png')
    saveas(gcf, [base_name,'_layers_psd.fig'],'fig')
    
end
