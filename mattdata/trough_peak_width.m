function width = trough_peak_width( waveforms )

if isempty(waveforms)
    width = 0;
    return
end

mean_waveform = mean(waveforms, 1);

trough = find(min(mean_waveform) == mean_waveform,1);
peak = find(max(mean_waveform) == mean_waveform,1);

if peak <= trough
    'THERES A PROBLEM'
    trough
    peak
    size(mean_waveform)
    width = 0;
else
    width = peak - trough;
end
