function clusters = cluster_phase_shifts( phase_shifts_by_band, bands, num_clusters )
%CLUSTER_PHASE_SHIFTS The first argument is a cell that is indexed by band
%names. Within each cell is a matrix of phase shifts at that band
%(symmetric by construction). The second argument is a cell array of band
%names to be used in clustering. Each band in bands will be used to
%construct a column (using the first column, i.e. using the first as a
%reference).

num_bands = length(bands);
data = [];

for ii = 1:num_bands
    band = bands{ii};
    phase_shifts = phase_shifts_by_band.(band);
    data = [data, phase_shifts(:,1)];
end

clusters = kmeans(data, num_clusters);

end

