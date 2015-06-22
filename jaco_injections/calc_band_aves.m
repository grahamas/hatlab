function ch_band_aves = calc_band_aves(S, f, bands, bandnames)
% Given a by-channel spectrogram, average accross each band for
% each channel.

num_chs = size(S, 3);

ch_band_aves = cell(num_chs,1);

for bandname = bandnames
    bn = bandname{:};
    band_freqs = bands.(bn);
    band_dx = band_freqs(1) <= f & f < band_freqs(2);
    band_lfp = S(:,band_dx,:);
    band_ave = squeeze(mean(band_lfp,2));
    for ch = 1:num_chs
        ch_band_aves{ch}.(bn) = band_ave(:,ch);
    end
end

end
