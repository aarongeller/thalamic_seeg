function zmat = do_zscore(valmat, blmat)
zmat = zeros(size(valmat));
for i=1:size(zmat,1)
    s = std(blmat(i,:));
    m = mean(blmat(i,:));
    if s>10^-6
        zmat(i,:) = (valmat(i,:) - m)./s;
    end
end
