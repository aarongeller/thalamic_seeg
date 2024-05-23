function do_UCHSN_fxy(postfix, offset_s, outputdir)

if ~exist('outputdir', 'var')
    outputdir = 'UCHSN/figs/granger';
end

% offset_s: file-specific offset

% absolute_offset: can differ from offset_s if the file starts in
% the middle of the event, e.g. to show the end of the seizure,
% used just to set time labels in the TFS figure

% Fxy and Fyx have dimensions: channels x freq x time
seedchannel = 'LCM2';
prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHSN/UCHSN_09_04_23__16_36_19';
load(fullfile(prefix, 'channel.mat'));
[~, channel_names, ~] = exclude_channels([], {Channel.Name}, seedchannel);

forwardmatname = ['Fxy_UCHSN_' postfix];
backwardmatname = ['Fyx_UCHSN_' postfix];
forwardstruct = load(fullfile('UCHSN', forwardmatname));
backwardstruct = load(fullfile('UCHSN', backwardmatname));

do_fxy_plots(eval(['forwardstruct.' forwardmatname]), eval(['backwardstruct.' backwardmatname]), ...
             channel_names, seedchannel, 5:5:100, offset_s, 200, outputdir); 
