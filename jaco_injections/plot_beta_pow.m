layers_config


for date_num = 1:length(date_list)

    file_name = file_name_list{date_num};
    good_chs = good_chs_list{date_num};
    windows = windows_list{date_num};
    num_windows = length(windows);

    is_good_ch = @(ch) any(ch == good_chs);

    base_name = [day_dir, file_name];
    lfp_name = [base_name, lfp_ext];
    spec_name = [base_name, spec_ext];
    if exist(spec_name, 'file')
        load(spec_name)
    else
        fprintf('SPECTRUM NOT LOADED.\n')
        fprintf('BACKUP PLAN NOT IMPLEMENTED.\n')
        load(lfp_name);
        lfp_mat = cell2mat(lfpdeci); % channels x samples
        num_chans = size(lfp_mat, 1);
    end

    num_chans = size(S,3); % S comes from spec_name file
    %time = (1/lfp_fs):(1/lfp_fs):(size(lfp_mat,2)/lfp_fs);

    beta_mat = nan(num_chans,length(t));
    beta_mat(good_chs, :) = band_from_spec(S(:,:,good_chs).^2,f,bands.beta);

    window_dx_list = cell(num_windows, 1);
    for w_num = 1:num_windows
        window_sec = windows{w_num} * 60;
        window_dx_list{w_num} = window_sec(1) <= t & t < window_sec(2);
    end
    
    fprintf('beta layer\n') 
    beta_layer_mat = zeros(num_layers, length(t));
    for l_num = 1:num_layers
        this_layer = physical_mapping(l_num, :);
        good_layer_dx = this_layer(arrayfun(is_good_ch, this_layer));
        beta_layer_mat(l_num,:) = smooth(log10(mean(beta_mat(good_layer_dx,:),1)),200);
    end
    colors = jet(8);
    fprintf('plotting\n')
    figure
    subplot(1,num_windows,1)
    for w_num = 1:num_windows
        subplot(1, num_windows, w_num)
        hold all
        window_dx = window_dx_list{w_num};
        for l_num = 1:num_layers
            plot(t(window_dx)./60,beta_layer_mat(l_num,window_dx),...
                'color', colors(l_num,:)); % t from mtspecgramc
        end
        window = windows{w_num};
        xlim([min(t(window_dx)),max(t(window_dx))]./60) % t from mtspecgramc
    end
    fprintf('done plotting.\n')
    legend({'1','2','3','4','5','6','7','8(deep)'})
    subplot(1,num_windows,1)
    xlabel('t (minutes)')
    ylabel('log power')
    fprintf('saving...\n')
    saveas(gcf, [base_name, betapowfig_ext])
    saveas(gcf, [base_name, betapowpng_ext])
    fprintf('saved!\n')

end

           

