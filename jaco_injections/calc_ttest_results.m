function ttest_results = calc_ttest_results(ch_band_aves, bands, bandnames, window_size, step_size)


end_time = t(end)-window_size;

ttest_results = cell(num_lfps, 1);
parfor ch = 1:num_lfps
    my_aves = ch_aves{ch};
    my_results = {};
    for bnbad = bandnames
        bn = bnbad{:}
        this_ave = my_aves.(bn);
        ctimes = window_size:step_size:end_time;
        num_ctimes = length(ctimes);
        ps = zeros(num_ctimes,1);
        for jj = 1:num_ctimes
            ctime = ctimes(jj);
            before = this_ave(ctime-window_size <= t & t < ctime);
            after = this_ave(ctime<t & t <= ctime+window_size);
            [~,p] = ttest2(before, after);
            ps(jj) = p;
        end
        my_results.(bn) = ps;
    end
    ttest_results{ch} = my_results;
end




end

