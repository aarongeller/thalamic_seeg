function do_fxy_plots(gc_info, figsdir, tfsclim, zclim, timevec);

if ~exist(figsdir, 'dir')
    mkdir(figsdir);
end

forwarddir = fullfile(figsdir, 'forward');
if ~exist(forwarddir, 'dir')
    mkdir(forwarddir);
end

backwarddir = fullfile(figsdir, 'backward');
if ~exist(backwarddir, 'dir')
    mkdir(backwarddir);
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

skipthese = {'SpO2' 'EtCO2' 'Pulse' 'CO2Wave' '$RPT11' '$RPT12' 'EKG1' ...
             'C451' 'C461' 'Annotations'};

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

iozmeanvals_Fxy = meanvals_Fxy(iozinds,:,:);
iozmeanvals_Fyx = meanvals_Fyx(iozinds,:,:);
iozbaselinemeans_Fxy = baselinemeans_Fxy(iozinds,:,:);
iozbaselinemeans_Fyx = baselinemeans_Fyx(iozinds,:,:);
iozzscore_Fxy = do_zscore(squeeze(mean(iozmeanvals_Fxy)), squeeze(mean(iozbaselinemeans_Fxy)));
iozzscore_Fyx = do_zscore(squeeze(mean(iozmeanvals_Fyx)), squeeze(mean(iozbaselinemeans_Fyx)));

noniozmeanvals_Fxy = meanvals_Fxy(noniozinds,:,:);
noniozmeanvals_Fyx = meanvals_Fyx(noniozinds,:,:);
noniozbaselinemeans_Fxy = baselinemeans_Fxy(noniozinds,:,:);
noniozbaselinemeans_Fyx = baselinemeans_Fyx(noniozinds,:,:);
noniozzscore_Fxy = do_zscore(squeeze(mean(noniozmeanvals_Fxy, "omitnan")), ...
                             squeeze(mean(noniozbaselinemeans_Fxy, "omitnan")));
noniozzscore_Fyx = do_zscore(squeeze(mean(noniozmeanvals_Fyx, "omitnan")), ...
                             squeeze(mean(noniozbaselinemeans_Fyx, "omitnan")));

[channel_names, inds] = sort(gc_info{1}.channel_names);

for i=1:elecs
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
% delete(ppm);

ioz_figname = ['200_' gc_info{1}.seedstr '_IOZ.png'];
ioz_figpath = fullfile(forwarddir, ioz_figname);
ioz_titstr = [gc_info{1}.seedstr ' -> IOZ'];
do_tfs_fig(squeeze(mean(iozmeanvals_Fxy, "omitnan")), tfsclim, gc_info{1}.freqs, ...
           gc_info{1}.srate, ioz_titstr, ioz_figpath, timevec);

zioz_figname = ['z_201_' gc_info{1}.seedstr '_IOZ.png'];
zioz_figpath = fullfile(forwarddir, zioz_figname);
zioz_titstr = ['z(' gc_info{1}.seedstr ' -> IOZ)'];
do_tfs_fig(iozzscore_Fxy, zclim, gc_info{1}.freqs, ...
    gc_info{1}.srate, zioz_titstr, zioz_figpath, timevec);

nonioz_figname = ['202_' gc_info{1}.seedstr '_nonIOZ.png'];
nonioz_figpath = fullfile(forwarddir, nonioz_figname);
nonioz_titstr = [gc_info{1}.seedstr ' -> nonIOZ'];
do_tfs_fig(squeeze(mean(noniozmeanvals_Fxy, "omitnan")), tfsclim, gc_info{1}.freqs, ...
           gc_info{1}.srate, nonioz_titstr, nonioz_figpath, timevec);

znonioz_figname = ['z_203_' gc_info{1}.seedstr '_nonIOZ.png'];
znonioz_figpath = fullfile(forwarddir, znonioz_figname);
znonioz_titstr = ['z(' gc_info{1}.seedstr ' -> nonIOZ)'];
do_tfs_fig(iozzscore_Fxy, zclim, gc_info{1}.freqs, ...
    gc_info{1}.srate, znonioz_titstr, znonioz_figpath, timevec);

zdiffioz_figname = ['zdiff_204_' gc_info{1}.seedstr '_IOZ.png'];
zdiffioz_figpath = fullfile(diffdir, zdiffioz_figname);
zdiffioz_titstr = ['z(IOZ -> ' gc_info{1}.seedstr ') - z(' gc_info{1}.seedstr ' -> IOZ)'];
do_tfs_fig(iozzscore_Fxy - iozzscore_Fyx, zclim, gc_info{1}.freqs, ...
           gc_info{1}.srate, zdiffioz_titstr, zdiffioz_figpath, timevec);

zdiffnonioz_figname = ['zdiff_205_' gc_info{1}.seedstr '_nonIOZ.png'];
zdiffnonioz_figpath = fullfile(diffdir, zdiffnonioz_figname);
zdiffnonioz_titstr = ['z(nonIOZ -> ' gc_info{1}.seedstr ') - z(' gc_info{1}.seedstr ' -> nonIOZ)'];
do_tfs_fig(noniozzscore_Fxy - noniozzscore_Fyx, zclim, gc_info{1}.freqs, ...
           gc_info{1}.srate, zdiffnonioz_titstr, zdiffnonioz_figpath, timevec);

% ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
%                         'showWorkerProgress', true, 'title', ...
%                         'Plotting Backward Connectivity');
for i=1:elecs
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
% delete(ppm);

ioz_figname = ['200_IOZ_' gc_info{1}.seedstr '.png'];
ioz_figpath = fullfile(backwarddir, ioz_figname);
ioz_titstr = ['IOZ -> ' gc_info{1}.seedstr];
do_tfs_fig(squeeze(mean(iozmeanvals_Fyx, "omitnan")), tfsclim, gc_info{1}.freqs, ...
           gc_info{1}.srate, ioz_titstr, ioz_figpath, timevec);

zioz_figname = ['z_201_IOZ_' gc_info{1}.seedstr '.png'];
zioz_figpath = fullfile(backwarddir, zioz_figname);
zioz_titstr = ['z(IOZ -> ' gc_info{1}.seedstr ')'];
do_tfs_fig(iozzscore_Fyx, zclim, gc_info{1}.freqs, ...
    gc_info{1}.srate, zioz_titstr, zioz_figpath, timevec);

nonioz_figname = ['202_nonIOZ_' gc_info{1}.seedstr '.png'];
nonioz_figpath = fullfile(backwarddir, nonioz_figname);
nonioz_titstr = ['nonIOZ -> ' gc_info{1}.seedstr];
do_tfs_fig(squeeze(mean(noniozmeanvals_Fyx, "omitnan")), tfsclim, gc_info{1}.freqs, ...
           gc_info{1}.srate, nonioz_titstr, nonioz_figpath, timevec);

znonioz_figname = ['z_203_nonIOZ_' gc_info{1}.seedstr '.png'];
znonioz_figpath = fullfile(backwarddir, znonioz_figname);
znonioz_titstr = ['z(nonIOZ -> ' gc_info{1}.seedstr ')'];
do_tfs_fig(noniozzscore_Fyx, zclim, gc_info{1}.freqs, ...
    gc_info{1}.srate, znonioz_titstr, znonioz_figpath, timevec);

close all;
toc;

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
