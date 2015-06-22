function y = lfpfilt(x)
%NS5TONS3FILTER Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.2 and the Signal Processing Toolbox 6.20.
% Generated on: 25-Sep-2014 16:48:37

% Butterworth Lowpass filter designed using FDESIGN.LOWPASS.

% All frequency values are in Hz.
Fs = 30000;  % Sampling Frequency

N  = 4;    % Order
Fc = 500;  % Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass('N,F3dB', N, Fc, Fs);
Hd = design(h, 'butter');

% [EOF]
y = filtfilt(Hd.sosMatrix, Hd.ScaleValues,x);