function [m, channel_names, seednum] = exclude_channels(dat, channel_names, seedstr)
skip_channels = get_skip();
seednum = find(strcmpi(seedstr, channel_names));
indexvec = zeros(1, length(channel_names));
for i=1:length(skip_channels)
    indexvec = or(indexvec, strcmp(skip_channels{i}, channel_names));
end
savevec = not(indexvec);
badinds = find(indexvec);
for i=1:length(badinds)
    if badinds(i) < seednum
        seednum = seednum - 1;
    else
        break
    end
end
if isempty(dat)
    m = dat;
else
    m = dat(savevec, :);
end
channel_names = channel_names(savevec);
