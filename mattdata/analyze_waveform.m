function waveform_metrics = analyze_waveform( unit_waveforms )
%ANALYZE_WAVEFORM Given waveform, compute certain metrics (e.g. half-width)
% The unit_waveforms is a cell containing "timestamp" 1xB vector and
% "waveform" NxB matrix, where B is the number of bins and N is the number 
% of spikes, for a single unit.

% Hardcoded sampling frequency
fs = 30000;

% For extensibility, use cell to return metrics
waveform_metrics = {};

timestamp = unit_waveforms.timestamp;
waveform = unit_waveforms.waveform;

% This line gives half-spike width
waveform_metrics.half_width = half_width(waveform) / fs;

% Gives current best spike width metric (may change)
waveform_metrics.spike_width = waveform_metrics.half_width;


end

