function do_gc_anal(subj, cond, overwrite_data, overwrite_figs, ...
                    overwrite_alldata, tfsclim, clim, srate, halfwindow_s)

if ~exist('overwrite_data', 'var')
    overwrite_data = 0;
end

if ~exist('overwrite_figs', 'var')
    overwrite_figs = 1;
end

if ~exist('overwrite_alldata', 'var')
    overwrite_alldata = 0;
end

if ~exist('tfsclim', 'var')
    tfsclim = [0 3];
end

if ~exist('zclim', 'var')
    zclim = [-15 15];
end

if ~exist('srate', 'var')
    srate = 250;
end

if ~exist('halfwindow_s', 'var')
    halfwindow_s = 10;
end

datapath = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/';

switch subj
  case 'UCHSN'
    prefix = fullfile(datapath, 'UCHSN/UCHSN_09_04_23__16_36_19');
    duration_s = 30;
    seedstr = 'LCM2';
    sz_onset_s = 81.6;
    % sz_offset_s = 99;
    sz_offset_s = nan;
    if strcmp(cond, 'onset')
        offset_s = 0;
        eegfile = 'data_block001_02_notch.mat';
        extra_offset = 60; % for TFS plot if we want to adjust time axis
    elseif strcmp(cond, 'offset')
        offset_s = 70;
        eegfile = 'data_block001_notch.mat';
        extra_offset = 0;
    end
  case 'UCHGG'
    prefix = fullfile(datapath, 'UCHGG/UCHGG_');
    seedstr = 'RPI1';
    sz_onset_s  = [83 83.9 86.4 82.5 69.6 69.6 83.8 69.9 93.6 83.7 83.7 ...
                   72 68.4 83.1 70.3 76.5];
    sz_offset_s = 180;
    switch cond
      case 'onset'
        duration_s = 20;
        offset_s = 60;
        extra_offset = 0;
        %eegfile = 'data_block001_04_notch.mat';
        channeldirpart = '25_08_23__21_20_17';
        eegfiles = { '25_08_23__21_20_17/data_block001.mat' ...
                     '26_08_23__10_48_33/data_block001.mat' ...
                     '26_08_23__14_25_10/data_block001.mat' ...
                     '26_08_23__17_39_05/data_block001.mat' ...
                     '27_08_23__10_54_38/data_block001.mat' ...
                     '27_08_23__16_28_57/data_block001.mat' ...
                     '28_08_23__03_25_43/data_block001.mat' ...
                     '28_08_23__10_53_25/data_block001.mat' ...
                     '28_08_23__14_43_42/data_block001.mat' ...
                     '28_08_23__16_28_59/data_block001.mat' ...
                     '28_08_23__16_51_19/data_block001.mat' ...
                     '28_08_23__20_01_37/data_block001.mat' ...
                     '29_08_23__05_42_28/data_block001.mat' ...
                     '29_08_23__11_03_18/data_block001.mat' ...
                     '29_08_23__16_01_13/data_block001.mat' ...
                     '29_08_23__19_22_41/data_block001.mat' ...
                   };
        ioz = {'RAH1', 'RAH2', 'RAH3', 'RPH1', 'RPH2', 'RPH3'};
      case 'offset'
        duration_s = 30;
        offset_s = 0;
        extra_offset = 151;
        eegfile = 'data_block001_02_notch.mat';
      case 'wholesz'
        duration_s = 120;
        offset_s = 70;
        extra_offset = 0;
        eegfile = 'data_block001_resample_notch.mat';
    end
  case 'UCHVG'
    prefix = fullfile(datapath, 'UCHVG/UCHVG_25_07_23__03_33_09');
    seedstr = 'LANT1';
    sz_onset_s = 83.4;
    sz_offset_s = 171;
    switch cond
      case 'finderror'
        duration_s = 5;
        offset_s = 152; % was getting error if including second 155
        extra_offset = 0;
        eegfile = 'data_block001_04.mat';
      case 'wholesz'
        duration_s = 120;
        offset_s = 60;
        extra_offset = 0;
        eegfile = 'data_block001.mat';
    end
  case 'UCHDR2'
    prefix = fullfile(datapath, 'UCHDR240313/UCHDR240313_15_03_24__09_02_27');
    seedstr = 'LTOM1';
    sz_onset_s = 59.7;
    sz_offset_s = 76;
    switch cond
      case 'wholesz'
        duration_s = 35;
        offset_s = 45;
        extra_offset = 0;
        eegfile = 'data_block001_notch.mat';
    end

end

outputdir = ['granger_' cond];
figsdir = fullfile('analyses', subj, 'figs', outputdir);

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
    if ~exist(datapath, 'file')
        gc_info.files = {};
        gc_info.data = {};
    else
        load(datapath);
        eval(['gc_info = ' varname ';']);
    end
    if ~exist(subj, 'dir')
        mkdir(subj);
    end
    for i=1:length(eegfiles)
        if any(strcmp(eegfiles{i}, gc_info.files)) && ~overwrite_alldata
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
if overwrite_figs
    do_fxy_plots(gc_info.data, figsdir, tfsclim, zclim, timevec);
    system(['python make_gc_pdf.py ' subj ' granger_' cond]);
end
