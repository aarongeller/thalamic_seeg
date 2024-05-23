function do_UCHSN_movbiga(offset_s, duration_s, absolute_offset, outputdir)

if ~exist('outputdir', 'var')
    outputdir = 'granger';
end

% offset_s: file-specific offset

% absolute_offset: can differ from offset_s if the file starts in
% the middle of the event, e.g. to show the end of the seizure,
% used just to set time labels in the TFS figure

% Fxy and Fyx have dimensions: channels x freq x time

whole_file = 'data_block001_notch.mat';
onset_file = 'data_block001_02_notch.mat';
prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHSN/UCHSN_09_04_23__16_36_19';

load(fullfile(prefix, 'channel.mat'));
% load(fullfile(prefix, onset_file));
load(fullfile(prefix, whole_file));

srate = get_bs_srate(History); % History is saved in brainstorm datafile

start_sample = round(srate*offset_s) + 1;
end_sample = start_sample + round(srate*duration_s);

[Fxy, Fyx] = do_seeded_gc(F, srate, Channel, 'LCM2', start_sample, ...
                          end_sample, absolute_offset, ...
                          fullfile('UCHSN/figs', outputdir));

% save Fxy matrices
output_str = ['UCHSN_' num2str(absolute_offset) '_' num2str(duration_s)];
Fxy_output_str = ['Fxy_' output_str];
Fyx_output_str = ['Fyx_' output_str];
eval([Fxy_output_str ' = Fxy;']);
eval([Fyx_output_str ' = Fyx;']);
fxycomm = ['save(fullfile(''UCHSN'', ''' Fxy_output_str '''), ''' Fxy_output_str ''');'];
fyxcomm = ['save(fullfile(''UCHSN'', ''' Fyx_output_str '''), ''' Fyx_output_str ''');'];
eval(fxycomm);
eval(fyxcomm);
