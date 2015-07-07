function y = mid_beta_filt(x)
% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = 30000;  % Sampling Frequency

N  = 4;    % Order
Fc1 = 20;  % Low Cutoff Frequency
Fc2 = 25;  % High Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');

% [EOF]
y = filtfilt(Hd.sosMatrix, Hd.ScaleValues,x);