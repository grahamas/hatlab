addpath(genpath('/home/grahams/chronux'))

day_dir = '/home/grahams/jaco_injections/';
file_names = {'20140505/J20140505_M1Contra'};

lfp_ext = '_LFP.mat';
phase_shifts_ext = '_phase_shifts.mat';

maxpass = 55;

ARB_CH = 3;

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

band_names={'delta','theta','alpha','beta', 'low_beta', 'low_mid_beta', 'mid_beta', 'high_beta','gamma'};
num_bands = length(band_names);

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


%%%%%%%%

goodchs = goodchs05;

%%%%%%%%

calc_phase_shift = @(angles1, angles2, shifts) arrayfun(@(shift) sum(abs(angles1(1:end-shift) - angles2(shift+1:end))), shifts);

for file_name = file_names
    name = file_name{:};
    base_name = [day_dir,name];
    lfp_name = [base_name, lfp_ext];
    load(lfp_name);
    num_lfps = length(lfpdeci);
    
    phase_shifts_by_band = {};

    for band_num = 1:num_bands
        band_name = band_names{band_num};
        band_cutoffs = bands.(band_name);
        lfp_angles = cell(1,num_lfps);
        for lfp_num = 1:num_lfps
            lfp = lfpdeci{lfp_num};
            filtered_lfp = bandpass_filt(lfp, band_cutoffs);
            lfp_angles{lfp_num} = angle(hilbert(filtered_lfp));
        end
        period_sec = 1/max(band_cutoffs);
        period_bin_num = period_sec * params.Fs;
        tau = 1:period_bin_num;
        phase_shifts = zeros(num_lfps, num_lfps);
        for ii = 1:num_lfps-1
            for jj = ii+1:num_lfps
                [max_angle, max_angle_dx] = max(calc_phase_shift(lfp_angles{ii}, lfp_angles(jj), tau));
                phase_shifts(ii, jj) = tau(max_angle_dx);
            end
        end
        phase_shifts = phase_shifts + phase_shifts';
        phase_shifts_by_band.(band_name) = phase_shifts;
    end
    save([base_name,phase_shifts_ext], phase_shifts_by_band, '-v7.3');
end
                
        

end
