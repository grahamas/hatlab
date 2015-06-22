function rmsEstimate = computeRMS(rawdata, totalchans)

% disp(size(rawdata.Data));
filteredData = spkfilter(rawdata.Data(:,1:60000)');
filteredData = filteredData';
% disp(size(filteredData));
segdata = reshape(filteredData, totalchans, 600, 100);
% segrdata = segdata;
segdata = mean(segdata.^2,2);
segdata = squeeze(segdata);
segdata = sort(segdata,2);
seg = segdata(:, 6:25);
rmsEstimate = sqrt(mean(seg,2));