addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/20140505/'
filebase = 'J05052014001'
% Note that J05052014002 is too short

'reading data...'
load([day_dir,filebase,'_LFP.mat'])
'done.'

maxpass = 55;

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

num_lfps = length(lfpdeci);
lfpmat = cell2mat(lfpdeci)';

'computing specgram...'
[S, t, f] = mtspecgramc(lfpmat, movingwin, params);
'done.'


ch_aves = cell(num_lfps, 1);
for bandname = bandnames
    bandname = bandname{:};
    band_freqs = bands.(bandname);
    band_dx = band_freqs(1) <= f & f < band_freqs(2);
    band_lfp = S(:,band_dx,:);
    band_ave = squeeze(mean(band_lfp, 2));
    for ch = 1:num_lfps
        ch_aves{ch}.(bandname) = band_ave(:,ch);
    end
end

window_size = 120;
step_size = .5;

end_time = t(end)-window_size;

ttest_results = cell(num_lfps, 1);
parfor ch = 1:num_lfps
    my_aves = ch_aves{ch};
    my_results = {};
    for bnbad = bandnames
        bn = bnbad{:}
        this_ave = my_aves.(bn);
        ctimes = window_size:step_size:end_time;
        num_ctimes = length(ctimes);
        ps = zeros(num_ctimes,1);
        for jj = 1:num_ctimes
            ctime = ctimes(jj);
            before = this_ave(ctime-window_size <= t & t < ctime);
            after = this_ave(ctime<t & t <= ctime+window_size);
            [~,p] = ttest2(before, after);
            ps(jj) = p;
        end
        my_results.(bn) = ps;
    end
    ttest_results{ch} = my_results;
end




