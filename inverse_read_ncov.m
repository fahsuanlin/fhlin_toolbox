function [cov_matrix, varargout]=read_ncov(ncov_file,nn_eeg,nn_meg,varargin)

% read_ncov.m
%
% read noise covariance matrix into matlab
%
% [N]=read_ncov(ncov_file)
% 
% Apr. 5, 2001
%

flag_display=1;

for i=1:length(varargin)./2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	switch option
	case 'flag_display'
		flag_display=option_value;
	otherwise
		fprintf('unknown option [%s]\n',option);
		return;
	end;	
end;

if(flag_display)
	fprintf('Reading noise covariance...\n');
end;

if(isempty(ncov_file))
	if(flag_display)
		fprintf('no noise covariance!!\n');
	end;
	cov_matrix=[];
	return;
end;


fp=fopen(ncov_file,'r','ieee-be.l64');

% dummy char
[ch]=fread(fp,1,'uchar');

%read file header without the new-line character
str=fgets(fp);
str=str(1:(length(str)-1));
if(flag_display)
	fprintf('NCOV file header=[%s]\n',str);
end;


str=str2num(fgets(fp));
n_meg=str(1);
if(length(str)>1)
	n_eeg=str(2);
end;
if(length(str)>2)
	n_trial=str(3);
end;

if(flag_display)
	fprintf('EEG channel=%d\n',n_eeg);
	fprintf('MEG channel=%d\n',n_meg);
	fprintf('\n');
end;

cov_matrix=fscanf(fp,'%f',[(n_eeg+n_meg)*(n_eeg+n_meg)]);
cov_matrix=reshape(cov_matrix,[n_eeg+n_meg,n_eeg+n_meg]);

fclose(fp);

if(nn_eeg==0)
	cov_matrix=cov_matrix(n_eeg+1:n_eeg+n_meg,n_eeg+1:n_eeg+n_meg);
end;

if(nn_meg==0)
	cov_matrix=cov_matrix(1:n_eeg,1:n_eeg);
end;


if(nargin==4&strcmp(varargin{1},'diag')==1)
	fprintf('All off-diagonal entries of noise covariance are set to zero!\n');
	cov_matrix=diag(diag(cov_matrix));
end;

if(flag_display)
	disp('Read NCOV DONE!');
end;

if(nargout==2)
	varargout{1}=n_trial;
end;
return;