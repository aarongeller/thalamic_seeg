function [Fxy,Fyx] = mov_bi_ga_seeded(dat,seedchan,startp,endp,win,order,fs,freq,docirc)
% MOV_BI_GA_SEEDED Compute the granger causality from the moving window Bivariate models
% 
% Usage:
%   [Fxy,Fyx] = mov_bi_ga_seeded(dat,seedchan,startp,endp,window,order,fs,freq) 
% 
% Input(s):
%   dat     - data set in Matlab format
%   seedchan - channel to use as connectivity seed
%   starp   - start position
%   endp    - ending position
%   win     - window length
%   order   - model order
%   fs      - Sampling rate
%   freq    - a vector of frequencies of interest, usually freq = 0:fs/2
% 
% Output(s):
%   Fx2y    - the causality measure from x to y
%   Fy2x    - causality from y to x
%             The order of Fx2y/Fy2x is 1 to 2:L, 2 to 3:L,....,L-1 to L, where
%             L is the number of channels. That is, 1st column: 1&2; 2nd:
%             1&3; ...; (L-1)th: 1&L; ...; (L(L-1))th:(L-1)&L.
% 
% Example:
%   [Fxy,Fyx] = mov_bi_ga_seeded(data,1,18,10,5,200,[1:100])
% 
% See also: one_bi_ga.

% modified from BSMART toolbox.

if ~exist('docirc','var')
    docirc = 0;
end

channel = size(dat,2);
trial   = size(dat,3);
points  = endp-startp+1;
   
fxy = [];
fyx = [];
b = zeros(2,trial*win);
count = 0;
total = (points-win+1)*(channel-1);

if docirc
    % for permutation testing
    sliceafter = randi(size(dat,1));
    dat(:,seedchan,:) = circshift(dat(:,seedchan,:), sliceafter);
end

p = gcp; % 4 workers
ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
                        'showWorkerProgress', true, 'title', ...
                        'Granger Causality Calculation');

parfor t = 1:points-win+1
    endind = t+startp+win-2;
    a = dat(t+startp-1:endind,:,:);
    b = zeros(2, win);
    for c = 1:channel
        if c==seedchan
            fxy(c,:,t) = nan(length(freq), 1);
            fyx(c,:,t) = nan(length(freq), 1);
        else
            for k = 1:trial
                b(1, (k-1)*win+1:k*win) = a(:, seedchan, k);
                b(2, (k-1)*win+1:k*win) = a(:, c, k);
            end
            b = zscore(detrend(b'))';
            [~, ~, fxy(c,:,t), fyx(c,:,t)] = pwcausal(b, trial, win, order, fs, freq);
            pause(100/total);
            ppm.increment();
        end
    end
end

delete(ppm);

Fxy = fxy;
Fyx = fyx;

end%mov_bi_ga

% [EOF]
