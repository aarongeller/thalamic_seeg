function preictal_comparison()

prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHGG/';

pre_1min_file = fullfile(prefix, 'UCHGG_25_08_23__21_20_17/timefreq_connect1_cohere_231231_1644.mat');
load(pre_1min_file);
pre_1min_TF = TF;

pre_1hr_file = fullfile(prefix, 'UCHGG_25_08_23__20_24_10/timefreq_connect1_cohere_231231_1939.mat');
load(pre_1hr_file);
pre_1hr_TF = TF;

pre_6hr_file = fullfile(prefix, 'UCHGG_25_08_23__15_23_23/timefreq_connect1_cohere_231231_1928.mat');
load(pre_6hr_file);
pre_6hr_TF = TF;

diff_1hr_1min = pre_1hr_TF - pre_1min_TF;
diff_6hr_1min = pre_6hr_TF - pre_1min_TF;

figure; imagesc(squeeze(mean(diff_1hr_1min, 2))'); axis xy; colorbar; 
clim([-0.3 0.3]);
% mylabs = RowNames(xticks);
labinds = 1:10:length(RowNames);
xticks(labinds);
mylabs = RowNames(labinds);
xticklabels(mylabs);
xtickangle(-90);
myfreqs = Freqs(yticks);
yticklabels(myfreqs);
title('Diff(Mean Imaginary Coherence) with RPI1 for 1 hour vs 1 min preictal');
ylabel('Frequency (Hz)');
xlabel('Channel');
print('-dpng', 'diff_1hr_1min');

figure; imagesc(squeeze(mean(diff_6hr_1min, 2))'); axis xy; colorbar;
clim([-0.3 0.3]);
% mylabs = RowNames(xticks);
labinds = 1:10:length(RowNames);
xticks(labinds);
mylabs = RowNames(labinds);
xticklabels(mylabs)
xtickangle(-90);
myfreqs = Freqs(yticks);
yticklabels(myfreqs);
title('Diff(Mean Imaginary Coherence) with RPI1 for 6 hours vs 1 min preictal');
ylabel('Frequency (Hz)');
xlabel('Channel');
print('-dpng', 'diff_6hr_1min');
