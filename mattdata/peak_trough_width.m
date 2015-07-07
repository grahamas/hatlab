function width = trough_peak_width( waveform )

if isempty(waveform)
    width = 0;
    return
end

mean_waveform = mean(waveform, 2);

trough = find(min(mean_waveform) == mean_waveform,1);
peak = find(max(mean_waveform) == mean_waveform,1);

if peak <= trough
    'THERES A PROBLEM'
    start
    stop
    width = 0;
else
    width = peak - trough;
end

% half_peak = max(waveform, [], 1) ./ 2;
% 
% % prefix 'b' denotes a binary/logical matrix
% num_waveforms = size(waveform,2);
% 
% width = zeros(num_waveforms, 1);
% for ii = 1:num_waveforms
%     b_over_half = waveform(:, ii) >= half_peak(ii);
%     b_under_half = ~b_over_half;
%     
%     start = find(b_over_half, 1);
%     
%     under_half_dx = find(b_under_half);
%     b_after_spike = under_half_dx  > start;
%     
%     stop = under_half_dx(find(b_after_spike, 1));
%     
%     stop
%     start
%     if start > 40
%         waveform(:,ii)
%     end
%     width(ii) = stop - start;
% end
    
end