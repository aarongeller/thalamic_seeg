function ll = get_seeg_channels(mfile)
ll = zeros(1,3);
load(mfile);
ll(1) = sum(strcmp({Channel.Type}, 'SEEG'));
ll(2) = sum(strcmp({Channel.Type}, 'MISC'));
ll(3) = sum(strcmp({Channel.Type}, 'ECG'));
