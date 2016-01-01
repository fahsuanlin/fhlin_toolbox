function [varargout]=inverse_prep(varargin)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults

file_meg_forward={};
file_eeg_forward={};
file_prior={};
file_noisecovariance={};
file_badchannel={};
file_dip={};
file_dec={};
file_brain_patch={};
file_measure_mat={};


nperdip=3;						% estimate all directional components

nctype='diag';						%only diagonal entries of noise covairance are non-zero; this is the same as the old stream where "nc" is set to "2".

flag_cortical_constraint=0;				%cortical constraint; if it is set to 1, only dipole prependicular to the cortical surface will be estimated. Otherwise, it would be 3 directional dipole (x,y and z components) for each cortical location. 
flag_prior_continous=0;					%use the prior values from prior files. No adjustment
prior_threshold=1.0;					%the minimum of priors to be active in prior matrix (flag_prior_continous must be 0 to be effective)
prior_min=0.1;						%the value assigned to sub-threshold prior entries (flag_prior_continous must be 0 to be effective)

%output arguments
A=[];
R=[];
C=[];
Y=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read-in parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'subject'
		subject=option_value;
	case 'file_dip'
		file_dip=option_value;
	case 'file_dec'
		file_dec=option_value;
	case 'file_badchannel'
		file_badchannel=option_value;
	case 'file_meg_forward'
		file_meg_forward=option_value;
	case 'file_eeg_forward'
		file_eeg_forward=option_value;
	case 'file_brain_patch'
		file_brain_patch=option_value;
	case 'file_measure_mat'
		file_measure_mat=option_value;
	case 'file_noisecovariance'
		file_noisecovariance=option_value;
	case 'file_prior'
		file_prior=option_value;
	case 'nctype'
		nctype=option_value;
	case 'flag_cortical_constraint'
		flag_cortical_constraint=option_value;
	case 'flag_prior_continous'
		flag_prior_continous=option_value;
	case 'prior_threshold'
		prior_threshold=option_value;
	case 'prior_min'
		prior_min=option_value;
	otherwise
		fprintf('unknown option [%s]\n',option);
		return;
	end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isempty(file_prior))
    prior_index=0;
else
    prior_index=1;
end;
%file_output_stem=sprintf('%s_cort%d_nn%d_pri%d_nperdip%d_stnorm%d',file_output,flag_cortical_constraint,flag_noise_normalized_iop,prior_index,nperdip,flag_iop_stnorm);
%fprintf('\nOutput file stem=[%s]\n\n',file_output_stem);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


process_id=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	Read data into matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n%d. READ DATA FROM FILES...\n',process_id);
process_id=process_id+1;

% dip and dec information
for i=1:size(file_dip,1)
	[DIP{i},DEC{i}]=inverse_read_dipdec(file_dip{i}, file_dec{i});
	dec{i}=find(DEC{i});
	dip{i}=DIP{i}(:,dec{i});
end;

% forward solutions
fprintf('Reading MEG/EEG forward solution...\n');
A_EEG_3D_tmp={};
A_EEG_2D_tmp={};
for i=1:size(file_eeg_forward,1)
    if(isempty(findstr(file_eeg_forward{i},'mat')))
        [A_EEG_3D_tmp{i},A_EEG_2D_tmp{i}]=inverse_read_fwd(file_eeg_forward{i},nperdip);
    else
        tmp=load(file_eeg_forward{i});
        A_EEG_2D_tmp{i}=(tmp.EEG_fwd)';
    end;
end;
if(length(A_EEG_2D_tmp)>0)
    n_eeg=size(A_EEG_2D_tmp{1},1);
else
    n_eeg=0;
end;




A_MEG_3D_tmp={};
A_MEG_2D_tmp={};
for i=1:size(file_meg_forward,1)
    if(isempty(findstr(file_meg_forward{i},'mat')))
        [A_MEG_3D_tmp{i},A_MEG_2D_tmp{i}]=inverse_read_fwd(file_meg_forward{i},nperdip);
    else
        tmp=load(file_meg_forward{i});
        A_MEG_2D_tmp{i}=(tmp.MEG_fwd)';
    end;
end;
if(length(A_MEG_2D_tmp)>0)
    n_meg=size(A_MEG_2D_tmp{1},1);
else
    n_meg=0;
end;


%splitting forwad solution if necessary to match dip/dec file
flag_split=0;
if(length(file_meg_forward)>0)
    AA_MEG=A_MEG_2D_tmp{1};
    if(length(file_dip)~=length(file_meg_forward))
        flag_split=1;
    end;
else
    AA_MEG=[];
end;
if(length(file_eeg_forward)>0)
    AA_EEG=A_EEG_2D_tmp{1};
    if(length(file_dip)~=length(file_eeg_forward))
        flag_split=1;
    end;
else
    AA_EEG=[];
end;
if(flag_split)
    fprintf('splitting forward matrix ....\n');
    offset=0;
    for i=1:length(file_dip)
        if(~isempty(AA_MEG)) A_MEG_2D_tmp{i}=AA_MEG(:,offset+1:offset+length(dec{i})); end;
        if(~isempty(AA_EEG)) A_EEG_2D_tmp{i}=AA_EEG(:,offset+1:offset+length(dec{i})); end;
        offset=offset+length(dec{i});
    end;
end;
fprintf('end of splitting!\n');    
        

for i=1:max(length(A_EEG_2D_tmp),length(A_MEG_2D_tmp))
	if(length(A_EEG_2D_tmp)>0&length(A_MEG_2D_tmp)>0)
		A_2D_tmp{i}=[A_EEG_2D_tmp{i};A_MEG_2D_tmp{i}];
	elseif(length(A_EEG_2D_tmp)>0)
		A_2D_tmp{i}=[A_EEG_2D_tmp{i}];
	elseif(length(A_MEG_2D_tmp)>0)
		A_2D_tmp{i}=[A_MEG_2D_tmp{i}];
	end;		
end;


%sensor noise covariance matrix
C=inverse_read_ncov(file_noisecovariance,n_eeg,n_meg,nctype);

% bad channels
BAD=inverse_read_badchannel(file_badchannel);

%% dipole prior information
R=inverse_read_prior(file_prior);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Cortical constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. CORTICAL CONSTRAINT ADJUSTMENT...\n',process_id);
process_id=process_id+1;

if(flag_cortical_constraint)
	if(nperdip==3)
		for i=1:size(file_dip,1)
			fprintf('3 directional dipoles in original forward solution...\n');
			fprintf('They will be collapsed into 1 dipole prependicular to cortical surface now...\n');
			
			cortical_normal=dip{i}(4:6,:);	%normal vector to the cortical surface for the decimated dipoles.

			if(size(A_2D_tmp{i},2)==nperdip.*length(dec{i}))
				A3D_tmp{i}=reshape(A_2D_tmp{i},[size(A_2D_tmp{1},1),nperdip,length(dec{i})]);
				A2D_tmp{i}=zeros(size(A_2D_tmp{i},1),length(dec{i}));
				for k=1:size(A3D_tmp{i},1)
					A2D_tmp{i}(k,:)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_normal,1);
				end;
				A_2D_tmp{i}=A2D_tmp{i};
				fprintf('Cortical constraint applied!!\n');
			else
				fprintf('Dimension of forward solution does not match the dimension of decimated dipole!\n');
				fprintf('size(A)=%s; size(dec)=%s nperdip=%d\n',mat2str(size(A_2D_tmp{i})),mat2str(size(dec{i})),nperdip);	
			end;
		end;

	elseif(nperdip==1)
		fprintf('1 directional dipoles in original forward solution...\n');
	
	else
		fprintf('%d directional dipoles at each cortical surface location...\n',nperdip);
		fprintf('Confusion about cortical surface constraint. GIVE UP CORTICAL SURFACE CONSTRAINT!\n');
	end;

else
	fprintf('no cortical constraint applied! all x, y and z directional dipoles are estimated!\n');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	collapse forward solutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. COLLAPSE FORWARD SOLUTIONS...\n',process_id);
process_id=process_id+1;

%A_EEG_3D=[];
%for i=1:size(file_eeg_forward,1)
%	A_EEG_3D=cat(3,A_EEG_3D,A_EEG_3D_tmp{i});
%end;

%A_MEG_3D=[];
%for i=1:size(file_meg_forward,1)
%	A_MEG_3D=cat(3,A_MEG_3D,A_MEG_3D_tmp{i});
%end;

A=[];
for i=1:length(A_2D_tmp)
	A=cat(2,A,A_2D_tmp{i});
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Remove bad channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. REMOVE BAD CHANNEL...\n',process_id);
process_id=process_id+1;

if(~isempty(BAD))

	if(isempty(C))
		fprintf('Empty noise covariance matrix!\n');
		C=eye(n_eeg+n_meg);
	end;
	
	%EEG
	eeg_idx=BAD(2,find(BAD(1,:)==0));
	if(~isempty(eeg_idx))
		A(eeg_idx,:)=0;
		C(eeg_idx,:)=0;
		C(:,eeg_idx)=0;
		fprintf('EEG bad channel %s removed!\n',mat2str(eeg_idx));
		fprintf('(NOTE: channel numbers are 1-based!)\n');
	end;
	
	%MEG
	meg_idx=BAD(2,find(BAD(1,:)==1));
	if(~isempty(meg_idx))
		A(n_eeg+meg_idx,:)=0;
		C(n_eeg+meg_idx,:)=0;
		C(:,n_eeg+meg_idx)=0;
		fprintf('MEG bad channel %s removed!\n',mat2str(meg_idx));
		fprintf('(NOTE: channel numbers are 1-based!)\n');
	end;
end;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Normalize forward solution
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. NORMALIZE FORWARD SOLUTION...\n',process_id);
process_id=process_id+1;

sumeeg=0;

summeg=0;

sumeeg=sumeeg+sum(sum(A(1:n_eeg,:).^2));

summeg=summeg+sum(sum(A(n_eeg+1:n_eeg+n_meg,:).^2));

if(sumeeg>0.0) sumeeg=sqrt(sumeeg./(size(A,2)./nperdip)./n_eeg); end;

if(summeg>0.0) summeg=sqrt(summeg./(size(A,2)./nperdip)./n_meg); end;


A(1:n_eeg,:)=A(1:n_eeg,:)./sumeeg;
A(n_eeg+1:n_eeg+n_meg,:)=A(n_eeg+1:n_eeg+n_meg,:)./summeg;

A=A./sqrt(sum(sum(A.^2))./(size(A,2)/nperdip));

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Process the dipole prior
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. PROCESS DIPOLE PRIOR INFO...\n',process_id);
process_id=process_id+1;
if(~isempty(file_prior))
	%fprintf('<<<Under construction...Prior is set to an identify matrix>>>\n');

	for i=1:size(file_prior,1)
		prior{i}=inverse_read_prior(file_prior{i});
	end;

	count=0;
	for i=1:length(DEC)
		count=count+length(find(DEC{i}));
	end;

	R=zeros(1,size(A,2));
	nn=floor(size(A,2)/count);

	offset=0;
	for i=1:length(DEC)
		index_dec=find(DEC{i})-1;
		index_prior=prior{i}.dipole_index;
		data_prior=prior{i}.dipole_prior;
		[c,ia,ib]=intersect(index_prior,index_dec);
        fprintf('[%d] coincided fMRI prior dipoles...\n',length(ia));
		for j=1:nn
			R(offset+ib*nn+j)=data_prior(ia);
		end;
		offset=offset+nn*length(index_dec);
	end;


	if(flag_prior_continous) 	%use continouse prior values
        fprintf('using CONTINUOUS prior!\n');
        R=abs(R);
	else				%use thresholded prior values
        fprintf('using DISCRETE prior!\n');
		idx=find(abs(R)>=prior_threshold);
		R(idx)=1;
		idx=find(abs(R)<prior_threshold);
		R(idx)=prior_min;
	end;
else
	fprintf('No prior information is created/read!\n');
	R=[];
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varargout{1}=A;
output_count=1;
fprintf('output[%d]--> forward operator [A]\n',output_count);
output_count=output_count+1;

varargout{2}=R;
fprintf('output[%d]--> prior [R]\n',output_count);
output_count=output_count+1;

varargout{3}=C;
fprintf('output[%d]--> noise covariance [C]\n',output_count);
output_count=output_count+1;




fprintf('\nINVERSE PREPARATION DONE!!\n');








