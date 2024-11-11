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
    tfsclim = [0 1];
end

if ~exist('zclim', 'var')
    zclim = [-10 10];
end

if ~exist('srate', 'var')
    srate = 250;
end

if ~exist('halfwindow_s', 'var')
    halfwindow_s = 10;
end

datapath = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/';

prefix = fullfile(datapath, [subj '/' subj '_']);

switch subj
  case 'UCHSN'
    duration_s = 30;
    seedstr = 'LCM2';
    sz_onset_s = [97.6 84.4 97.9 79 66.4 82.1 81 102.6 60.6 91.2 ...
                  105.4 70.4 ];
    sz_offset_s = nan;
    if strcmp(cond, 'onset')
        duration_s = 20;
        channeldirpart = '10_04_23__12_38_07';
        eegfiles = { '10_04_23__12_38_07/data_block001_notch.mat' ...
                     '10_04_23__18_58_17/data_block001_notch.mat' ...
                     '11_04_23__07_54_50/data_block001_notch.mat' ...
                     '11_04_23__08_44_42/data_block001_notch.mat' ...
                     '11_04_23__09_30_50/data_block001_notch.mat' ...
                     '12_04_23__11_23_41/data_block001_notch.mat' ...
                     '12_04_23__17_08_19/data_block001_notch.mat' ...
                     '12_04_23__17_44_02/data_block001_notch.mat' ...
                     '13_04_23__08_22_24/data_block001_notch.mat' ...
                     '13_04_23__08_35_40/data_block001_notch.mat' ...
                     '13_04_23__09_00_33/data_block001_notch.mat' ...
                     '13_04_23__09_31_42/data_block001_notch.mat' ...
                   };
        ioz = {'LPT5', 'LPT6', 'LPT7', 'LPT8'};
    elseif strcmp(cond, 'offset')
        offset_s = 70;
        eegfile = 'data_block001_notch.mat';
        extra_offset = 0;
    end
  case 'UCHGG'
    seedstr = 'RPI1';
    sz_onset_s  = [83 83.9 86.4 82.5 69.6 69.6 83.8 69.9 93.6 83.7 83.7 ...
                   72 68.4 83.1 70.3 76.5];
    sz_offset_s = 180;
    switch cond
      case 'onset'
        duration_s = 20;
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
    seedstr = 'LANT1';
    sz_onset_s = [83.4 82.3 82.6];
    sz_offset_s = 171;
    switch cond
      case 'onset'
        duration_s = 20;
        channeldirpart = '25_07_23__03_33_09';
        eegfiles = { '25_07_23__03_33_09/data_block001.mat' ...
                     '25_07_23__05_04_19/data_block001.mat' ...
                     '25_07_23__06_19_48/data_block001.mat' ...
                   };
        ioz = {'LAH1', 'LAH2', 'LAH3', 'LAH4', 'LPH1', 'LPH2', 'LPH3', 'LPH4'};
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
  case 'UCHDR'
    seedstr = 'LANT1';
    sz_onset_s = [46.8 53.4 47.9 46.5 47.6 46.8 47.3 47 47.2 45.5 ...
                  44.9 46.8 47.5];
    switch cond
      case 'onset'
        duration_s = 20;
        channeldirpart = '02_08_22__13_02_47';

        eegfiles = {'02_08_22__13_02_47/data_block001_notch.mat' ...
                    '02_08_22__13_38_36/data_block001_notch.mat' ...
                    '02_08_22__13_41_01/data_block001_notch.mat' ...
                    '02_08_22__13_43_37/data_block001_notch.mat' ...
                    '02_08_22__13_45_44/data_block001_notch.mat' ...
                    '02_08_22__13_47_15/data_block001_notch.mat' ...
                    '02_08_22__13_50_04/data_block001_notch.mat' ...
                    '02_08_22__13_52_22/data_block001_notch.mat' ...
                    '02_08_22__13_53_55/data_block001_notch.mat' ...
                    '02_08_22__13_56_06/data_block001_notch.mat' ...
                    '02_08_22__13_57_59/data_block001_notch.mat' ...
                    '02_08_22__14_00_35/data_block001_notch.mat' ...
                    '02_08_22__14_02_08/data_block001_notch.mat' ...
                   };

        ioz = {'MEGA6', 'MEGA7'};
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
  case 'UCHCV220919'
    seedstr = 'LPUL1';
    sz_onset_s = [80.8 71.096 75.46 78.73 82.39 82.24 89.63 78.24 ...
                  64.54 80.33];
    switch cond
      case 'onset'
        duration_s = 20;
        channeldirpart = '21_09_22__01_12_19';

        eegfiles = {'21_09_22__01_12_19/data_block001_notch.mat' ...
                    '21_09_22__02_22_43/data_block001_notch.mat' ...
                    '21_09_22__05_33_34/data_block001_notch.mat' ...
                    '21_09_22__18_20_52/data_block001_notch.mat' ...
                    '23_09_22__04_10_35/data_block001_notch.mat' ...
                    '24_09_22__05_44_44/data_block001_notch.mat' ...
                    '24_09_22__16_49_27/data_block001_notch.mat' ...
                    '25_09_22__02_50_31/data_block001_notch.mat' ...
                    '25_09_22__03_48_37/data_block001_notch.mat' ...
                    '25_09_22__03_59_14/data_block001_notch.mat' ...
                   };

        ioz_L_small = {'LTO1' 'LTO2' 'LTO3' 'LTO4'};
        ioz_L_big = {ioz_L_small{:} 'LTO5' 'LTO6' 'LTO7' 'LTO8' 'LTO9' 'LTO10' ...
                     'LMIO6' 'LMIO7' 'LMIO8' 'LMIO9' 'LMIO10' 'LMIO11' ...
                     'LMI12' 'LMI13'};
        ioz = ioz_L_big;
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
analdir = fullfile('analyses', subj);
figsdir = fullfile(analdir, 'figs', outputdir);

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

        if ~exist(analdir, 'dir')
            mkdir(analdir);
        end
    else
        load(datapath);
        eval(['gc_info = ' varname ';']);
    end
    for i=1:length(eegfiles)
        fprintf([int2str(i) '/' int2str(length(eegfiles)) ') ']);
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
