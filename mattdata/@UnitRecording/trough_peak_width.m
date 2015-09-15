function width = trough_peak_width( waveforms )

if isempty(waveforms)
    width = 0;
    return
end

mean_waveform = mean(waveforms, 1);

trough = find(min(mean_waveform) == mean_waveform,1);
peak = find(max(mean_waveform) == mean_waveform,1);

assert(peak > trough)
width = peak - trough;
end
