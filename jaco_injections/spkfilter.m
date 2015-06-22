function y = spkfilter(x)
%SPKFILTER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.2 and the Signal Processing Toolbox 6.20.
% Generated on: 28-Oct-2014 17:20:57

% Butterworth Highpass filter designed using FDESIGN.HIGHPASS.

% All frequency values are in Hz.
Fs = 30000;  % Sampling Frequency

N  = 4;    % Order
Fc = 250;  % Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.highpass('N,F3dB', N, Fc, Fs);
Hd = design(h, 'butter');
y = filtfilt(Hd.sosMatrix, Hd.ScaleValues,x);
% [EOF]
