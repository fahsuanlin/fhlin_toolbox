function [onset, beta]=etc_onset(timeVec,timecourse,rise_on,rise_off,y_on,y_off)

if(min(size(timecourse))==1)
	timecourse=timecourse./max(timecourse);
else
	for ii=1:size(timecourse,2)
		timecourse(:,ii)=timecourse(:,ii)./max(timecourse(:,ii));
	end;
end;
	
tidx=find(timeVec>rise_on&timeVec<rise_off);
regressor_tidx=timeVec(tidx);


timecourse_orig=timecourse;
if(min(size(timecourse))==1)
	timecourse=timecourse(tidx)';
else
	timecourse=timecourse(tidx,:);
end;

beta=zeros(2,size(timecourse,2));
onset=zeros(1,size(timecourse,2));



for ii=1:size(timecourse,2)
	sidx=find(timecourse(:,ii)>y_on&timecourse(:,ii)<y_off);
	if(~isempty(sidx)&length(sidx)>=2)
		D=[ones(length(sidx),1),regressor_tidx(sidx)'];

		beta(:,ii)=inv(D'*D)*D'*timecourse(sidx,ii);
		onset(ii)=-beta(1,ii)./beta(2,ii);
	else
		beta(:,ii)=nan;
		onset(ii)=nan;
	end;
end;

idx=find(~isnan(onset)&(onset>0.5));
onset_avg=mean(onset(idx));
onset_median=median(onset(idx));
onset_std=std(onset(idx));
fprintf('onset = %2.2f (+/-%2.2f) median=%2.2f sec\n',onset_avg,onset_std,onset_median);
