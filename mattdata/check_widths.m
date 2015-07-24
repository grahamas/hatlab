
num_channels = length(session.channel);

for ii = 1:num_channels
    channel = session.channel(ii);
    num_units = length(channel.unit);
    for jj = 1:num_units
        unit = channel.unit(jj);
        width = unit.width;
        if length(width) ~= 1
            fprintf('There is a problem\n')
            ii
            jj
        end
    end
end

