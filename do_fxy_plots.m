function do_fxy_plots(gc_info, offset, figsdir, tfsclim, zclim, ...
                      sz_onset_s, sz_offset_s)

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

if ~exist('sz_onset_s', 'var')
    sz_onset_s = nan;
end

if ~exist('sz_offset_s', 'var')
    sz_offset_s = nan;
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
    do_tfs_fig(squeeze(gc_info.Fxy(inds(i),:,:)), tfsclim, gc_info.freqs, ...
               gc_info.srate, offset, titstr, figpath, sz_onset_s, sz_offset_s);

    zfigname = ['z_' sprintf('%03d', i) '_' gc_info.seedstr '_' channel_names{i} '.png'];
    zfigpath = fullfile(forwarddir, zfigname);
    ztitstr = ['Z-Score ' gc_info.seedstr ' -> ' channel_names{i}];
    do_tfs_fig(squeeze(zFxy(inds(i),:,:)), zclim, gc_info.freqs, gc_info.srate, offset, ...
               ztitstr, zfigpath, sz_onset_s, sz_offset_s);

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
    do_tfs_fig(squeeze(gc_info.Fyx(inds(i),:,:)), tfsclim, gc_info.freqs, ...
               gc_info.srate, offset, titstr, figpath, sz_onset_s, sz_offset_s);

    zfigname = ['z_' sprintf('%03d', i) '_' channel_names{i} '_' gc_info.seedstr '.png'];
    zfigpath = fullfile(backwarddir, zfigname);
    ztitstr = ['Z-Score ' channel_names{i} ' -> ' gc_info.seedstr];
    do_tfs_fig(squeeze(zFyx(inds(i),:,:)), zclim, gc_info.freqs, gc_info.srate, offset, ...
               ztitstr, zfigpath, sz_onset_s, sz_offset_s);

    pause(100/total);
    ppm.increment();
end
delete(ppm);

close all;
toc;

function do_tfs_fig(dat, cl, freqs, srate, offset, titstr, figpath, ...
                    sz_onset_s, sz_offset_s)
figure('visible', 'off'); 
imagesc(dat); 
axis xy;
colorbar; 
clim(cl);
num_samples_x = size(dat,2);
num_samples_y = size(dat,1);
dur_s = num_samples_x/srate;
sz_onset_x = num_samples_x*(sz_onset_s - offset)/dur_s;
sz_offset_x = num_samples_x*(sz_offset_s - offset)/dur_s;
lwid = 4;
if ~isnan(sz_onset_s)
    hold on;
    plot([sz_onset_x sz_onset_x], [1 num_samples_y], 'g--', 'linewidth', ...
         lwid);
    hold off;
end
if ~isnan(sz_offset_s)
    hold on;
    plot([sz_offset_x sz_offset_x], [1 num_samples_y], 'r--', 'linewidth', ...
         lwid);
    hold off;
end

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
