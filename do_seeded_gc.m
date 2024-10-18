function gc_info = do_seeded_gc(eegdata, srate, channelinfo, seedstr, startsample, ...
                                endsample, baseline_s)

if ~exist('baseline_s', 'var')
    baseline_s = 10;
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
else
    channel_names = {channelinfo.Name};
    [eegdata, channel_names, seednum] = exclude_channels(eegdata, channel_names, seedstr);
    windowlength = 100;
    order = 10; % order 20 for 200 Hz data gives half cycle of 5 Hz wave
    freqs = 5:5:srate/2;

    [Fxy, Fyx] = mov_bi_ga_seeded(eegdata', seednum, startsample, endsample, windowlength, ...
                                  order, srate, freqs);

    [Fxy_baseline, Fyx_baseline] = mov_bi_ga_seeded(eegdata', seednum, 1, round(srate*baseline_s), ...
                                                    windowlength, order, srate, freqs);
end

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

toc;
