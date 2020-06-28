clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%0. Here are some defaults (And customized setup)
%%%%%%%%%%%%%%%%%%%%%%%%%%%


file_dip={
'/space/sake/5/users/iiro/002411ij/mspace/bem/lh.dip',
'/space/sake/5/users/iiro/002411ij/mspace/bem/rh.dip',
};


file_dec={
'/space/sake/5/users/iiro/002411ij/mspace/bem/lh-10.dec',
'/space/sake/5/users/iiro/002411ij/mspace/bem/rh-10.dec',
};

file_badchannel='/space/sake/5/users/iiro/002411ij/mspace/scripts/chan.bad';					%you can set it to '' (empty string)
%file_badchannel='';


file_noisecovariance='/space/sake/5/users/iiro/002411ij/mspace/data/noise2.ncov';				%you can set it to '' (empty string)

file_meg_forward={
'/space/sake/5/users/iiro/002411ij/mspace/bem/lh-10.mfwd',
'/space/sake/5/users/iiro/002411ij/mspace/bem/rh-10.mfwd',
};

file_eeg_forward='';

file_prior='';						%you can set it to '' (empty string)

file_measure_mat='/space/allo/5/users/fhlin/inverse/inverse_check/devs_258.mat';

file_output='iiro_010601';				%output file stem; Thiis is for IOP and STC file.



snr=5;							% set the SNR of data; if snr==0, it does not change any recorded data.
							% Otherwise it changes the nosie matrix for specified SNR (see process 5).
 
regularize_constant=0.01;  				% for noise matrix regularization in process 5.
							% 0.01 is the value set by nlinest.c

nperdip=3;						%total number of dipole component for 1 dipole

nctype='diag';						%only diagonal entries of noise covairance are non-zero; this is the same as the old stream where "nc" is set to "2".

stnorm=0.5;						%l-p norm of spatiotemporal cost

dipole_filter=[1 30];					%cut-off frequency (Hz) of bandpass filter for the estimated dipole (defualt: bandbass between 1Hz and 30 Hz)






flag_cortical_constraint=0;				%cortical constraint; if it is set to 1, only dipole prependicular to the cortical surface will be estimated. Otherwise, it would be 3 directional dipole (x,y and z components) for each cortical location. 
flag_iop_stnorm=0;					%modify IOP for spatiotemporal norms
flag_iop_file_output=0;					%write IOP in a file
flag_noise_normalized_iop=0;				%noise sensitivity nromalized IOP
flag_bad_channel_excluded=1;				%excluding bad channels
flag_estimate_dipole=1;					%estimate dipoles using the derived inverse operator.
flag_filter_dipole=1;					%filter the dipole estimates using a band-pass filter defined by dipole_filter;
flag_write_stc=1;					%write output STC file
		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_output_stem=sprintf('%s_cort%d_nn%d_nperdip%d_stnorm%d',file_output,flag_cortical_constraint,flag_noise_normalized_iop,nperdip,flag_iop_stnorm);
fprintf('\nOutput file stem=[%s]\n\n',file_output_stem);

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
	[A_EEG_3D_tmp{i},A_EEG_2D_tmp{i}]=inverse_read_fwd(file_eeg_forward{i},nperdip);
end;
if(length(A_EEG_3D_tmp)>0)
	n_eeg=size(A_EEG_3D_tmp{1},1);
else
	n_eeg=0;
end;

A_MEG_3D_tmp={};
A_MEG_2D_tmp={};
for i=1:size(file_meg_forward,1)
	[A_MEG_3D_tmp{i},A_MEG_2D_tmp{i}]=inverse_read_fwd(file_meg_forward{i},nperdip);
end;
if(length(A_MEG_3D_tmp)>0)
	n_meg=size(A_MEG_3D_tmp{1},1);
else
	n_meg=0;
end;


for i=1:max(length(A_EEG_2D_tmp),length(A_MEG_2D_tmp))
	if(length(A_EEG_2D_tmp)>0&length(A_MEG_2D_tmp)>0)
		A_2D_tmp{i}=[A_EEG_2D_tmp{i};A_MEG_2D_tmp{i}];
	elseif(length(A_EEG_2D_tmp)>0)
		A_2D_tmp{i}=[A_EEG_2D_tmp{i}];
	elseif(length(A_MEG_2D_tmp)>0)
		A_2D_tmp{i}=[A_MEG_2D_tmp{i}];
	end;		
end;

% sensor noise covariance matrix
C=inverse_read_ncov(file_noisecovariance,n_eeg,n_meg,nctype);

% bad channels
BAD=inverse_read_badchannel(file_badchannel);

% dipole prior information
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
				fprintf('size(A)=%s; size(dec)=%s nperdip=%d\n',mat2str(size(A)),mat2str(size(dec{i})),nperdip);	
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

A_EEG_3D=[];
for i=1:size(file_eeg_forward,1)
	A_EEG_3D=cat(3,A_EEG_3D,A_EEG_3D_tmp{i});
end;

A_MEG_3D=[];
for i=1:size(file_meg_forward,1)
	A_MEG_3D=cat(3,A_MEG_3D,A_MEG_3D_tmp{i});
end;

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

fprintf('<<<Under construction...Prior is set to an identify matrix>>>\n');
%if(flag_gain_normalize_prior)
%
%	R=normalize_prior();
%end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Get partial product : A*R*A'
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. GET PARTIAL INVERSE OPERATOR (A*R*At)...\n',process_id);
process_id=process_id+1;

% if there is NO prior dipole information
if(isempty(R))
	R=ones(1,size(A,2));
end;

Matrix_ARAt=(A.*repmat(R,[size(A,1),1]))*A';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Regularize the noise covariance
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. NOISE COVARIANCE MATRIX REGULARIZATION...\n',process_id);
process_id=process_id+1;

if(~isempty(C))
	%regularize the noise matrix
	fprintf('Regularizing noise covariance matrix...\n');

	C=inverse_regularize_matrix(C,regularize_constant);

else
	
	fprintf('Empty noise covariance matrix!\n');
	
	C=eye(n_eeg+n_meg).*(1+regularize_constant);

end;



if(snr>0)
	
	fprintf('Adjusting noise covariance matrix based on given SNR...\n');

	
	noise_power=trace(C)./size(C,1); % get the power of noise
	
	signal_power=trace(Matrix_ARAt)./size(Matrix_ARAt,1); % get the power of noise
	
	C=C.*(signal_power/(noise_power*snr*snr));	%scale the noise matrix of specified SNR

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Inverse the sum of signal matrix (ARA') and noise matrix (C)
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. INVERSION FOR INVERSE OPERATOR...\n',process_id);
process_id=process_id+1;

mm=Matrix_ARAt+C;



Matrix_SN=(Matrix_ARAt+C);
Matrix_SN_inv=inv(Matrix_SN);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Get the minimum L-2 norm inverse operator
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. FINALIZE MIN-NORM INVERSE OPERATOR...\n',process_id);
process_id=process_id+1;

W=A'*Matrix_SN_inv;

for i=1:size(W,2)
	W(:,i)=W(:,i).*R';
end;
W_mn=W;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Spatio-temporal norm IOP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. MODIFY IOP FOR SPATIOTEMPORAL NORM...\n',process_id);
process_id=process_id+1;


if(flag_iop_stnorm)

	if(~isempty(file_measure_mat))
		tmp=load(file_measure_mat,'B');
		Y=tmp.B;
	end;


	
	[W]=inverse_stnorm(W, A,Y,C,R,Matrix_SN,stnorm);
	W_stnorm=W;



else

	fprintf('SKIP SPATIOTEMPORAL NORM IOP!\n');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Noise sensitivy normalized IOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. NOISE SENSITIVITY NORMALIZED IOP...\n',process_id);
process_id=process_id+1;

if(flag_noise_normalized_iop)
	mm=C*W';
	
	for i=1:size(W,1)
		nd(i)=W(i,:)*mm(:,i);
	end;
	nd=sqrt(nd)';
	ND=repmat(nd,[1,size(W,2)]);
	W=W./ND;

%	ND=diag(1./diag(sqrt(W*C*W')));
%	W=ND*W;
else
	fprintf('SKIP NOISE SENSITIVITY NORMALIZATION!\n');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Shape 3D inverse operator
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. SHAPING 3D INVERSE OPERATOR...\n',process_id);
process_id=process_id+1;

if(nperdip==1 | flag_cortical_constraint)
	
	W_3D=reshape(W,[1,size(W,1),n_eeg+n_meg]);
else

	W_3D=reshape(W,[nperdip,size(W,1)/nperdip,n_eeg+n_meg]);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%12. writing IOP into file
%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('\n\n%d. WRITING INVERSE OPERATOR INTO FILE...\n',process_id);
process_id=process_id+1;

if((flag_iop_file_output)&(~isempty(file_iop)))
	file_iop=sprintf('%s.iop',file_output_stem);
	fprintf('writing IOP [%s]...\n',file_iop);
	inverse_write_iop(W_3D,n_eeg,n_meg,1,find(DEC),file_iop);
else
	fprintf('\n\nSKIP WRITING INVERSE OPERATOR INTO FILE!\n');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%

%13. calculation dipole estimates

%%%%%%%%%%%%%%%%%%%%%%%%%%%



if(flag_estimate_dipole)
	
	fprintf('\n\n%d. Calculating dipole estimates...\n',process_id);
	
	process_id=process_id+1;

	
	if(~isempty(who('Y')))		
		
		fprintf('estimating dipoles...\n');
		
		X=W*Y;
	
	elseif(~isempty(file_measure_mat))
		
		fprintf('loading measurement data...\n');
		
		tmp=load(file_measure_mat,'B');
		
		fprintf('estimating dipoles...\n');
		
		X=W*(tmp.B);
	
	else
		
		fprintf('CANNOT LOAD MEASUREMENT!!\n');
		
		fprintf('SKIP DIPOLE ESTIMATION!!\n');
	
	end;

else
	
	fprintf('\n\nSKIP DIPOLE ESTIMATION!\n');

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%

%14. writing STC file

%%%%%%%%%%%%%%%%%%%%%%%%%%%



if(flag_write_stc)
	
	fprintf('\n\n%d. Writing STC file...\n',process_id);
	
	process_id=process_id+1;

	
	if(~isempty(who('X')))
		
		if(nperdip==1|flag_cortical_constraint)

		
		else
				
			%collapse 3 directional components into magnitude
				
			fprintf('collapsing 3 directional dipole componenets into magnitude...\n');
				
			X=reshape(X,[nperdip,size(X,1)/nperdip,size(X,2)]);
				
			X=squeeze(sum(X.^2,1));
		
		end;
		
		
		%X=fmri_scale(X,10,0); 				%normalize dipole estiamtes between 0 and 10 (for EASYMEG rendering)
		
			
		if(~isempty(file_measure_mat))
			tmp=load(file_measure_mat,'sfreq');
			sample_time=1/(tmp.sfreq)*1000.0;	%sample period in msec
	
			tmp=load(file_measure_mat,'t0');
			init_latency=(tmp.t0).*1000.0;		%MEG recording initial latency
		else
			sample_time=2;				%2 msec sample period
			init_latency=0;				%0 msec recording initial latency
		end;
			
		fprintf('Sampling period = [%3.3f] msec\n', sample_time);
		fprintf('Init latency = [%3.3f] msec\n', init_latency);

		offset=0;
		for i=1:length(dec)
			file_stc=sprintf('%s_%02d.stc',file_output_stem,i);
			fprintf('writing STC [%s]...\n',file_stc);
			x=X(offset+1:offset+length(dec{i}),:);
			
			max(max(x))
			min(min(x))
			
			if(flag_filter_dipole)
				fprintf('\nFiltering dipole estimates using a band pass filter between %s (Hz)...\n',mat2str(dipole_filter));
				x=inverse_filter(x,dipole_filter,1/sample_time.*1000);
			end;
			
			max(max(x))
			min(min(x))

			x=fmri_scale(x,10,0);	%scale the dipole estimates between 10 and 1
			offset=offset+length(dec{i});

			inverse_write_stc(x,dec{i}-1,init_latency,sample_time,file_stc); 
		end;
	else
		
		fprintf('NO DIPOLE ESTIMATES!!\n');
		
		fprintf('SKIP WRITING STC FILE!!\n');
	
	end;

else
	
	fprintf('\n\nSKIP WRITING STC FILE!\n');

end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fprintf('\nINVERSE OPERATOR DONE!!\n');








