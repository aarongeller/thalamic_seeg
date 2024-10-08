function onset_ic(doraw, doz, doioz)

if ~exist('doraw', 'var')
    doraw = 1;
end

if ~exist('doz', 'var')
    doz = 1;
end

if ~exist('doioz', 'var')
    doioz = 1;
end

prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_Visualization/data';
sz1 =  'UCHGG/UCHGG_25_08_23__21_20_17/timefreq_connect1_cohere_241005_1150.mat';
sz2 =  'UCHGG/UCHGG_26_08_23__10_48_33/timefreq_connect1_cohere_241005_1156.mat';
sz3 =  'UCHGG/UCHGG_26_08_23__14_25_10/timefreq_connect1_cohere_241005_1159.mat';
sz4 =  'UCHGG/UCHGG_26_08_23__17_39_05/timefreq_connect1_cohere_241005_1203.mat';
sz5 =  'UCHGG/UCHGG_27_08_23__10_54_38/timefreq_connect1_cohere_241005_1214.mat';
sz6 =  'UCHGG/UCHGG_27_08_23__16_28_57/timefreq_connect1_cohere_241005_1222.mat';
sz7 =  'UCHGG/UCHGG_28_08_23__03_25_43/timefreq_connect1_cohere_241005_1231.mat';
sz8 =  'UCHGG/UCHGG_28_08_23__10_53_25/timefreq_connect1_cohere_241005_1245.mat';
sz9 =  'UCHGG/UCHGG_28_08_23__14_43_42/timefreq_connect1_cohere_241005_1254.mat';
sz10 =  'UCHGG/UCHGG_28_08_23__16_28_59/timefreq_connect1_cohere_241005_1316.mat';
sz11 =  'UCHGG/UCHGG_28_08_23__16_51_19/timefreq_connect1_cohere_241005_1304.mat';
sz12 =  'UCHGG/UCHGG_28_08_23__20_01_37/timefreq_connect1_cohere_241005_1346.mat';
sz13 =  'UCHGG/UCHGG_29_08_23__05_42_28/timefreq_connect1_cohere_241005_1357.mat';
sz14 =  'UCHGG/UCHGG_29_08_23__11_03_18/timefreq_connect1_cohere_241005_1404.mat';
sz15 =  'UCHGG/UCHGG_29_08_23__16_01_13/timefreq_connect1_cohere_241005_1410.mat';
sz16 =  'UCHGG/UCHGG_29_08_23__19_22_41/timefreq_connect1_cohere_241005_1420.mat';

allsz = {sz1 sz2 sz3 sz4 sz5 sz6 sz7 sz8 sz9 sz10 sz11 sz12 sz13 sz14 sz15 sz16};
onset_times = [83 83.9 86.4 82.5 69.6 69.6 83.8 69.9 93.6 83.7 83.7 ...
               72 68.4 83.1 70.3 76.5];
    
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
    onset_sample = min(find(Time>=onset_times(i)));
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

figsdir = 'analyses/UCHGG/figs/IC_mean_tfs';
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
