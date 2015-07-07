function width = half_width( waveform )
%HALF_WIDTH Calculate the spike half-width of waveforms
% The half-spike width is the time elapsed between when the waveform first
% surpasses half the peak amplitude, to when it next passes below the same
% threshold. This threshold, and the peak amplitude, are calculated with
% respect to a de-meaned waveform. 
% NOTE: Need to find better way to get resting potential.
%
% waveform: T x N matrix; T time bins, N spikes.
%

if isempty(waveform)
    width = 0;
    return
end

mean_waveform = mean(waveform, 1);

half_peak = max(mean_waveform) / 2;
size(half_peak)

b_over_half = mean_waveform >= half_peak;
start = find(b_over_half, 1);

b_under_half = ~b_over_half;
under_half_dx = find(b_under_half);
b_after_spike = under_half_dx > start;
stop = under_half_dx(find(b_after_spike, 1));

width = stop - start;

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

