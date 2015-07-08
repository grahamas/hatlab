function output_cell = spectra_struct( lfp, moving_win, params )

[S, t, f] = mtspecgramc(lfp, moving_win, params);

output_cell = struct('S', S, 't', t, 'f', f);


end

