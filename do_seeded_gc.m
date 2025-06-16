function gc_info = do_seeded_gc(eegdata, srate, channelinfo, seedstr, startsample, ...
                                endsample, baseline_s, freqs, windowlength, order)

if ~exist('baseline_s', 'var')
    baseline_s = 10;
end

if ~exist('freqs', 'var')
    freqs = 5:5:srate/2;
end

if ~exist('windowlength', 'var')
    windowlength = 100;
end

if ~exist('order', 'var')
    % order 20 for 200 Hz data gives half cycle of 5 Hz wave
    order = 10;
end

tic;

if size(eegdata, 1) ~= length(channelinfo)
    error('Channel info dimensions dont match EEG dimensions.  Exiting.');
end

if exist('debug', 'var') && debug==1
    startsample = 1;
    endsample = 15;
    windowlength = 10;
    order = 5;
    load('~/Documents/MATLAB/bsmart/test/test71_pre.mat');
    srate = 200;
    seednum = 9;
    seedstr = '9';
    freqs = 1:5:srate/2;

    [Fxy, Fyx] = mov_bi_ga_seeded(dat, seednum, startsample, endsample, windowlength, ...
                                  order, srate, freqs);
elseif ~isempty(seedstr)
    channel_names = {channelinfo.Name};
    [eegdata, channel_names, seednum] = exclude_channels(eegdata, channel_names, seedstr);

    % Fxy is l x m x n
    % where l = num channels (seed -> all channels)
    % m = num freqs
    % n = num samples

    [Fxy, Fyx] = mov_bi_ga_seeded(eegdata', seednum, startsample, endsample, windowlength, ...
                                  order, srate, freqs);

    [Fxy_baseline, Fyx_baseline] = mov_bi_ga_seeded(eegdata', seednum, 1, round(srate*baseline_s), ...
                                                    windowlength, order, srate, freqs);
else
    % for RNS analyses: do all channels

    result_samples = endsample - startsample - windowlength + 2;
    bl_samples = round(srate*baseline_s) - windowlength + 1;

    Fxy = zeros(6, length(freqs), result_samples);
    Fyx = zeros(6, length(freqs), result_samples);
    Fxy_baseline = zeros(6, length(freqs), bl_samples);
    Fyx_baseline = zeros(6, length(freqs), bl_samples);

    lastind = 0;
    for i=1:3
        numpairs = 4-i;

        [Fxytemp, Fyxtemp] = mov_bi_ga_seeded(eegdata(i:end,:)', 1, startsample, endsample, windowlength, ...
                                              order, srate, freqs);
        Fxy(i+lastind:i+lastind+numpairs-1,:,:) = Fxytemp(2:end,:,:);
        Fyx(i+lastind:i+lastind+numpairs-1,:,:) = Fyxtemp(2:end,:,:);

        [Fxybltemp, Fyxbltemp] = mov_bi_ga_seeded(eegdata(i:end,:)', 1, 1, round(srate*baseline_s), ...
                                                  windowlength, order, srate, freqs);
        Fxy_baseline(i+lastind:i+lastind+numpairs-1,:,:) = Fxybltemp(2:end,:,:);
        Fyx_baseline(i+lastind:i+lastind+numpairs-1,:,:) = Fyxbltemp(2:end,:,:);

        lastind = lastind + numpairs - 1;
    end

    seedstr = [];
    channel_names = channelinfo;
end

tfs = mywavconv(eegdata, srate, freqs);
tfs_pow_all = abs(squeeze(tfs)).^2;
tfs_pow_baseline = tfs_pow_all(:, 1:bl_samples, :);
tfs_pow = tfs_pow_all(:, startsample:(result_samples+startsample-1), :);
tfs_pow = permute(tfs_pow, [1 3 2]);
tfs_pow_baseline = permute(tfs_pow_baseline, [1 3 2]);

timepts = size(Fxy,3);
timevec = (startsample:(startsample+timepts-1))./srate;

gc_info = [];
gc_info.timevec = timevec;
gc_info.eegdata = eegdata;
gc_info.Fxy = Fxy;
gc_info.Fyx = Fyx;
gc_info.Fxy_baseline = Fxy_baseline;
gc_info.Fyx_baseline = Fyx_baseline;
gc_info.srate = srate;
gc_info.channel_names = channel_names;
gc_info.seedstr = seedstr;
gc_info.windowlength = windowlength;
gc_info.order = order;
gc_info.freqs = freqs;
gc_info.tfs_pow = tfs_pow;
gc_info.tfs_pow_baseline = tfs_pow_baseline;

toc;
