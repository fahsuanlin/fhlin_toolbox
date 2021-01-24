function [A_reg, Y_reg, x_mne_orientation,A_reg_u]=inverse_mce_prep(varargin)
%
%inverse_mce_prep       prepare the MCE estimates
%
%[A_reg, Y_reg, x_mne_orientation,A_reg_u]=inverse_mce_prep([option_name1, option_value1,...]
%
%%
%option:
%   Y: MEG measurements;
%   A: original 2D forward matrix
%   A_reg_rank: a scalar (integer) specifying the rank of the regularized forward matrix, A_reg
%
%
% fhlin@jan. 16. 2003

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_prep_A=1;
flag_prep_Y=1;
flag_prep_orient=1;

A_reg=[];
A_reg_u=[];
Y_reg=[];
A_reg_rank=[];
A=[];

x_mne_orientation=[];
X_mne=[];
W_mne=[];

flag_display=0;
for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'a_reg_rank'
		A_reg_rank=option_value;
	case 'a'
		A=option_value;
	case 'a_reg_u'
		A_reg_u=option_value;
	case 'x_mne'
		X_mne=option_value;
	case 'y'
		Y=option_value;
	case 'w_mne'
		W_mne=option_value;
	case 'flag_display'
		flag_display=option_value;
	case 'flag_prep_a'
		flag_prep_A=option_value;
	case 'flag_prep_y'
		flag_prep_Y=option_value;
	case 'flag_prep_orient'
		flag_prep_orient=option_value;
	otherwise
		fprintf('unknown option [%s]\n',option);
		return;
	end;
end;




if(flag_prep_A|(flag_prep_Y&isempty(A_reg_u)&isempty(A_reg_rank)))
	% forward regularization
	if(flag_display)
		fprintf('regularizing forward matrix...\n');
	end;
	if(~isempty(A_reg_rank))
		if(flag_display)
			fprintf('specified regularization...[%d]\n',A_reg_rank);
		end;
		[A_reg_u,s,v]=svds(A,A_reg_rank);
	else
		if(flag_display)
			fprintf('automatic regularization...[%d]\n',round(min(size(A)).*0.6));
		end;
		[A_reg_u,s,v]=svds(A,round(min(size(A)).*0.6));
	end;

	ds=diag(s);
	ss=ds.^2./sum(ds.^2);

	css=cumsum(ss);
	A_reg=s(1:A_reg_rank,1:A_reg_rank)*v(:,1:A_reg_rank)';       %regularized forward
	clear('ss','s','v');
end;	

if(flag_prep_Y)
	if(flag_display)
		fprintf('regularizing observation...\n')
	end;
	Y_reg=A_reg_u(:,1:A_reg_rank)'*Y;                    %regularized observation
end;

if(flag_prep_orient)
	if(flag_display)
		fprintf('estimating orientation...\n')
	end;
	if(isempty(X_mne))
		if(flag_display)
			fprintf('MNE inverse...');
		end;
		if(isempty(W_mne)|isempty(Y))
			fprintf('no measurement (Y) or inverse operator (W_mne)!\n');
			fprintf('error!\n');
			return;
		end;
		X_mne=W_mne*Y(:,i);
	end;
	
	%search time instant with maximal power for each dipole
	power=squeeze(sum(reshape(abs(X_mne).^2,[3,size(X_mne,1)/3,size(X_mne,2)]),1));
	if(size(power,3)==1)
		max_power_time_idx=ones(size(X_mne,1)/3,1);
	else
		[max_power,max_power_time_idx]=max(power,[],2);
	end;

	for ii=1:(size(X_mne,1)./3)
		x_mne_orientation(:,ii)=reshape(X_mne((ii-1)*3+1:ii*3,max_power_time_idx(ii)),[3,size(X_mne((ii-1)*3+1:ii*3,max_power_time_idx(ii)),1)/3]);
 	        x_mne_orientation(:,ii)=x_mne_orientation(:,ii)./repmat(sqrt(sum(x_mne_orientation(:,ii).^2,1)),[3,1]);
	
		if(sum(x_mne_orientation(:,ii).^2)<eps)
			x_mne_orientation(:,ii)=0;
		end;
	end;
end;


