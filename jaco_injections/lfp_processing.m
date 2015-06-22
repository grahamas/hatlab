addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/';
file_names = {'20140505/J05052014001', '20140505/J05052014002',...
    '20140505/J05052014003', '20140514/J20140514_M1Contra'};
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

layers = [5, 13, 23, 27, 37, 45, 55, 59;...
          4, 12, 18, 28, 36, 44, 50, 60;...
          6, 14, 22, 32, 38, 46, 54, 64;...
          3, 11, 19, 29, 35, 43, 51, 61;...
          7, 15, 21, 31, 39, 47, 53, 63;...
          2, 10, 20, 24, 34, 42, 52, 56;...
          8, 17, 26, 30, 40, 49, 58, 62;...
          1, 9, 16, 25, 33, 41, 48, 57];


bandnames={'delta','theta','alpha','beta','gamma'};
bandnames_nodelta={'theta','alpha','beta','gamma'};

bands.delta = [1,4];
bands.theta = [4,8];
bands.alpha = [8,12];
bands.beta = [12,32];
bands.gamma = [32,maxpass];

params.Fs = 2000;
params.fpass = [0,maxpass];
params.trialave = 0;

movingwin = [1, .5];

window_size = 120;
step_size = .5;

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
    ch_band_aves = calc_band_aves(S, f, bands, bandnames);

    band_figs = {}
    for bandname = bandnames
        bn = bandname{:};
        band_figs.(bn) = figure
        title(['All ',bn,' for ',name])
        ylabel('log power')
        xlabel('time (min)')
    end

    h = figure
    set(h, 'Visible', 'off')
    for ch = 1:length(ch_band_aves)
        this_ch = ch_band_aves{ch};

        %hold all;
        %for bandname = bandnames
        %    bn = bandname{:};
        %    plot(t./60, this_ch.(bn))
        %end
        %hold off;
        %legend(bandnames)
        %xlabel('time (min)')
        %ylabel('power')
        %title([name,', Channel ',num2str(ch),' band powers'])
        %saveas(h,[base_name,'_',num2str(ch),bpowfig_ext],'fig')
        %saveas(h,[base_name,'_',num2str(ch),bpowpng_ext],'png')
        %clf(h)

        %hold all;
        %for bandname = bandnames_nodelta
        %    bn = bandname{:};
        %    plot(t./60, this_ch.(bn))
        %end
        %hold off;
        %legend(bandnames_nodelta)
        %xlabel('time (min)')
        %ylabel('power')
        %title([name,', Channel ',num2str(ch),' band powers'])
        %saveas(h,[base_name,'_',num2str(ch),npowfig_ext],'fig')
        %saveas(h,[base_name,'_',num2str(ch),npowpng_ext],'png')
        %clf(h)
        for bandname = bandnames
            bn = bandname{:}
            figure(band_figs.(bn));
            hold on
            plot(t./60, smooth(log(this_ch.(bn)),1000));
            xlim([9,13])
        end

        %hold all;
        %for bandname = bandnames
        %    bn = bandname{:};
        %    plot(t./60, smooth(log(this_ch.(bn)),1000))
        %end
        %hold off;
        %legend(bandnames)
        %xlabel('time (min)')
        %ylabel('log power')
        %title([name,', Channel ',num2str(ch),' log band powers'])
        %saveas(h,[base_name,'_',num2str(ch),lpowfig_ext],'fig')
        %saveas(h,[base_name,'_',num2str(ch),lpowpng_ext],'png')    
        %clf(h)

        %plot(t./60,this_ch.beta)
        %xlabel('time (min)')
        %ylabel('power')
        %ylim([0, 20000])
        %title([name,', Channel ',num2str(ch),' beta power'])
        %saveas(h,[base_name,'_',num2str(ch),betapowfig_ext],'fig')
        %saveas(h,[base_name,'_',num2str(ch),betapowpng_ext],'png')    
    end

    for bandname = bandnames
        bn = bandname{:};
        saveas(band_figs.(bn), [base_name,'_lim1_all',bn,'.fig'],'fig')
        saveas(band_figs.(bn), [base_name,'_lim1_all',bn,'.png'],'png')
    end


end

