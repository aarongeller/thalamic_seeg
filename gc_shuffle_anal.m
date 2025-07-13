function [uncorrected_tfs pixelcorrected_tfs clustercorrected_tfs] ...
    =  gc_shuffle_anal(allvals, baselinevals, elecinds, shufflenum, actual_tfs)

% allvals: elecs x trials x freqs x time

if length(elecinds)>1
    % elec_allvals: trials x freqs x time
    elec_allvals = squeeze(mean(allvals(elecinds, :, :, :), "omitnan"));
    % elec_baselinevals: trials x freqs x time
    elec_baselinevals = squeeze(mean(baselinevals(elecinds, :, :, :), "omitnan"));
else
    elec_allvals = squeeze(allvals(elecinds, :, :, :));
    elec_baselinevals = squeeze(baselinevals(elecinds, :, :, :));
end

tic;
thresh_frac = 0.25; % Cohen Ch 33 sample code 
[res, low_dist, high_dist, blobs] = baseline_permute(elec_allvals, elec_baselinevals, shufflenum, thresh_frac);
toc;

uncorrected_tfs = do_thresh(actual_tfs, res);
pixelcorrected_tfs = do_thresh(actual_tfs, low_dist, high_dist);
clustercorrected_tfs = do_cluster_thresh(actual_tfs, blobs, thresh_frac);

function [res, low_dist, high_dist, blobscores] = baseline_permute(trialvals, baselinevals, shufflenum, thresh_frac)
numtrials = size(trialvals,1);
trial_freqs = size(trialvals, 2);
trial_samples = size(trialvals, 3);
baseline_samples = size(baselinevals, 3);
total_samples = trial_samples + baseline_samples;

% stick baselines onto trials
concatenated_orig_data = nan(numtrials, trial_freqs, total_samples);
concatenated_orig_data(:,:,1:baseline_samples) = baselinevals;
concatenated_orig_data(:,:,(baseline_samples+1):total_samples) = trialvals;

res = nan(shufflenum, trial_freqs, trial_samples);
low_dist = nan(shufflenum, 1);
high_dist = nan(shufflenum, 1);
blobscores = zeros(shufflenum, 1);

for i=1:shufflenum
    offsets = randi(total_samples, numtrials, 1);    
    concatenated_shuffled_data = nan(size(concatenated_orig_data));

    % shift each trial by random # of samples
    for j=1:numtrials    
        concatenated_shuffled_data(j,:,:) = circshift(concatenated_orig_data(j,:,:), ...
                                                      offsets(j), 2);
    end
    
    % split off the new "baselines"
    shuffled_baselinevals = concatenated_shuffled_data(:, :, 1:baseline_samples);
    shuffled_trialvals = concatenated_shuffled_data(:, :, (baseline_samples+1):end);

    % take mean over trials and save the z-score TFS for this shuffle
    thistfs = do_zscore(squeeze(mean(shuffled_trialvals)), ...
                        squeeze(mean(shuffled_baselinevals)));
    res(i,:,:) = thistfs;
    
    % save extreme values for pixel-based correction
    low_dist(i) = min(thistfs(:));
    high_dist(i) = max(thistfs(:));
    
    % get cluster scores
    thresh_tfs = thistfs;
    thresh_tfs(abs(thresh_tfs) < range(thresh_tfs(:))*thresh_frac) = 0;
    [mapl, nblobs] = bwlabel(thresh_tfs);
    clustsum = zeros(1, nblobs);
    for j=1:nblobs
        clustsum(j) = abs(sum(thistfs(mapl(:)==j)));
    end

    blobscores(i) = max(clustsum);
end

function thresholded_tfs = do_thresh(orig_tfs, low_thresh, high_thresh)

if size(low_thresh, 2)==1
    % pixel-based correction using saved low and high populations
    n = length(low_thresh);
    low_dist = repmat(low_thresh, size(orig_tfs));
    low_dist = reshape(low_dist, [n size(orig_tfs)]);
end

if exist('high_thresh', 'var')
    if size(high_thresh, 2)==1
        % pixel-based correction using saved low and high populations
        n = length(high_thresh);
        high_dist = repmat(high_thresh, size(orig_tfs));
        high_dist = reshape(high_dist, [n size(orig_tfs)]);
    end
else
    % no correction, using simulated TFS stack
    low_dist = low_thresh;
    high_dist = low_dist;
end

thresholded_tfs = zeros(size(orig_tfs));
for i=1:size(orig_tfs,1)
    for j=1:size(orig_tfs,2)
        p1 = prctile(low_dist(:,i,j), 2.5);
        p2 = prctile(high_dist(:,i,j), 97.5);
        if orig_tfs(i,j) < p1 | orig_tfs(i,j) > p2
            thresholded_tfs(i,j) = orig_tfs(i,j);
        end
    end
end

function thresholded_tfs = do_cluster_thresh(orig_tfs, blobscores, thresh_frac)

thresholded_tfs = zeros(size(orig_tfs));

% get cluster scores
thresh_tfs = orig_tfs;
thresh_tfs(abs(thresh_tfs) < range(thresh_tfs(:))*thresh_frac) = 0;
[mapl, nblobs] = bwlabel(thresh_tfs);
clustsum = zeros(1, nblobs);
for j=1:nblobs
    clustsum(j) = abs(sum(thresh_tfs(mapl(:)==j)));
end

% get clusters above threshold
goodclusters = find(clustsum > prctile(blobscores, 95));

for i=1:length(goodclusters)
    % copy each good cluster
    this_cluster_inds = find(mapl==goodclusters(i));
    for j=1:length(this_cluster_inds)        
        thresholded_tfs(this_cluster_inds(j)) = orig_tfs(this_cluster_inds(j));
    end
end
