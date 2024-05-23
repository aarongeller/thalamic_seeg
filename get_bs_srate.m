function srate = get_bs_srate(history)

% get sampling rate from brainstorm history struct

% looks for string: '    Resample: from xxx Hz to yyy Hz'

srate = -inf;

for i=1:length(history)
    res = split(extractAfter(history(i,3), 'Resample:'));
    if length(res)>1
        srate = str2num(res{end-1});
        break;
    end
end

        

