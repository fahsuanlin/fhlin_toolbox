function [res]=fmri_pls_maskdata(dat,threshold,flag)
%fmri_pls_maskdata 		generate a mask to the datamat based on the threshold and flag setting.
%
%[res]=fmri_pls_maskdata(dat,threshold,flag)
%
%dat: the dat to be masked
%threshold: the threshold to do masking
%flag: if flag==0, all entries in dat >= threshold will be kept.
%      if flag==1, all entries in dat <= threshold will be kept.
%
%written by fhlin@aug. 26 1999

res=zeros(size(dat));


if(flag==0)
        idx = find(dat>=threshold);
	res(idx)=dat(idx);
end;
if(flag==1)
	idx = find(dat<=threshold);
	res(idx)=dat(idx);
end;

disp('masking done!');