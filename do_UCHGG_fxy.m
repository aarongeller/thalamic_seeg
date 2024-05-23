function do_UCHGG_fxy(postfix, absolute_offset)

prefix = '/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/UCHGG/UCHGG_25_08_23__21_20_17';
load(fullfile(prefix, 'channel.mat'));
[~, channel_names, ~] = exclude_channels([], {Channel.Name}, 'RPI1'); 

forwardmatname = ['Fxy_' postfix];
backwardmatname = ['Fyx_' postfix];
forwardstruct = load(forwardmatname);
backwardstruct = load(backwardmatname);

do_fxy_plots(eval(['forwardstruct.' forwardmatname]), eval(['backwardstruct.' backwardmatname]), ...
             channel_names, 'RPI1', 5:5:100, 151, 200, 'UCHGG/figs/granger'); 
