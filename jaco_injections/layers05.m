addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/';
file_names = {'20140505/J05052014001'};
%file_names = {'20140514/J20140514_M1Contra'};
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

bandnames={'delta','theta','alpha','beta', 'low_beta', 'low_mid_beta', 'mid_beta', 'high_beta','gamma'};

bands.delta = [1,4];
bands.theta = [4,8];
bands.alpha = [8,12];
bands.beta = [12,32];
bands.low_beta = [12,17];
bands.low_mid_beta = [17,22];
bands.mid_beta = [22,27];
bands.high_beta = [27,32];
bands.gamma = [32,maxpass];

params.Fs = 2000;
params.fpass = [0,maxpass];
params.trialave = 0;

movingwin = [1, .5];

%window_size = .1;
%step_size = .025;

windows = {[7,13.5], [14,19.5], [20,25.5], [26,35]};


%%%%%%%%

goodchs = goodchs05;

%%%%%%%%

for file_name = file_names
    name = file_name{:};
    base_name = [day_dir,name];
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
