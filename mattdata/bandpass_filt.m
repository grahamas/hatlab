function y = bandpass_filt(x, cutoffs)
% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = 1000;  % Sampling Frequency

N  = 4;    % Order
Fc1 = cutoffs(1);  % Low Cutoff Frequency
Fc2 = cutoffs(2);  % High Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');

% [EOF]
y = filtfilt(Hd.sosMatrix, Hd.ScaleValues, x);