function [output]=etc_detrend(data)
%	etc_detrend	remove only the linear trend of the data while keeping the DC
%
%	output=etc_detrend(data);
%
%	data: input 2D matrix of [n_time, n_variable];
%	output: output 2D matrix of [n_time, n_variable];
%
%	fhlin@28 aug. 2006
%
flag_sep=0;
[n_time,n_variable]=size(data);
output=zeros(size(data));

if(flag_sep)
	design(:,1)=[1:n_time]';
	design(:,2)=ones(1,n_time)';
	for idx=1:n_variable
		beta=inv(design'*design)*design'*data(:,idx);
		output(:,idx)=data(:,idx)-design(:,1)*beta(1);
	end;
else
	design=zeros(n_time*n_variable,n_variable+1);
	y=zeros(n_time*n_variable,1);
	for idx=1:n_variable
		design((idx-1)*n_time+1:idx*n_time,1)=[1:n_time]';
		design((idx-1)*n_time+1:idx*n_time,idx+1)=ones(1,n_time)';
		y((idx-1)*n_time+1:idx*n_time,1)=data(:,idx);
	end;
	beta=inv(design'*design)*design'*y;
	output=reshape(y-design(:,1)*beta(1),[n_time,n_variable]);
end;


return;
