function [brainlv, ica_sv, designlv, brainscore, designscore,mean_matrix]=fmri_pls_ica(raw,varargin)
%fmri_pls_ica		ICA on effect space of PLS
%
% [brainlv, ica_sv, designlv, brainscore, designscore,mean_matrix]=fmri_pls_ica(raw,contrast);
% raw: the 2D datamat, each row is an image at one time point. and each column is a time series of one voxel.
% contrast: contrast matrix
% eta: the learning rate in ICA. (default: 0.05)
% A0: the initial unmixing matrix: (default: identity matrix)
%
% brainlv: independent components as brain LV's
% ica_sv: the contribution of each independent component by average power
% designlv: inversion of the unmixing matrix, each column of such an inversion is one design LV
% brainscore: raw*brainlv
% designscore: contrast*designlv
%
%mean_matrix: the mean matrix of product of contrast and raw datamat
%	       ICA must use the mean corrected input. TO restore the
%	       original input matrix, this mean_matrix must be added 
%	       afterward.
%
% written by fhlin@jan. 18, 00

forced_convergence=0;
contrast=[];
numIC=[];

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'contrast'
		contrast=option_value;
	case 'forced_convergence'
		forced_convergence=option_value;
	case 'numic'
		numIC=option_value;
	otherwise
		fprintf('unknown [%s] option!\n',option);
		fprintf('error!\n')'
		return;
	end;
end;

if(isempty(contrast))
	contrast=eye(size(raw,1));
end;

x=contrast'*raw;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% old input parameter processing....
%if (nargin==3)
%  	fprintf('reading datamat...\n');
%	raw=varargin{1};
%	fprintf('reading contrast matrix...\n');
%	contrast=varargin{2};
%   x=contrast'*raw;
%   forced_convergence=varargin{3};
%elseif(nargin==2)
%	fprintf('reading datamat...\n');
%	raw=varargin{1};
%	fprintf('reading contrast matrix...\n');
%	contrast=varargin{2};
%
%	x=contrast'*raw;
%	forced_convergence=0;
%
%elseif (nargin==1)
%	fprintf('reading effect space...\n');
%   x=varargin{1};
%   forced_convergence=0;
%
%else
%	fprintf('cannot recognize the parameters...\n');
%	fprintf('terminating PLS-ICA\n');
%	return;
%end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get rid of the mean
%mean_matrix=repmat(mean(x,2),[1,size(x,2)]);
%x=x-mean_matrix;

eta=0.05;
sz=size(x,1);
a0=eye(sz,sz);
%if nargin==3
%	eta=varargin{1};
%end;
%
%if nargin==4
%	eta=varargin{1};
%	a0=varargin{2};
%end;

fprintf('ICA...\n');
%%%%%%%%% my ica algorithm %%%%%%%%%%%%%
%[s,W]=fmri_ica(x, eta, a0);
%A=inv(W);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% fast ica algorithm %%%%%%%%%%%%%
if(isempty(numIC))
	[s,A,W]=fastica(x,'verbose','off','displayMode','off','maxNumIterations',400,'epsilon',0.001);
else
	[s,A,W]=fastica(x,'verbose','off','displayMode','off','maxNumIterations',400,'epsilon',0.001,'numOfIC',numIC);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if((((~isempty(s))&(size(A,1)==size(A,2)))|(forced_convergence))|(size(s,1)==numIC)) %convergent ICA
   
   if(forced_convergence) 
      fprintf('ICA forced convergence!\n');
   else
      fprintf('ICA convergence!\n');
      fprintf('actual IC=%s\n',mat2str(size(W)));
   end;
      
	mn=min(numIC,size(x,1));

	ica_sv=zeros(mn,mn);
	n_designlv=zeros(size(x,1),mn);
	n_brainlv=zeros(mn,size(x,2));


	for i=1:size(W,1)
		n_designlv(:,i)=A(:,i)./sqrt(A(:,i)'*A(:,i));
		n_brainlv(i,:)=s(i,:)./sqrt(s(i,:)*s(i,:)');
	
		n_recon=n_designlv(:,i)*n_brainlv(i,:);
		n_recon_energy=sum(sum(n_recon.^2));
	
	
		orig_recon=A(:,i)*s(i,:);
		orig_recon_energy=sum(sum(orig_recon.^2));
	
	
		ica_sv(i,i)=sqrt(orig_recon_energy/n_recon_energy);
	
	end;


	[dummy,sequence]=sort(diag(ica_sv));
	sequence=flipud(sequence);



	sv=ica_sv;
	for i=1:min(size(sv))
		ica_sv(i,i)=sv(sequence(i),sequence(i));
	end;

	brainlv([1:min(size(n_brainlv))],:)=n_brainlv(sequence,:);
	brainlv=brainlv';
	designlv(:,[1:min(size(n_designlv))])=n_designlv(:,sequence);

	if(nargin==3)
  		fprintf('getting design scores and brain scores...\n');
		brainscore=raw*brainlv;
      designscore=contrast*designlv;
   elseif(nargin==2)
     	fprintf('getting design scores and brain scores...\n');
		brainscore=raw*brainlv;
      designscore=contrast*designlv;
	elseif(nargin==1)
		fprintf('no datamat and contrast available. ');
		fprintf('setting brain scores and design scores to zeros.\n');
		brainscore=0;
		designscore=0;
	end;

	disp('PLS ICA done!');
else
	brainlv=0;
	ica_sv=0;
	designlv=0;
	brainscore=0;
	designscore=0;
	mean_matrix=0;
	disp('PLS ICA not convergent!');
end;

