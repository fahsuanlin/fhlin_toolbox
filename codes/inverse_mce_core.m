function [X_mce,value_mce]=inverse_mce_core(Y,varargin)
%
%inverse_mce_core       calculate the MCE estimates
%
%[X_mce,value_mce]=inverse_mce_core(Y,[option_name1, option_value1,...]
%
%Y: measurements (m*n matrix, m-channel and n-time points)
%
%option:
%   A_reg: 2D regularized forward matrix for MCE
%   A: original 2D forward matrix
%   A_reg_rank: a scalar (integer) specifying the rank of the regularized forward matrix, A_reg
% 	A_reg_u: 2D left singular vectors of the regularzed forward solution.
%   x_mne_orientaiton: a 2D matrix specifying the orientation of dipoles (3*n_dipole)
%   X_mne: MNE estimation of sources
%   W_mne: MNE inverse operator
% 	mce_weight: a column vector for weighting dipoles in MCE
% 	mce_weight_order: a scalar for weighting dipoles in MCE by the lead field power magnitudes 
%
%X_mce: output MCE estimates
%value_mce: output MCE errors
%
% fhlin@jan. 16. 2003

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A_reg=[];
Y_reg=[];
A_reg_rank=[];
A_reg_u=[];
A=[];

x_mne_orientation=[];
mce_weight=[];
mce_weight_order=[];
X_mne=[];
W_mne=[];
x_mce_init=[];

flag_estimate_orientation=1;
flag_display=0;
flag_collapse_A_reg=1;
flag_time_invariant_orientation=1;
flag_modify_mce=1;

X_mce=[];
value_mce=[];

timeVec=[];


flag_estimate_orientation=1; %estimate dipole orientation at every time point using MNE

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'a_reg'
		A_reg=option_value;
	case 'a_reg_rank'
		A_reg_rank=option_value;
	case 'a_reg_u'
		A_reg_u=option_value;
	case 'a'
		A=option_value;
	case 'x_mne_orientation'
		x_mne_orientation=option_value;
	case 'mce_weight'
		mce_weight=option_value;
	case 'mce_weight_order'
		mce_weight_order=option_value;
	case 'x_mne'
		X_mne=option_value;
	case 'y_reg'
		Y_reg=option_value;
	case 'x_mce_init'
		x_mce_init=option_value;
	case 'w_mne'
		W_mne=option_value;
	case 'flag_estimate_orientation'
		flag_estimate_orientation=option_value;
	case 'flag_display'
		flag_display=option_value;
	case 'flag_collapse_a_reg'
		flag_collapse_A_reg=option_value;
	case 'flag_time_invariant_orientation'
		flag_time_invariant_orientation=option_value;
	case 'flag_modify_mce'
		flag_modify_mce=option_value;
	case 'timevec'
		timeVec=option_value;
	otherwise
		fprintf('unknown option [%s]\n',option);
		return;
	end;
end;



%%%%%%%%%%%%% MEC preparation%%%%%%%%%%%%%%%
if(~isempty(Y))
	length_Y=size(Y,2);
end;

if(~isempty(Y_reg))
	length_Y=size(Y_reg,2);
end;

for i=1:length_Y
    
	X_mne_orig=X_mne;
	x_mne_orientation_orig=x_mne_orientation;
    
	if(flag_estimate_orientation)
		if(isempty(x_mne_orientation))
			if(isempty(X_mne))
				if(flag_display)
					fprintf('MNE inverse...');
				end;
				X_mne=W_mne*Y(:,i);
			end;
			if(flag_display)
				fprintf('orientation estimation...');
			end;
			if(~flag_time_invariant_orientation)
	 	           	x_mne_orientation=reshape(X_mne(:,i),[3,size(X_mne(:,i),1)/3]);
 			        x_mne_orientation=x_mne_orientation./repmat(sqrt(sum(x_mne_orientation.^2,1)),[3,1]);
   			        idx0=find(repmat(sqrt(sum(x_mne_orientation.^2,1)),[3,1])<eps);
     				x_mne_orientation(idx0)=0;
			else
				flag_estimate_orientation=0;	%only estimate orientation once!
									
				%search time instant with maximal power for each dipole
				if(isempty(X_mne))
					X_mne=W_mne*Y;
				end;
				
				power=squeeze(sum(reshape(abs(X_mne).^2,[3,size(X_mne,1)/3,size(X_mne,2)]),1));
                if(size(X_mne,2))==1 power=power'; end;
                
				[max_power,max_power_time_idx]=max(power,[],2);

				for ii=1:(size(X_mne,1)./3)
                        x_mne_orientation(:,ii)=reshape(X_mne((ii-1)*3+1:ii*3,max_power_time_idx(ii)),[3,size(X_mne((ii-1)*3+1:ii*3,max_power_time_idx(ii)),1)/3]);
 				        x_mne_orientation(:,ii)=x_mne_orientation(:,ii)./repmat(sqrt(sum(x_mne_orientation(:,ii).^2,1)),[3,1]);
	
					if(sum(x_mne_orientation(:,ii).^2)<eps)
						x_mne_orientation(:,ii)=0;
					end;
				end;
			end;
	        end;
	end;
	
	

	if(flag_collapse_A_reg)
		A_reg_theta=zeros(size(A_reg,1),size(A_reg,2)./3);
		for j=1:size(A_reg_theta,2)
			A_reg_theta(:,j)=A_reg(:,(j-1)*3+1:j*3)*x_mne_orientation(:,j);
	        end;
	else
		A_reg_theta=A_reg;
	end;

	if(flag_display)
		fprintf('MCE weighting...');
	end;
	mce_weight_orig=mce_weight;
	if(isempty(mce_weight))
		if(isempty(mce_weight_order))
			mce_weight=1./(sqrt(sum(A_reg_theta.^2,1)).^1.0)';
		else
			if(flag_display) fprintf('depth weighting at [%2.2f]...\n',mce_weight_order); end;
	        mce_weight=1./(sqrt(sum(A_reg_theta.^2,1)).^mce_weight_order)';
		end;
	end;
    
	%MCE starts
	if(flag_display)
		fprintf('MCE [%d|%d] %2.2f%%...\n',i,length_Y,i./length_Y*100.0);
	end;
    
	if(isempty(x_mce_init))
		[xx_mce,value_mce(i)] = simplex1(A_reg_theta,Y_reg(:,i),mce_weight,zeros(1,size(A_reg,2)),'flag_display',flag_display);
	else

	[xx_mce,value_mce(i)] = simplex1(A_reg_theta,Y_reg(:,i),mce_weight,zeros(1,size(A_reg,2)),'flag_display',flag_display,'mce_init',x_mce_init(:,i));
	end;
	
	if(flag_modify_mce)
		if(flag_display) fprintf('modify MCE by replacing zero entries into EPS...\n'); end;
		idx=find(abs(xx_mce')<eps);
		xx_mce(idx)=rand(length(idx),1).*eps.*1e3;
	end;
	
	X_mce(:,i)=xx_mce';
    
	mce_weight=mce_weight_orig;
	if(~flag_time_invariant_orientation)
		x_mne_orientation=x_mne_orientation_orig;
	end;
	X_mne=X_mne_orig;
    
end;
