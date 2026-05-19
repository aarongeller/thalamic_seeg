function ll=get_edf_sr_dur(fname)
ll=zeros(1,2);
load(fname);
ll(1) = F.prop.sfreq;
ll(2) = F.prop.times(2);
% h = blockEdfLoad(fname);
% d = h.num_data_records * h.data_record_duration;
