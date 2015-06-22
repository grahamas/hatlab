function save_spectrum_from_lfpmat(basename, movingwin, params)

'reading data...'
load([basename,'_LFP.mat'])
'done.'

lfpmat = cell2mat(lfpdeci)';

'computing specgram...'
[S, t, f] = mtspecgramc(lfpmat, movingwin, params);
'done.'

'saving specgram...'
save([basename,'_spec.mat'],'S','t','f');
'done.'

end
