load('beh.mat')

lfp_fs = 1000;
spike_fs = 30000;

num_channels = length(all_channels);

parfor ii = 1:num_channels
    if isempty(all_channels(ii).unit_waveforms)
        continue
    end
    num_behaviors = length(all_channels(ii).behavior_spectra);
    
    for jj = 1:num_behaviors
        % Under assumption instruction 10ms prior to go...
        start = beh(jj,1);
        instruction = beh(jj,3);
        movement = beh(jj,5);
        %%% THIS CODE ASSUMES lfpfs = 1000 !!! %%%
        all_channels(ii).behavior_spectra(jj).instruction_early.time...
            = [instruction + .001, instruction + .500];
        all_channels(ii).behavior_spectra(jj).instruction_late.time...
            = [instruction + .501, instruction + 1.000];
        all_channels(ii).behavior_spectra(jj).execution.time...
            = [movement - .200, movement + .299];
    end
end

%save('all_channels_new.mat', 'all_channels', '-v7.3')
