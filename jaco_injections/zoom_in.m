addpath(genpath('/home/grahams/chronux'))

layers_config

bands = psd_bands;
band_names = psd_band_names;

%%%%%%%%

for day_num = 1:length(day_list)
    file_name = file_name_list{day_num};
    good_chs = good_chs_list{day_num};
    windows = windows_list{day_num};
    
    base_name = [day_dir,file_name];
    spec_name = [base_name, spec_ext];
    if (exist(spec_name, 'file') == 2)
        load(spec_name);
    else
        save_spectrum_from_lfpmat(base_name, movingwin, params);
        load(spec_name);
    end

    good_specgram = squeeze(mean(S(:,:,goodchs),3));
    avgs = {};

    figure
    hold all
    for bandname = bandnames
        bn = bandname{:};
        band_freqs = bands.(bn);
        band_dx = band_freqs(1) <= f & f < band_freqs(2);
        band_lfp = good_specgram(:,band_dx);
        band_avg = squeeze(mean(band_lfp, 2));
        avgs.(bn) = band_avg;
        
        plot(t./60, smooth(log(band_avg),200));
    end
    
    legend(bandnames)
    xlabel('time (min)')
    ylabel('log power')
    saveas(gcf, [base_name,'_1panel.png'], 'png')
    saveas(gcf, [base_name,'_1panel.fig'], 'fig')
        

end
