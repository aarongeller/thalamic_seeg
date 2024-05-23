function [Fxy, Fyx] = do_UCHGG_movbiga(offset_s, duration_s, absolute_offset)

% offset_s: file-specific offset

% absolute_offset: can differ from offset_s if the file starts in
% the middle of the event, e.g. to show the end of the seizure,
% used just to set time labels in the TFS figure

% Fxy and Fyx have dimensions: channels x freq x time

whole_file = 'data_block001';
sz_end_file = 'data_block001_02_notch';
first_90_sec = 'data_block001_04';
prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHGG/UCHGG_25_08_23__21_20_17';

load(fullfile(prefix, 'channel.mat'));
load(fullfile(prefix, sz_end_file));
%load(fullfile(prefix, first_90_sec));

srate = 200;

start_sample = round(srate*offset_s) + 1;
end_sample = start_sample + round(srate*duration_s);

[Fxy, Fyx] = do_seeded_gc(F, srate, Channel, 'RPI1', start_sample, ...
                          end_sample, absolute_offset, 'UCHGG/figs/granger_end_notch');
