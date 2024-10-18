function b = get_matching_inds(vec1, vec2)
temp = [];
for i=1:length(vec2)
    temp(end+1,:) = strcmp(vec1, vec2{i});
end
b = find(any(temp));
