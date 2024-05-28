function do_gc_anal(subj, cond, overwrite_data, overwrite_figs)

if ~exist('overwrite_data', 'var')
    overwrite_data = 0;
end

if ~exist('overwrite_figs', 'var')
    overwrite_figs = 1;
end

switch subj
  case 'UCHSN'
    prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHSN/UCHSN_09_04_23__16_36_19';
    duration_s = 30;
    seedstr = 'LCM2';
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
    prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHGG/UCHGG_25_08_23__21_20_17';    
    seedstr = 'RPI1';
    switch cond
      case 'onset'
        duration_s = 30;
        offset_s = 60;
        extra_offset = 0;
        eegfile = 'data_block001_04_notch.mat';
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
end

outputdir = ['granger_' cond];
figsdir = fullfile(subj, 'figs', outputdir);

load(fullfile(prefix, 'channel.mat'));
load(fullfile(prefix, eegfile));

srate = 1/mean(diff(Time)); % assumes SR constant over the file
start_sample = round(srate*offset_s) + 1;
end_sample = start_sample + round(srate*duration_s);

varname =  [subj '_gcinfo_' cond];
filename = [varname '.mat'];
datapath = fullfile(subj, filename);

% compute gc if necessary
if ~exist(datapath, 'file') || overwrite_data
    gc_info = do_seeded_gc(F, srate, Channel, seedstr, start_sample, end_sample);
    eval([varname ' = gc_info;']);
    save(datapath, varname);
else
    load(datapath);
    eval(['gc_info = ' varname ';']);
end

% make figs if necessary
if overwrite_figs
    do_fxy_plots(gc_info, start_sample/srate + extra_offset, figsdir);
    system(['python make_gc_pdf.py ' subj ' granger_' cond]);
end


