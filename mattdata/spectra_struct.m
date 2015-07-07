function output_cell = spectra_struct( lfp, moving_win, params )

[S, t, f] = mtspecgramc(lfp, moving_win, params);
mid_beta = mid_beta_filt(lfp);

output_cell = struct('S', S, 't', t, 'f', f, 'mid_beta', mid_beta);


end

