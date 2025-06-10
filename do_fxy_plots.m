function do_fxy_plots(gc_info, figsdir, tfsclim, zclim, timevec, ...
                      overwrite_all_figs, overwrite_ioz_figs);

if ~exist(figsdir, 'dir')
    mkdir(figsdir);
end

forwarddir = fullfile(figsdir, 'forward');
if ~exist(forwarddir, 'dir')
    mkdir(forwarddir);
end

forwardthreshdir = fullfile(figsdir, 'forward_thresh');
if ~exist(forwardthreshdir, 'dir')
    mkdir(forwardthreshdir);
end

backwarddir = fullfile(figsdir, 'backward');
if ~exist(backwarddir, 'dir')
    mkdir(backwarddir);
end

backwardthreshdir = fullfile(figsdir, 'backward_thresh');
if ~exist(backwardthreshdir, 'dir')
    mkdir(backwardthreshdir);
end

diffdir = fullfile(figsdir, 'diff');
if ~exist(diffdir, 'dir')
    mkdir(diffdir);
end

if ~exist('sz_onset_s', 'var')
    sz_onset_s = nan;
end

if ~exist('sz_offset_s', 'var')
    sz_offset_s = nan;
end

if ~exist('overwrite_all_figs', 'var')
    overwrite_all_figs = 1;
end

if ~exist('overwrite_z_figs', 'var')
    overwrite_ioz_figs = 1;
end

tic;

% p = gcp;
% total = size(gc_info.Fxy,1);
% ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
%                         'showWorkerProgress', true, 'title', ...
%                         'Plotting Forward Connectivity');

elecs = size(gc_info{1}.Fxy, 1);
freqs = size(gc_info{1}.Fxy, 2);
timepts = size(gc_info{1}.Fxy, 3);
baseline_timepts = size(gc_info{1}.Fxy_baseline, 3);

RowNames = gc_info{1}.channel_names;

allvals_Fxy = nan(elecs, length(gc_info), freqs, timepts);
allvals_Fyx = nan(elecs, length(gc_info), freqs, timepts);
meanvals_Fxy = nan(elecs, freqs, timepts);
meanvals_Fyx = nan(elecs, freqs, timepts);
baselinevals_Fxy = nan(elecs, length(gc_info), freqs, baseline_timepts);
baselinevals_Fyx = nan(elecs, length(gc_info), freqs, baseline_timepts);
baselinemeans_Fxy = nan(elecs, freqs, baseline_timepts);
baselinemeans_Fyx = nan(elecs, freqs, baseline_timepts);

zvals_Fxy = nan(size(meanvals_Fxy));
zvals_Fyx = nan(size(meanvals_Fxy));
iozzvals_Fxy = nan(size(meanvals_Fxy));
iozzvals_Fyx = nan(size(meanvals_Fxy));
noniozzvals_Fxy = nan(size(meanvals_Fxy));
noniozzvals_Fyx = nan(size(meanvals_Fxy));

for i=1:length(gc_info) % for every file,
    for j=1:elecs
        allvals_Fxy(j,i,:,:) = gc_info{i}.Fxy(j,:,:);
        allvals_Fyx(j,i,:,:) = gc_info{i}.Fyx(j,:,:);
        baselinevals_Fxy(j,i,:,:) = gc_info{i}.Fxy_baseline(j,:,:);
        baselinevals_Fyx(j,i,:,:) = gc_info{i}.Fyx_baseline(j,:,:);
    end
end

skipthese = get_skip();

badinds = get_matching_inds(RowNames, skipthese);
goodinds = setdiff(1:elecs, badinds);

ioz = gc_info{1}.ioz;
iozinds = get_matching_inds(RowNames, ioz);
noniozinds = setdiff(1:elecs, iozinds);

for i=1:elecs
    if length(find(badinds==i))>0
        continue
    else
        meanvals_Fxy(i,:,:) = squeeze(mean(allvals_Fxy(i,:,:,:), "omitnan"));
        meanvals_Fyx(i,:,:) = squeeze(mean(allvals_Fyx(i,:,:,:), "omitnan"));
        baselinemeans_Fxy(i,:,:) = squeeze(mean(baselinevals_Fxy(i,:,:,:), "omitnan"));
        baselinemeans_Fyx(i,:,:) = squeeze(mean(baselinevals_Fyx(i,:,:,:), "omitnan"));
        zvals_Fxy(i,:,:) = do_zscore(squeeze(meanvals_Fxy(i,:,:)), squeeze(baselinemeans_Fxy(i,:,:)));
        zvals_Fyx(i,:,:) = do_zscore(squeeze(meanvals_Fyx(i,:,:)), squeeze(baselinemeans_Fyx(i,:,:)));
    end
end

[iozmeanvals_Fxy, iozmeanvals_Fyx, iozbaselinemeans_Fxy, iozbaselinemeans_Fyx, ...
 iozzscore_Fxy, iozzscore_Fyx] = do_roi_anal(meanvals_Fxy, meanvals_Fyx, baselinemeans_Fxy, ...
                                             baselinemeans_Fyx, iozinds);

[noniozmeanvals_Fxy, noniozmeanvals_Fyx, noniozbaselinemeans_Fxy, noniozbaselinemeans_Fyx, ...
 noniozzscore_Fxy, noniozzscore_Fyx] = do_roi_anal(meanvals_Fxy, meanvals_Fyx, baselinemeans_Fxy, ...
                                                  baselinemeans_Fyx, noniozinds);

[channel_names, inds] = sort(gc_info{1}.channel_names);

if overwrite_all_figs
    for i=1:elecs
        if length(find(badinds==inds(i)))>0
            continue
        else
            figname = [sprintf('%03d', i) '_' gc_info{1}.seedstr '_' channel_names{i} '.png'];
            figpath = fullfile(forwarddir, figname);
            titstr = [gc_info{1}.seedstr ' -> ' channel_names{i}];
            do_tfs_fig(squeeze(meanvals_Fxy(inds(i),:,:)), tfsclim, gc_info{1}.freqs, ...
                       gc_info{1}.srate, titstr, figpath, timevec);

            zfigname = ['z_' sprintf('%03d', i) '_' gc_info{1}.seedstr '_' channel_names{i} '.png'];
            zfigpath = fullfile(forwarddir, zfigname);
            ztitstr = ['Z-Score ' gc_info{1}.seedstr ' -> ' channel_names{i}];
            do_tfs_fig(squeeze(zvals_Fxy(inds(i),:,:)), zclim, gc_info{1}.freqs, gc_info{1}.srate, ...
                       ztitstr, zfigpath, timevec);

            % pause(100/total);
            % ppm.increment();
        end
    end
end
% delete(ppm);

shufflenum = 1000;

if overwrite_all_figs | overwrite_ioz_figs
    ioz_figname = ['400_' gc_info{1}.seedstr '_IOZ.png'];
    ioz_figpath = fullfile(forwarddir, ioz_figname);
    ioz_titstr = [gc_info{1}.seedstr ' -> IOZ'];
    do_tfs_fig(squeeze(mean(iozmeanvals_Fxy, "omitnan")), tfsclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, ioz_titstr, ioz_figpath, timevec);

    zioz_figname = ['z_401_' gc_info{1}.seedstr '_IOZ.png'];
    zioz_figpath = fullfile(forwarddir, zioz_figname);
    zioz_titstr = ['z(' gc_info{1}.seedstr ' -> IOZ)'];
    do_tfs_fig(iozzscore_Fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, zioz_titstr, zioz_figpath, timevec);

    nonioz_figname = ['402_' gc_info{1}.seedstr '_nonIOZ.png'];
    nonioz_figpath = fullfile(forwarddir, nonioz_figname);
    nonioz_titstr = [gc_info{1}.seedstr ' -> nonIOZ'];
    do_tfs_fig(squeeze(mean(noniozmeanvals_Fxy, "omitnan")), tfsclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, nonioz_titstr, nonioz_figpath, timevec);

    znonioz_figname = ['z_403_' gc_info{1}.seedstr '_nonIOZ.png'];
    znonioz_figpath = fullfile(forwarddir, znonioz_figname);
    znonioz_titstr = ['z(' gc_info{1}.seedstr ' -> nonIOZ)'];
    do_tfs_fig(noniozzscore_Fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, znonioz_titstr, znonioz_figpath, timevec);

    zdiffioz_figname = ['zdiff_404_' gc_info{1}.seedstr '_IOZ.png'];
    zdiffioz_figpath = fullfile(diffdir, zdiffioz_figname);
    zdiffioz_titstr = ['z(IOZ -> ' gc_info{1}.seedstr ') - z(' gc_info{1}.seedstr ' -> IOZ)'];
    do_tfs_fig(iozzscore_Fxy - iozzscore_Fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, zdiffioz_titstr, zdiffioz_figpath, timevec);

    zdiffnonioz_figname = ['zdiff_405_' gc_info{1}.seedstr '_nonIOZ.png'];
    zdiffnonioz_figpath = fullfile(diffdir, zdiffnonioz_figname);
    zdiffnonioz_titstr = ['z(nonIOZ -> ' gc_info{1}.seedstr ') - z(' gc_info{1}.seedstr ' -> nonIOZ)'];
    do_tfs_fig(noniozzscore_Fxy - noniozzscore_Fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, zdiffnonioz_titstr, zdiffnonioz_figpath, timevec);

    % thresholded TFS analyses- IOZ
    [thresh_zioz_fxy, pixel_thresh_zioz_fxy, cluster_thresh_zioz_fxy] = ...
        gc_shuffle_anal(allvals_Fxy, baselinevals_Fxy, iozinds, shufflenum, iozzscore_Fxy);

    % 1) no correction for multiple comparisons
    thresh_zioz_figname = ['thresh_406_z_' gc_info{1}.seedstr '_IOZ.png'];
    thresh_zioz_figpath = fullfile(forwardthreshdir, thresh_zioz_figname);
    thresh_zioz_titstr = ['Thresholded z(' gc_info{1}.seedstr ' -> IOZ)'];
    do_tfs_fig(thresh_zioz_fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, thresh_zioz_titstr, thresh_zioz_figpath, timevec);

    % 2) pixel-based correction
    pixel_thresh_zioz_figname = ['thresh_407_pixel_' gc_info{1}.seedstr '_IOZ.png'];
    pixel_thresh_zioz_figpath = fullfile(forwardthreshdir, pixel_thresh_zioz_figname);
    pixel_thresh_zioz_titstr = ['Pixel Corrected Thresholded z(' gc_info{1}.seedstr ' -> IOZ)'];
    do_tfs_fig(pixel_thresh_zioz_fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, pixel_thresh_zioz_titstr, pixel_thresh_zioz_figpath, timevec);

    % 3) cluster-based correction
    cluster_thresh_zioz_figname = ['thresh_408_cluster_' gc_info{1}.seedstr '_IOZ.png'];
    cluster_thresh_zioz_figpath = fullfile(forwardthreshdir, cluster_thresh_zioz_figname);
    cluster_thresh_zioz_titstr = ['Cluster Corrected Thresholded z(' gc_info{1}.seedstr ' -> IOZ)'];
    do_tfs_fig(cluster_thresh_zioz_fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, cluster_thresh_zioz_titstr, cluster_thresh_zioz_figpath, timevec);

    % thresholded TFS analyses- nonIOZ
    [thresh_znonioz_fxy, pixel_thresh_znonioz_fxy, cluster_thresh_znonioz_fxy] = ...
        gc_shuffle_anal(allvals_Fxy, baselinevals_Fxy, noniozinds, shufflenum, noniozzscore_Fxy);

    % 1) no correction for multiple comparisons
    thresh_znonioz_figname = ['thresh_409_z_' gc_info{1}.seedstr '_nonIOZ.png'];
    thresh_znonioz_figpath = fullfile(forwardthreshdir, thresh_znonioz_figname);
    thresh_znonioz_titstr = ['Thresholded z(' gc_info{1}.seedstr ' -> nonIOZ)'];
    do_tfs_fig(thresh_znonioz_fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, thresh_znonioz_titstr, thresh_znonioz_figpath, timevec);

    % 2) pixel-based correction
    pixel_thresh_znonioz_figname = ['thresh_410_pixel_' gc_info{1}.seedstr '_nonIOZ.png'];
    pixel_thresh_znonioz_figpath = fullfile(forwardthreshdir, pixel_thresh_znonioz_figname);
    pixel_thresh_znonioz_titstr = ['Pixel Corrected Thresholded z(' gc_info{1}.seedstr ' -> nonIOZ)'];
    do_tfs_fig(pixel_thresh_znonioz_fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, pixel_thresh_znonioz_titstr, pixel_thresh_znonioz_figpath, timevec);

    % 3) cluster-based correction
    cluster_thresh_znonioz_figname = ['thresh_411_cluster_' gc_info{1}.seedstr '_nonIOZ.png'];
    cluster_thresh_znonioz_figpath = fullfile(forwardthreshdir, cluster_thresh_znonioz_figname);
    cluster_thresh_znonioz_titstr = ['Cluster Corrected Thresholded z(' gc_info{1}.seedstr ' -> nonIOZ)'];
    do_tfs_fig(cluster_thresh_znonioz_fxy, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, cluster_thresh_znonioz_titstr, cluster_thresh_znonioz_figpath, timevec);

end
% ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
%                         'showWorkerProgress', true, 'title', ...
%                         'Plotting Backward Connectivity');

if overwrite_all_figs
    for i=1:elecs
        if length(find(badinds==inds(i)))>0
            continue
        else
            figname = [sprintf('%03d', i) '_' channel_names{i} '_' gc_info{1}.seedstr '.png'];
            figpath = fullfile(backwarddir, figname);
            titstr = [channel_names{i} ' -> ' gc_info{1}.seedstr];
            do_tfs_fig(squeeze(meanvals_Fyx(inds(i),:,:)), tfsclim, gc_info{1}.freqs, ...
                       gc_info{1}.srate, titstr, figpath, timevec);

            zfigname = ['z_' sprintf('%03d', i) '_' channel_names{i} '_' gc_info{1}.seedstr '.png'];
            zfigpath = fullfile(backwarddir, zfigname);
            ztitstr = ['Z-Score ' channel_names{i} ' -> ' gc_info{1}.seedstr];
            do_tfs_fig(squeeze(zvals_Fyx(inds(i),:,:)), zclim, gc_info{1}.freqs, gc_info{1}.srate, ...
                       ztitstr, zfigpath, timevec);
            % pause(100/total);
            %    ppm.increment();
        end
    end
end
% delete(ppm);

if overwrite_all_figs | overwrite_ioz_figs
    ioz_figname = ['400_IOZ_' gc_info{1}.seedstr '.png'];
    ioz_figpath = fullfile(backwarddir, ioz_figname);
    ioz_titstr = ['IOZ -> ' gc_info{1}.seedstr];
    do_tfs_fig(squeeze(mean(iozmeanvals_Fyx, "omitnan")), tfsclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, ioz_titstr, ioz_figpath, timevec);

    zioz_figname = ['z_401_IOZ_' gc_info{1}.seedstr '.png'];
    zioz_figpath = fullfile(backwarddir, zioz_figname);
    zioz_titstr = ['z(IOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(iozzscore_Fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, zioz_titstr, zioz_figpath, timevec);

    nonioz_figname = ['402_nonIOZ_' gc_info{1}.seedstr '.png'];
    nonioz_figpath = fullfile(backwarddir, nonioz_figname);
    nonioz_titstr = ['nonIOZ -> ' gc_info{1}.seedstr];
    do_tfs_fig(squeeze(mean(noniozmeanvals_Fyx, "omitnan")), tfsclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, nonioz_titstr, nonioz_figpath, timevec);

    znonioz_figname = ['z_403_nonIOZ_' gc_info{1}.seedstr '.png'];
    znonioz_figpath = fullfile(backwarddir, znonioz_figname);
    znonioz_titstr = ['z(nonIOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(noniozzscore_Fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, znonioz_titstr, znonioz_figpath, timevec);

    % thresholded TFS analyses
    [thresh_zioz_fyx, pixel_thresh_zioz_fyx, cluster_thresh_zioz_fyx] = ...
        gc_shuffle_anal(allvals_Fyx, baselinevals_Fyx, iozinds, shufflenum, iozzscore_Fyx);

    % 1) no correction for multiple comparisons
    thresh_zioz_figname = ['thresh_406_z_IOZ_' gc_info{1}.seedstr '.png'];
    thresh_zioz_figpath = fullfile(backwardthreshdir, thresh_zioz_figname);
    thresh_zioz_titstr = ['Thresholded z(IOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(thresh_zioz_fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, thresh_zioz_titstr, thresh_zioz_figpath, timevec);

    % 2) pixel-based correction
    pixel_thresh_zioz_figname = ['thresh_407_pixel_IOZ_' gc_info{1}.seedstr '.png'];
    pixel_thresh_zioz_figpath = fullfile(backwardthreshdir, pixel_thresh_zioz_figname);
    pixel_thresh_zioz_titstr = ['Pixel Corrected Thresholded z(IOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(pixel_thresh_zioz_fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, pixel_thresh_zioz_titstr, pixel_thresh_zioz_figpath, timevec);

    % 3) cluster-based correction
    cluster_thresh_zioz_figname = ['thresh_408_cluster_IOZ_' gc_info{1}.seedstr '.png'];
    cluster_thresh_zioz_figpath = fullfile(backwardthreshdir, cluster_thresh_zioz_figname);
    cluster_thresh_zioz_titstr = ['Cluster Corrected Thresholded z(IOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(cluster_thresh_zioz_fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, cluster_thresh_zioz_titstr, cluster_thresh_zioz_figpath, timevec);

    % thresholded TFS analyses- nonIOZ
    [thresh_znonioz_fyx, pixel_thresh_znonioz_fyx, cluster_thresh_znonioz_fyx] = ...
        gc_shuffle_anal(allvals_Fyx, baselinevals_Fyx, noniozinds, shufflenum, noniozzscore_Fyx);

    % 1) no correction for multiple comparisons
    thresh_znonioz_figname = ['thresh_409_z_nonIOZ_' gc_info{1}.seedstr '.png'];
    thresh_znonioz_figpath = fullfile(backwardthreshdir, thresh_znonioz_figname);
    thresh_znonioz_titstr = ['Thresholded z(nonIOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(thresh_znonioz_fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, thresh_znonioz_titstr, thresh_znonioz_figpath, timevec);

    % 2) pixel-based correction
    pixel_thresh_znonioz_figname = ['thresh_410_pixel_nonIOZ_' gc_info{1}.seedstr '.png'];
    pixel_thresh_znonioz_figpath = fullfile(backwardthreshdir, pixel_thresh_znonioz_figname);
    pixel_thresh_znonioz_titstr = ['Pixel Corrected Thresholded z(nonIOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(pixel_thresh_znonioz_fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, pixel_thresh_znonioz_titstr, pixel_thresh_znonioz_figpath, timevec);

    % 3) cluster-based correction
    cluster_thresh_znonioz_figname = ['thresh_411_cluster_nonIOZ_' gc_info{1}.seedstr '.png'];
    cluster_thresh_znonioz_figpath = fullfile(backwardthreshdir, cluster_thresh_znonioz_figname);
    cluster_thresh_znonioz_titstr = ['Cluster Corrected Thresholded z(nonIOZ -> ' gc_info{1}.seedstr ')'];
    do_tfs_fig(cluster_thresh_znonioz_fyx, zclim, gc_info{1}.freqs, ...
               gc_info{1}.srate, cluster_thresh_znonioz_titstr, cluster_thresh_znonioz_figpath, timevec);

end



close all;
toc;

function [mean_fxy, mean_fyx, baseline_fxy, baseline_fyx, z_fxy, z_fyx] ...
        = do_roi_anal(dat_fxy, dat_fyx, baselinedat_fxy, baselinedat_fyx, inds)
mean_fxy = dat_fxy(inds,:,:);
mean_fyx = dat_fyx(inds,:,:);
baseline_fxy = baselinedat_fxy(inds,:,:);
baseline_fyx = baselinedat_fyx(inds,:,:);
z_fxy = do_zscore(squeeze(mean(mean_fxy, "omitnan")), squeeze(mean(baseline_fxy, "omitnan")));
z_fyx = do_zscore(squeeze(mean(mean_fyx, "omitnan")), squeeze(mean(baseline_fyx, "omitnan")));

function do_tfs_fig(dat, cl, freqs, srate, titstr, figpath, ...
                    timevec);
figure('visible', 'off'); 
imagesc(dat); 
axis xy;
colorbar; 
clim(cl);
yticklabels(freqs(yticks));
ylabel('Frequency (Hz)');
xtickvec = 511:2*srate:5001;
xticks(xtickvec);
xticklabels(timevec(xtickvec));
xlabel('Time (s)');
title(titstr);
print('-dpng', figpath);
