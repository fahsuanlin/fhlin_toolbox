function [y]=isi_sigmoidal_sim(TR,param,crf,sig_a,sig_b,sig_window,varargin)
% isi_sim     simulate the observation given stimulus onset, canonical
% response function (crf), and inter-stimulu-interval modulation sigmoidal function parameter
%
% [y]=isi_sigmoidal_sim(TR,param,crf,sig_a,sig_b,sig_window,[option, option_value,...]);
%
% TR: the interval between two "param" entries (in seconds)
% param: a vector of 0/1 containing the onset timing 
% crf: a vector of canonical response function for each trial; it has the same temporal resolution as "param". 
% sig_a and sig_b: parameters for the sigmoidal function y=1/(1+(-exp(x-a).*b))
% sig_window: the length of the window to account for ISI effect (in
% seoncds)
%
% fhlin@may 28 2008


param0=param;
param=zeros(length(param0));
param(find(param0))=1;

onset=find(param);
isi_modulation{1}=[1];
for idx=2:legnth(onset)
    relative_onset=onset-onset(idx);
    
    %find only stimuli *before* this trial
    relative_onset=relative_onset(find(relative_onset<0));
    
    %find only stimuli *within* the sigmoidal modulation window
    relative_onset_idx=find(abs(relative_onset).*TR<sig_window);
    
    isi_modulation{idx}=isi_sigmoidal(relative_onset(relative_onset_idx).*TR,a,b);
end;
