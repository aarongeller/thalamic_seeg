function do_gc_anal(subj, cond, overwrite_all_figs, overwrite_ioz_figs, ...
                    overwrite_data, overwrite_all_data, tfsclim, ...
                    clim, srate, halfwindow_s)

if ~exist('overwrite_all_figs', 'var')
    overwrite_all_figs = 1;
end

if ~exist('overwrite_ioz_figs', 'var')
    overwrite_ioz_figs = 1;
end

if ~exist('overwrite_data', 'var')
    overwrite_data = 0;
end

if ~exist('overwrite_all_data', 'var')
    overwrite_all_data = 0;
end

if ~exist('tfsclim', 'var')
    tfsclim = [0 1];
end

if ~exist('zclim', 'var')
    zclim = [-5 5];
end

if ~exist('srate', 'var')
    srate = 250;
end

if ~exist('halfwindow_s', 'var')
    halfwindow_s = 10;
end

hasshort = {'UCHSN230406' 'UCHGG230823' 'UCHVG230719' 'UCHDR220801' ...
            'UCHAK240403'};
if any(strcmp(subj, hasshort))
    longsubj = subj;
    subj = subj(1:5);
end

datapath = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/';

prefix = fullfile(datapath, [subj '/' subj '_']);

outputdir = ['granger_' cond];
analdir = fullfile('analyses', subj);
figsdir = fullfile(analdir, 'figs', outputdir);

info = get_sz_info(longsubj);

seedstr = info.seedstr;
ioz = info.ioz;
eegfiles = info.eegfiles;
sz_onset_s = info.ioz;

channeldirpart = fileparts(eegfiles{1});

load(fullfile([prefix channeldirpart], 'channel.mat'));

% select 20 sec around onset time
order = 10; % need to pad beginning by this many samples

varname =  [subj '_gcinfo_' cond];
filename = [varname '.mat'];
datapath = fullfile("analyses", subj, filename);

samplevec = (round(-srate*halfwindow_s) - order):round(srate*halfwindow_s);
timevec = samplevec./srate;

% compute gc if necessary
if overwrite_data
    if ~exist(datapath, 'file') || overwrite_all_data
        gc_info.files = {};
        gc_info.data = {};

        if ~exist(analdir, 'dir')
            mkdir(analdir);
        end
    else
        load(datapath);
        eval(['gc_info = ' varname ';']);
    end
    for i=1:length(eegfiles)
        d = fprintf('%s ', datetime("now"));
        fprintf([d int2str(i) '/' int2str(length(eegfiles)) ') ']);
        if any(strcmp(eegfiles{i}, gc_info.files)) && ~overwrite_all_data
            display(['Skipping ' eegfiles{i} '.']);
            continue
        else
            gc_info.files{end+1} = eegfiles{i};
        end
        display(['Analyzing ' eegfiles{i} '...']);
        eegfname = [prefix eegfiles{i}];
        load(eegfname);
        %srate = 1/mean(diff(Time)); % assumes SR constant over the file

        onset_sample = min(find(Time >= sz_onset_s(i)));

        start_sample = onset_sample + samplevec(1);
        end_sample = onset_sample + samplevec(end);

        thisgcinfo = do_seeded_gc(F, srate, Channel, seedstr, start_sample, end_sample);
        thisgcinfo.eegfname = eegfname;
        thisgcinfo.ioz = ioz;
        gc_info.data{end+1} = thisgcinfo;

        eval([varname ' = gc_info;']);
        save(datapath, varname, '-v7.3');
    end

else
    load(datapath);
    eval(['gc_info = ' varname ';']);
end

% make figs if necessary
if overwrite_all_figs | overwrite_ioz_figs
    do_fxy_plots(gc_info.data, figsdir, tfsclim, zclim, timevec, ...
                 overwrite_all_figs, overwrite_ioz_figs);
    system(['python make_gc_pdf.py ' subj ' granger_' cond]);
end
