function [param,ON]=etc_param_min_isi(TR, min_isi, n_trial, total_run_time,varargin)
%   etc_param_min_isi       generate the paradigm and onset time for
%   event-related design with minimal ISI constraint
%
% [param,ON]=etc_param_min_isi(TR, min_isi, n_trial, total_run_time)
%
% TR: TR in second
% min_ini: minimal ISI allowed in second
% n_trial: number of events to be presented
% total_run_time: the length of the run in second
%
% param: the paradigm with SOA
% ON: SOA
%
% fhlin@june 27 2007
%


% TR=0.1;                 %TR (second)
% min_isi=3;              %minimum ISI (second)
% n_trial=32;             %number of trial of stimulus
% total_run_time=240;     %240 sec per run

rv=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'rv'
            rv=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

if(isempty(rv))
    rv=1;
end;

param=zeros(1,round(total_run_time/TR));

done=0;
while(~done)
    onset=randperm(length(param));

    ON=[]; buffer=zeros(size(param));
    ON(1)=onset(1);
    if(ON(end)-ceil(min_isi/TR/2)>0) start=ON(end)-ceil(min_isi/TR/2); else start=1; end;
    if(ON(end)+floor(min_isi/TR/2)-1<length(param)) stop=ON(end)+floor(min_isi/TR/2)-1; else stop=length(param); end;
    buffer(start:stop)=1;
    idx=2;

    flag_break=0;
    n_trial_total=sum(n_trial);
    for ii=2:n_trial_total
        found=0;
        while(~found)
            if(onset(idx)-ceil(min_isi/TR/2)>0) start=onset(idx)-ceil(min_isi/TR/2); else start=1; end;
            if(onset(idx)+floor(min_isi/TR/2)-1<length(param)) stop=onset(idx)+floor(min_isi/TR/2)-1; else stop=length(param); end;
            if(sum(buffer(start:stop))==0)
                ON(end+1)=onset(idx);
                buffer(start:stop)=1;
                found=1;
            end;
            idx=idx+1;
            if(idx>length(param)) found=1; flag_break=1; end;
        end;
        if(flag_break) break; end;
    end;
    if(length(ON)==n_trial_total) done=1; end;
end;

for rv_idx=1:length(rv)
    aa=sum(n_trial(1:rv_idx-1))+1;
    bb=sum(n_trial(1:rv_idx));
    param(ON(aa:bb))=rv(rv_idx);
end;
return;
