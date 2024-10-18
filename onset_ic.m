function onset_ic(subj, doraw, doz, doioz, onsetmode, srate, halfwindow_s)

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

if ~exist('srate', 'var')
    srate = 250;
end

if ~exist('halfwindow_s', 'var')
    halfwindow_s = 10;
end

prefix = fullfile('/Users/aaron/Documents/brainstorm_db/IEEG_Visualization/data', ...
                  subj, [subj '_']);

switch subj
  case 'UCHGG'
    onset_sz = {'25_08_23__21_20_17/timefreq_connect1_cohere_241010_1821.mat' ...
                '26_08_23__10_48_33/timefreq_connect1_cohere_241010_1826.mat' ...
                '26_08_23__14_25_10/timefreq_connect1_cohere_241010_1831.mat' ...
                '26_08_23__17_39_05/timefreq_connect1_cohere_241010_1836.mat' ...
                '27_08_23__10_54_38/timefreq_connect1_cohere_241010_1839.mat' ...
                '27_08_23__16_28_57/timefreq_connect1_cohere_241010_1843.mat' ...
                '28_08_23__03_25_43/timefreq_connect1_cohere_241010_1845.mat' ...
                '28_08_23__10_53_25/timefreq_connect1_cohere_241010_1848.mat' ...
                '28_08_23__14_43_42/timefreq_connect1_cohere_241010_1851.mat' ...
                '28_08_23__16_28_59/timefreq_connect1_cohere_241010_1854.mat' ...
                '28_08_23__16_51_19/timefreq_connect1_cohere_241010_2007.mat' ...
                '28_08_23__20_01_37/timefreq_connect1_cohere_241010_1900.mat' ...
                '29_08_23__05_42_28/timefreq_connect1_cohere_241010_1903.mat' ...
                '29_08_23__11_03_18/timefreq_connect1_cohere_241010_1905.mat' ...
                '29_08_23__16_01_13/timefreq_connect1_cohere_241010_1908.mat' ...
                '29_08_23__19_22_41/timefreq_connect1_cohere_241010_1911.mat'};

    onset_times = [83 83.9 86.4 82.5 69.6 69.6 83.8 69.9 93.6 83.7 83.7 ...
                   72 68.4 83.1 70.3 76.5];

    offset_sz = {'25_08_23__21_20_17/timefreq_connect1_cohere_241010_1820.mat' ...
                 '26_08_23__10_48_33/timefreq_connect1_cohere_241010_1827.mat' ...
                 '26_08_23__14_25_10/timefreq_connect1_cohere_241010_1832.mat' ...
                 '26_08_23__17_39_05/timefreq_connect1_cohere_241010_1837.mat' ...
                 '27_08_23__10_54_38/timefreq_connect1_cohere_241010_1840.mat' ...
                 '27_08_23__16_28_57/timefreq_connect1_cohere_241010_1844.mat' ...
                 '28_08_23__03_25_43/timefreq_connect1_cohere_241010_1846.mat' ...
                 '28_08_23__10_53_25/timefreq_connect1_cohere_241010_1849.mat' ...
                 '28_08_23__14_43_42/timefreq_connect1_cohere_241010_1852.mat' ...
                 '28_08_23__16_28_59/timefreq_connect1_cohere_241010_1855.mat' ...
                 '28_08_23__16_51_19/timefreq_connect1_cohere_241010_2008.mat' ...
                 '28_08_23__20_01_37/timefreq_connect1_cohere_241010_1901.mat' ...
                 '29_08_23__05_42_28/timefreq_connect1_cohere_241010_1904.mat' ...
                 '29_08_23__11_03_18/timefreq_connect1_cohere_241010_1906.mat' ...
                 '29_08_23__16_01_13/timefreq_connect1_cohere_241010_1909.mat' ...
                 '29_08_23__19_22_41/timefreq_connect1_cohere_241010_1912.mat'};

    offset_times = [180 190.2 110.8 108 180 171 214.8 151.6 383 ...
                    112 130 130 123.9 185.1 175.2 194.9]; % first 130 probably not right

    ioz = {'RAH1', 'RAH2', 'RAH3', 'RPH1', 'RPH2', 'RPH3'};
    seedstr = 'RPI1';
  case 'UCHVG'
    onset_sz = {'25_07_23__03_33_09/timefreq_connect1_cohere_241011_1940.mat' ...
                '25_07_23__05_04_19/timefreq_connect1_cohere_241011_1938.mat' ...
                '25_07_23__06_19_48/timefreq_connect1_cohere_241011_2030.mat'};

    onset_times = [83.4 82.3 82.6];

    offset_sz = {'25_07_23__03_33_09/timefreq_connect1_cohere_241011_1941.mat' ...
                 '25_07_23__05_04_19/timefreq_connect1_cohere_241011_1939.mat' ...
                 '25_07_23__06_19_48/timefreq_connect1_cohere_241011_2031.mat'};

    offset_times = [171 179 172.9];

    ioz = {'LAH1', 'LAH2', 'LAH3', 'LAH4'};
    seedstr = 'LANT1';
  case 'UCHAK'
    onset_sz_p1 = {'06_04_24__09_39_50/timefreq_connect1_cohere_241012_1018.mat' ...
               };

    offset_sz_p1 = {'06_04_24__09_39_50/timefreq_connect1_cohere_241012_1019.mat' ...
                };

end

if onsetmode
    allsz = onset_sz;
    t = onset_times;
    figsubdir = 'IC_mean_tfs_onset';
else
    allsz = offset_sz;
    t = offset_times;
    figsubdir = 'IC_mean_tfs_offset';
end

figsdir = fullfile('analyses', subj, 'figs', figsubdir);

load([prefix allsz{1}]);
elecs = size(TF,1);
freqs = size(TF,3);
timepts = size(TF,2);

timevec = (-srate*halfwindow_s:(srate*halfwindow_s + 1))./srate;

allvals = nan(elecs, length(allsz), freqs, srate*2*halfwindow + 1);
meanvals = nan(elecs, freqs, srate*2*halfwindow + 1);
zvals = nan(size(meanvals));
iozzvals = nan(size(meanvals));
noniozzvals = nan(size(meanvals));
baselinevals = nan(elecs, length(allsz), freqs, srate*halfwindow_s);
baselinemeans = nan(elecs, freqs, srate*halfwindow_s);
zscore_clim = [-3 3];

skipthese = {'SpO2' 'EtCO2' 'Pulse' 'CO2Wave' '$RPT11' '$RPT12' 'EKG1' ...
             'C451' 'C461' 'Annotations'};

for i=1:length(allsz)
    % for every sz
    load([prefix allsz{i}]);
    
    % select 20 sec around onset time
    onset_sample = min(find(Time >= t(i)));
    selected_interval = TF(:, onset_sample-srate*halfwindow_s:onset_sample+srate*halfwindow_s, :);

    % for every elec, get tfs centered at onset
    for j=1:elecs
        allvals(j,i,:,:) = squeeze(selected_interval(j,:,:))';
        baselinevals(j,i,:,:) = squeeze(selected_interval(j,1:srate*halfwindow_s,:))';
    end
end

badinds = get_matching_inds(RowNames, skipthese);
goodinds = setdiff(1:elecs, badinds);

iozinds = get_matching_inds(RowNames, ioz);
noniozinds = setdiff(1:elecs, iozinds);

for i=1:elecs
    if length(find(badinds==i))>0
        continue
    else
        meanvals(i,:,:) = squeeze(mean(allvals(i,:,:,:), "omitnan"));
        baselinemeans(i,:,:) = squeeze(mean(baselinevals(i,:,:,:), "omitnan"));
        zvals(i,:,:) = do_zscore(squeeze(meanvals(i,:,:)), squeeze(baselinemeans(i,:,:)));
    end
end

iozmeanvals = meanvals(iozinds,:,:);
iozbaselinemeans = baselinemeans(iozinds,:,:);
iozzscore = do_zscore(squeeze(mean(iozmeanvals)), squeeze(mean(iozbaselinemeans)));
noniozmeanvals = meanvals(noniozinds,:,:);
noniozbaselinemeans = baselinemeans(noniozinds,:,:);
noniozzscore = do_zscore(squeeze(mean(noniozmeanvals, "omitnan")), ...
                         squeeze(mean(noniozbaselinemeans, "omitnan")));

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
            title([seedstr '-' RowNames{i} ' IC']);
            print('-dpng', fullfile(figsdir, [seedstr '_' RowNames{i}]));
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
            title([seedstr '-' RowNames{i} ' z(IC)']);
            print('-dpng', fullfile(figsdir, [seedstr '_' RowNames{i} '_zscore']));
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
    title([seedstr '-IOZ mean IC']);
    print('-dpng', fullfile(figsdir, [seedstr '_ioz']));
    close(h);

    h = figure('visible', 'off');
    imagesc(iozzscore); axis xy; clim([-3 3]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title([seedstr '-IOZ mean z(IC)']);
    print('-dpng', fullfile(figsdir, [seedstr '_ioz_zscore']));
    close(h);

    h = figure('visible', 'off');
    thismat = squeeze(mean(noniozmeanvals, "omitnan"));
    imagesc(thismat); axis xy; clim([0 1]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title([seedstr '-nonIOZ mean IC']);
    print('-dpng', fullfile(figsdir, [seedstr '_nonioz']));
    close(h);

    h = figure('visible', 'off');
    imagesc(noniozzscore); axis xy; clim([-3 3]);
    colorbar;
    xticklabels(timevec(501:500:end));
    yticklabels(Freqs(5:5:end));
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title([seedstr '-nonIOZ mean z(IC)']);
    print('-dpng', fullfile(figsdir, [seedstr '_nonioz_zscore']));
    close(h);
end

system(['python make_ic_pdf.py ' subj ' ' figsubdir]);
