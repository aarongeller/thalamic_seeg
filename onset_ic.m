function onset_ic(doraw, doz, doioz, onsetmode)

if ~exist('doraw', 'var')
    doraw = 1;
end

if ~exist('doz', 'var')
    doz = 1;
end

if ~exist('doioz', 'var')
    doioz = 1;
end

if ~exist('onsetmode', 'var')
    onsetmode = 1;
end

prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_Visualization/data';
onset_sz1 =  'UCHGG/UCHGG_25_08_23__21_20_17/timefreq_connect1_cohere_241010_1821.mat';
onset_sz2 =  'UCHGG/UCHGG_26_08_23__10_48_33/timefreq_connect1_cohere_241010_1826.mat';
onset_sz3 =  'UCHGG/UCHGG_26_08_23__14_25_10/timefreq_connect1_cohere_241010_1831.mat';
onset_sz4 =  'UCHGG/UCHGG_26_08_23__17_39_05/timefreq_connect1_cohere_241010_1836.mat';
onset_sz5 =  'UCHGG/UCHGG_27_08_23__10_54_38/timefreq_connect1_cohere_241010_1839.mat';
onset_sz6 =  'UCHGG/UCHGG_27_08_23__16_28_57/timefreq_connect1_cohere_241010_1843.mat';
onset_sz7 =  'UCHGG/UCHGG_28_08_23__03_25_43/timefreq_connect1_cohere_241010_1845.mat';
onset_sz8 =  'UCHGG/UCHGG_28_08_23__10_53_25/timefreq_connect1_cohere_241010_1848.mat';
onset_sz9 =  'UCHGG/UCHGG_28_08_23__14_43_42/timefreq_connect1_cohere_241010_1851.mat';
onset_sz10 =  'UCHGG/UCHGG_28_08_23__16_28_59/timefreq_connect1_cohere_241010_1854.mat';
onset_sz11 =  'UCHGG/UCHGG_28_08_23__16_51_19/timefreq_connect1_cohere_241010_2007.mat';
onset_sz12 =  'UCHGG/UCHGG_28_08_23__20_01_37/timefreq_connect1_cohere_241010_1900.mat';
onset_sz13 =  'UCHGG/UCHGG_29_08_23__05_42_28/timefreq_connect1_cohere_241010_1903.mat';
onset_sz14 =  'UCHGG/UCHGG_29_08_23__11_03_18/timefreq_connect1_cohere_241010_1905.mat';
onset_sz15 =  'UCHGG/UCHGG_29_08_23__16_01_13/timefreq_connect1_cohere_241010_1908.mat';
onset_sz16 =  'UCHGG/UCHGG_29_08_23__19_22_41/timefreq_connect1_cohere_241010_1911.mat';

onset_times = [83 83.9 86.4 82.5 69.6 69.6 83.8 69.9 93.6 83.7 83.7 ...
               72 68.4 83.1 70.3 76.5];

% offset
offset_sz1 =  'UCHGG/UCHGG_25_08_23__21_20_17/timefreq_connect1_cohere_241010_1820.mat';
offset_sz2 =  'UCHGG/UCHGG_26_08_23__10_48_33/timefreq_connect1_cohere_241010_1827.mat';
offset_sz3 =  'UCHGG/UCHGG_26_08_23__14_25_10/timefreq_connect1_cohere_241010_1832.mat';
offset_sz4 =  'UCHGG/UCHGG_26_08_23__17_39_05/timefreq_connect1_cohere_241010_1837.mat';
offset_sz5 =  'UCHGG/UCHGG_27_08_23__10_54_38/timefreq_connect1_cohere_241010_1840.mat';
offset_sz6 =  'UCHGG/UCHGG_27_08_23__16_28_57/timefreq_connect1_cohere_241010_1844.mat';
offset_sz7 =  'UCHGG/UCHGG_28_08_23__03_25_43/timefreq_connect1_cohere_241010_1846.mat';
offset_sz8 =  'UCHGG/UCHGG_28_08_23__10_53_25/timefreq_connect1_cohere_241010_1849.mat';
offset_sz9 =  'UCHGG/UCHGG_28_08_23__14_43_42/timefreq_connect1_cohere_241010_1852.mat';
offset_sz10 =  'UCHGG/UCHGG_28_08_23__16_28_59/timefreq_connect1_cohere_241010_1855.mat';
offset_sz11 =  'UCHGG/UCHGG_28_08_23__16_51_19/timefreq_connect1_cohere_241010_2008.mat';
offset_sz12 =  'UCHGG/UCHGG_28_08_23__20_01_37/timefreq_connect1_cohere_241010_1901.mat';
offset_sz13 =  'UCHGG/UCHGG_29_08_23__05_42_28/timefreq_connect1_cohere_241010_1904.mat';
offset_sz14 =  'UCHGG/UCHGG_29_08_23__11_03_18/timefreq_connect1_cohere_241010_1906.mat';
offset_sz15 =  'UCHGG/UCHGG_29_08_23__16_01_13/timefreq_connect1_cohere_241010_1909.mat';
offset_sz16 =  'UCHGG/UCHGG_29_08_23__19_22_41/timefreq_connect1_cohere_241010_1912.mat';

offset_times = [180 190.2 110.8 108 180 171 214.8 151.6 383 ...
                112 130 130 123.9 185.1 175.2 194.9]; % first 130 probably not right

if onsetmode
    allsz = {onset_sz1 onset_sz2 onset_sz3 onset_sz4 onset_sz5 onset_sz6 onset_sz7 ...
             onset_sz8 onset_sz9 onset_sz10 onset_sz11 onset_sz12 onset_sz13 ...
             onset_sz14 onset_sz15 onset_sz16};
    t = onset_times;
    figsdir = 'analyses/UCHGG/figs/IC_mean_tfs_onset';
else
    allsz = {offset_sz1 offset_sz2 offset_sz3 offset_sz4 offset_sz5 offset_sz6 offset_sz7 ...
             offset_sz8 offset_sz9 offset_sz10 offset_sz11 offset_sz12 offset_sz13 ...
             offset_sz14 offset_sz15 offset_sz16};
    t = offset_times;
    figsdir = 'analyses/UCHGG/figs/IC_mean_tfs_offset';
end

load(fullfile(prefix, allsz{1}));
elecs = size(TF,1);
freqs = size(TF,3);
timepts = size(TF,2);

srate = 200;
timevec = (-srate*10:(srate*10 + 1))./srate;

allvals = nan(elecs, length(allsz), freqs, srate*20 + 1);
meanvals = nan(elecs, freqs, srate*20 + 1);
zvals = nan(size(meanvals));
iozzvals = nan(size(meanvals));
noniozzvals = nan(size(meanvals));
baselinevals = nan(elecs, length(allsz), freqs, srate*10);
baselinemeans = nan(elecs, freqs, srate*10);
zscore_clim = [-3 3];

skipthese = {'SpO2' 'EtCO2' 'Pulse' 'CO2Wave' '$RPT11' '$RPT12' 'EKG1' ...
             'C451' 'C461' 'Annotations'};

ioz = {'RAH1', 'RAH2', 'RAH3', 'RPH1', 'RPH2', 'RPH3'};

for i=1:length(allsz)
    % for every sz
    load(fullfile(prefix, allsz{i}));
    
    % select 20 sec around onset time
    onset_sample = min(find(Time >= t(i)));
    selected_interval = TF(:, onset_sample-srate*10:onset_sample+srate*10, :);

    % for every elec, get tfs centered at onset
    for j=1:elecs
        allvals(j,i,:,:) = squeeze(selected_interval(j,:,:))';
        baselinevals(j,i,:,:) = squeeze(selected_interval(j,1:srate*10,:))';
    end
end

badinds = get_bad_inds(RowNames, skipthese);
goodinds = setdiff(1:elecs, badinds);

iozinds = get_bad_inds(RowNames, ioz);
noniozinds = setdiff(1:elecs, iozinds);

for i=1:elecs
    if length(find(badinds==i))>0
        continue
    else
        meanvals(i,:,:) = squeeze(mean(allvals(i,:,:,:), "omitnan"));
        baselinemeans(i,:,:) = squeeze(mean(baselinevals(i,:,:,:), "omitnan"));
        zvals(i,:,:) = do_zscore(squeeze(meanvals(i,:,:)), squeeze(baselinemeans(i,:,:)));
        if length(find(iozinds==i))>0
            iozzvals(i,:,:) = zvals(i,:,:);
        else
            noniozzvals(i,:,:) = zvals(i,:,:);
        end
    end
end

iozmeanvals = meanvals(iozinds,:,:);
noniozmeanvals = meanvals(noniozinds,:,:);

if ~exist(figsdir, 'dir')
    mkdir(figsdir);
end

for i=1:length(RowNames)
    if any(strcmp(RowNames{i}, skipthese))
        continue;
    else
        if doraw
            % raw plot
            h = figure('visible', 'off');
            thismat = squeeze(meanvals(i,:,:));
            imagesc(thismat); axis xy; clim([0 1]);
            colorbar;        
            xticklabels(timevec(501:500:end));
            yticklabels(Freqs(5:5:end));
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            title(['RPI1-' RowNames{i} ' IC']);
            print('-dpng', fullfile(figsdir, ['RPI1_' RowNames{i}]));
            close(h);
        end
        
        if doz
            % zscore
            h = figure('visible', 'off');
            thismat = squeeze(zvals(i,:,:));
            imagesc(thismat); axis xy; clim(zscore_clim);
            colorbar;        
            xticklabels(timevec(501:500:end));
            yticklabels(Freqs(5:5:end));
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            title(['RPI1-' RowNames{i} ' z(IC)']);
            print('-dpng', fullfile(figsdir, ['RPI1_' RowNames{i} '_zscore']));
            close(h);
        end
    end
end

if doioz
    h = figure('visible', 'off');
    thismat = squeeze(mean(iozmeanvals, "omitnan"));
    imagesc(thismat); axis xy; clim([0 1]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(['RPI1-IOZ mean IC']);
    print('-dpng', fullfile(figsdir, ['RPI1_ioz']));
    close(h);

    h = figure('visible', 'off');
    thismat = squeeze(mean(iozzvals, "omitnan"));
    imagesc(thismat); axis xy; clim([-3 3]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(['RPI1-IOZ mean z(IC)']);
    print('-dpng', fullfile(figsdir, ['RPI1_ioz_zscore']));
    close(h);

    h = figure('visible', 'off');
    thismat = squeeze(mean(noniozmeanvals, "omitnan"));
    imagesc(thismat); axis xy; clim([0 1]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(['RPI1-nonIOZ mean IC']);
    print('-dpng', fullfile(figsdir, ['RPI1_nonioz']));
    close(h);

    h = figure('visible', 'off');
    thismat = squeeze(mean(noniozzvals, "omitnan"));
    imagesc(thismat); axis xy; clim([-3 3]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title(['RPI1-nonIOZ mean z(IC)']);
    print('-dpng', fullfile(figsdir, ['RPI1_nonioz_zscore']));
    close(h);
end


function zmat = do_zscore(valmat, blmat)
zmat = zeros(size(valmat));
for i=1:size(zmat,1)
    s = std(blmat(i,:));
    m = mean(blmat(i,:));
    if s>10^-6
        zmat(i,:) = (valmat(i,:) - m)./s;
    end
end

function b = get_bad_inds(r, skipthese)
temp = [];
for i=1:length(skipthese)
    temp(end+1,:) = strcmp(r, skipthese{i});
end
b = find(any(temp));
