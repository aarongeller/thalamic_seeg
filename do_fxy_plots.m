function do_fxy_plots(gc_info, offset, figsdir)

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

tic;

p = gcp;
total = size(gc_info.Fxy,1);
ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
                        'showWorkerProgress', true, 'title', ...
                        'Plotting Forward Connectivity');

baseline_secs = 15;
zFxy = do_zscore(gc_info.Fxy, 1:gc_info.srate*baseline_secs);
zFyx = do_zscore(gc_info.Fyx, 1:gc_info.srate*baseline_secs);

[channel_names, inds] = sort(gc_info.channel_names);

parfor i=1:size(gc_info.Fxy,1)
    figname = [sprintf('%03d', i) '_' gc_info.seedstr '_' channel_names{i} '.png'];
    figpath = fullfile(forwarddir, figname);
    titstr = [gc_info.seedstr ' -> ' channel_names{i}];
    do_tfs_fig(squeeze(gc_info.Fxy(inds(i),:,:)), [0 3], gc_info.freqs, gc_info.srate, offset, titstr, figpath);

    zfigname = ['z_' sprintf('%03d', i) '_' gc_info.seedstr '_' channel_names{i} '.png'];
    zfigpath = fullfile(forwarddir, zfigname);
    ztitstr = ['Z-Score ' gc_info.seedstr ' -> ' channel_names{i}];
    do_tfs_fig(squeeze(zFxy(inds(i),:,:)), [-15 15], gc_info.freqs, gc_info.srate, offset, ...
               ztitstr, zfigpath);

    pause(100/total);
    ppm.increment();
end
delete(ppm);

ppm = ParforProgressbar(total, 'parpool', {'local', 4}, ...
                        'showWorkerProgress', true, 'title', ...
                        'Plotting Backward Connectivity');
parfor i=1:size(gc_info.Fyx,1)
    figname = [sprintf('%03d', i) '_' channel_names{i} '_' gc_info.seedstr '.png'];
    figpath = fullfile(backwarddir, figname);
    titstr = [channel_names{i} ' -> ' gc_info.seedstr];
    do_tfs_fig(squeeze(gc_info.Fyx(inds(i),:,:)), [0 3], gc_info.freqs, gc_info.srate, offset, titstr, figpath);

    zfigname = ['z_' sprintf('%03d', i) '_' channel_names{i} '_' gc_info.seedstr '.png'];
    zfigpath = fullfile(backwarddir, zfigname);
    ztitstr = ['Z-Score ' channel_names{i} ' -> ' gc_info.seedstr];
    do_tfs_fig(squeeze(zFyx(inds(i),:,:)), [-15 15], gc_info.freqs, gc_info.srate, offset, ...
               ztitstr, zfigpath);

    pause(100/total);
    ppm.increment();
end
delete(ppm);

close all;
toc;

function do_tfs_fig(dat, cl, freqs, srate, offset, titstr, figpath)
figure('visible', 'off'); 
imagesc(dat); 
axis xy;
colorbar; 
clim(cl);
% if ~exist('isz', 'var') || isz==0
%     clim(cl);
% end
yticklabels(freqs(yticks));
ylabel('Frequency (Hz)');
xtickvals = offset + xticks/srate;
xticklabs = split(strtrim(sprintf('%2.2f ', xtickvals)));
xticklabels(xticklabs);
xlabel('Time (s)');
title(titstr);
print('-dpng', figpath);


function m2 = do_zscore(m1, inds)
m2 = zeros(size(m1));

for i=1:size(m1,1)
    for j=1:size(m1,2)
        s = std(m1(i,j,inds));
        m = mean(m1(i,j,inds));
        m2(i,j,:) = (m1(i,j,:) - m)./s;
    end
end
