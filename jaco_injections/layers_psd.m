addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/';
%file_names = {'20140505/J05052014001', 
file_names = {'20140514/J20140514_M1Contra'};
% Note that J05052014002 is too short

%file_names = {'20140514/J20140514_M1Contra'};

lfp_ext = '_LFP.mat';
spec_ext = '_spec.mat';

bpowfig_ext = '_bandpow.fig';
bpowpng_ext = '_bandpow.png';

npowfig_ext = '_nodeltapow.fig';
npowpng_ext = '_nodeltapow.png';

lpowfig_ext = '_logpow.fig';
lpowpng_ext = '_logpow.png';

betapowfig_ext = '_betapow.fig';
betapowpng_ext = '_betapow.png';

maxpass = 55;

ARB_CH = 3;

%layers = [5, 13, 23, 27, 37, 45, 55, 59;...
%          4, 12, 18, 28, 36, 44, 50, 60;...
%          6, 14, 22, 32, 38, 46, 54, 64;...
%          3, 11, 19, 29, 35, 43, 51, 61;...
%          7, 15, 21, 31, 39, 47, 53, 63;...
%          2, 10, 20, 24, 34, 42, 52, 56;...
%          8, 17, 26, 30, 40, 49, 58, 62;...
%          1, 9, 16, 25, 33, 41, 48, 57];
layers = [2, 4, 30, 17, 34, 36, 62, 49;...
          13, 3, 29, 31, 45, 35, 61, 63;...
          6, 8, 27, 32, 38, 40, 59, 64;...
          1, 7, 28, 26, 33, 39, 60, 58;...
          14, 12, 19, 25, 46, 44, 51, 57;...
          5, 15, 24, 18, 37, 47, 56, 50;...
          10, 16, 23, 21, 42, 48, 55, 53;...
          9, 11, 20, 22, 41, 43, 52, 54];

goodchs14 = [9:31, 39:63];
goodchs05 = [3:32, 35:64];

bandnames={'delta','theta','alpha','beta','gamma'};

bands.delta = [1,4];
bands.theta = [4,8];
bands.alpha = [8,12];
bands.beta = [12,32];
bands.gamma = [32,maxpass];

params.Fs = 2000;
params.fpass = [0,maxpass];
params.trialave = 0;

movingwin = [1, .5];

%window_size = .1;
%step_size = .025;

windows = {[7,13.5], [14,19.5], [20,25.5], [26,35]};


%%%%%%%%

goodchs = goodchs14;

is_good = @(ch) any(ch == goodchs);

%%%%%%%%

for file_name = file_names
    name = file_name{:};
    base_name = [day_dir,name];
    lfp_name = [base_name, lfp_ext];
    
    load(lfp_name)
    lfpmat = cell2mat(lfpdeci)'; % samples x channels


    [Pxx, F] = periodogram(lfpmat);

    'calculating psd...'

    layer_psd = {};
    for l_num = 1:8
        this_layer = layers(l_num, :);
        good_layer = this_layer(arrayfun(is_good, this_layer));
        for w_num = 1:4
            window = windows{w_num};
            window_dx = (window(1)*60*2000):min(window(2)*60*2000,size(lfpmat,1));
            [Pxx, F] = periodogram(lfpmat(window_dx, good_layer),[],[],2000);%,'ConfidenceLevel',.95);
            layer_psd{l_num}{w_num}.Pxx = squeeze(mean(Pxx,2));
            layer_psd{l_num}{w_num}.F = F;
            %layer_psd{l_num}{w_num}.Pxxc = squeeze(mean(Pxxc,));
        end
    end
    
    'done calculating'
    colors = jet(8);

    figure
    for w_num = 1:4
        subplot(1,4,w_num);
        hold all;
        for l_num = 1:8
           plot(layer_psd{l_num}{w_num}.F, smooth(10*log10(layer_psd{l_num}{w_num}.Pxx),5000),'Color', colors(l_num,:))
        end 
        xlim([0,maxpass])
        ylim([0,80])
    end
    legend({'1','2','3','4','5','6','7','8(deep)'})
    subplot(1,4,1)
    xlabel('f')
    ylabel('log power')
    saveas(gcf, [base_name,'_layers_psd.png'],'png')
    saveas(gcf, [base_name,'_layers_psd.fig'],'fig')
    
end
