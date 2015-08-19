function band_avg = band_avg_from_spec(S, f, band_cutoffs)
    
    band_dx = band_cutoffs(1) <= f & f < band_freqs(2);
    band_lfp = S(:,band_dx)
    band_avg = squeeze(mean(band_lfp, 2));

end
