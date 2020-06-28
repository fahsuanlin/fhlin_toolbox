function history=isi_history(onset,isi_window, TR)
% isi_history	calcualte the history given a sequence of event onset
%
% history=isi_history(onset, isi_window, TR)
%
% onset: a sequence onsets of an event (in sample)
% isi_window: the duration of temporal window to account for the isi effect (in second)
% TR: the time difference bewteen two samples in the onset sequence (in second)
%
% fhlin@may 29 2008
%

history{1}=inf;
for idx=2:length(onset)
	onset_tmp=onset;
	onset_tmp=onset_tmp-onset(idx);
	onset_tmp_pre=abs(onset_tmp(find(onset_tmp<0))).*TR;
    if(isempty(onset_tmp_pre(onset_tmp_pre<=isi_window)))
        history{idx}=inf;
    else
    	history{idx}=onset_tmp_pre(onset_tmp_pre<=isi_window);
    end;
end;

return;
