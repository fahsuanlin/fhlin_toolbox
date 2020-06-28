function y=fmri_pls_sigmoid(slope,shift,x);
%
%
%
%
count=1;
for i=1:length(slope)
	for j=1:length(shift)
		y(:,count)=1./(1+exp(-slope(i).*(x-shift(j))))';
		count=count+1;
	end;
end;
