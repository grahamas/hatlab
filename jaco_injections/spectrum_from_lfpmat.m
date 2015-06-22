addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/20140505/'
file_names = {'J05052014001'}
% Note that J05052014002 is too short

lfp_ext = '_LFP.mat';
spec_ext = '_spec.mat';

bpowfig_ext = '_bandpow.fig';
bpowpng_ext = '_bandpow.png';

npowfig_ext = '_nodeltapow.fig';
npowpng_ext = '_nodeltapow.png';

lpowfig_ext = '_logpow.fig';
lpowpng_ext = '_logpow.png';

maxpass = 55;

ARB_CH = 3;

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

    for ch = 1:length(ch_band_aves)
        this_ch = ch_band_aves{ch};

        h = figure
        for bandname = bandnames
            bn = bandname{:};
            plot(t./60, this_ch.(bn))
        end
        legend(bandnames)
        xlabel('time (min)')
        ylabel('power')
        title([name,' band powers'])
        savefig(h,[base_name,bpowfig_ext])
        saveas(h,[base_name,bpowpng_ext])

        h = figure
        for bandname = bandnames_nodelta
            bn = bandname{:};
            plot(t./60, this_ch.(bn))
        end
        legend(bandnames)
        xlabel('time (min)')
        ylabel('power')
        title([name,' band powers'])
        savefig(h,[base_name,npowfig_ext])
        saveas(h,[base_name,npowpng_ext])

        h = figure
        for bandname = bandnames
            bn = bandname{:};
            plot(t./60, log(this_ch.(bn)))
        end
        legend(bandnames)
        xlabel('time (min)')
        ylabel('log power')
        title([name,' log band powers'])
        savefig(h,[base_name,lpowfig_ext])
        saveas(h,[base_name,lpowpng_ext])


    
end

