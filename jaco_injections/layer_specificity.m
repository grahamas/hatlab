addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/';
%file_names = {'20140505/J05052014001', '20140505/J05052014002',...
%    '20140505/J05052014003', '20140514/J20140514_M1Contra'};
file_name = '20140505/J05052014001';
% Note that J05052014002 is too short

%file_names = {'20140514/J20140514_M1Contra'};

lfp_ext = '_LFP.mat';
spec_ext = '_spec.mat';
zoom_ext = '_ZOOM_LFP.mat';

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

window_size = .1;
step_size = .025;

[spikes, lfpdeci, estRMS, spikematrix] = brainsigproc([day_dir,file_name,'.ns5'], 1, 0);

save([day_dir,file_name,zoom_ext], 'lfpdeci')
