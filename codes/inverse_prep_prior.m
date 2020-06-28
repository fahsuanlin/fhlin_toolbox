function [varargout]=inverse_prep(varargin)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults

file_meg_forward={};
file_eeg_forward={};
file_prior={};
file_noisecovariance={};
file_noisecovariance_evoke_fif={};
file_noisecovariance_null_fif={};
file_ssp_fiff='';
file_badchannel={};
file_goodchannel={};
file_dip={};
file_dec={};
file_brain_patch={};
file_measure_mat={};
file_measure_mat_filter='';
file_measure_mat_variable='';
file_curv={};
baseline_interval=[];
cortical_area={};

flag_badchannel_neuromag=1;	%read bad channel based on Neuromag labels
flag_goodchannel_neuromag=1;	%read bad channel based on Neuromag labels

flag_mne_toolbox=0;
mne_meg_channel_name={};
mne_eeg_channel_name={};


nperdip=3;						% estimate all directional components

nctype='diag';						%only diagonal entries of noise covairance are non-zero; this is the same as the old stream where "nc" is set to "2".

flag_cortical_constraint=0;				%cortical constraint; if it is set to 1, only dipole prependicular to the cortical surface will be estimated. Otherwise, it would be 3 directional dipole (x,y and z components) for each cortical location. 
flag_cortical_constrint_cone=0;
cortical_constraint_cone={}; %radian
cortical_constraint_normal={};

flag_ssp=0;

flag_prior_continous=0;					%use the prior values from prior files. No adjustment
prior_threshold=1.0;					%the minimum of priors to be active in prior matrix (flag_prior_continous must be 0 to be effective)
prior_min=0.1;						%the value assigned to sub-threshold prior entries (flag_prior_continous must be 0 to be effective)
prior_max=0.9;



%output arguments
A=[];
R=[];
C_ncov=[];
C_null=[];
C_evoke=[];
Y=[];
BAD=[];
SSP=[];
mne_channel={};

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
        case 'file_goodchannel'
            file_goodchannel=option_value;
        case 'file_meg_forward'
            file_meg_forward=option_value;
        case 'file_eeg_forward'
            file_eeg_forward=option_value;
        case 'file_ssp_fiff'
            file_ssp_fiff=option_value;
        case 'file_brain_patch'
            file_brain_patch=option_value;
        case 'file_curve'
            file_curve=option_value;
        case 'file_measure_mat'
            file_measure_mat=option_value;
        case 'file_measure_mat_filter'
            file_measure_mat_filter=option_value;
        case 'file_measure_mat_variable'
            file_measure_mat_variable=option_value;
        case 'baseline_index'
            baseline_index=option_value;
        case 'file_noisecovariance'
            file_noisecovariance=option_value;
        case 'file_noise_covariance_null_fif',
            file_noisecovariance_null_fif=option_value;
        case 'file_noise_covariance_evoke_fif',
            file_noisecovariance_evoke_fif=option_value;
        case 'file_prior'
            file_prior=option_value;
        case 'cortical_area'
            cortical_area=option_value;
        case 'nctype'
            nctype=option_value;
        case 'flag_cortical_constraint'
            flag_cortical_constraint=option_value;
        case 'flag_cortical_constraint_cone'
            flag_cortical_constraint_cone=option_value;
        case 'cortical_constraint_cone'
            cortical_constraint_cone=option_value;
        case 'cortical_constraint_normal'
            cortical_constraint_normal=option_value;
        case 'flag_prior_continous'
            flag_prior_continous=option_value;
        case 'prior_threshold'
            prior_threshold=option_value;
        case 'prior_min'
            prior_min=option_value;
        case 'prior_max'
            prior_max=option_value;
        case 'flag_badchannel_neuromag'
            flag_badchannel_neuromag=option_value;
        case 'flag_goodchannel_neuromag'
            flag_goodchannel_neuromag=option_value;
        case 'flag_mne_toolbox'
            flag_mne_toolbox=option_value;
        case 'flag_ssp'
            flag_ssp=option_value;
        case 'mne_meg_channel_name'
            mne_meg_channel_name=option_value;
        case 'mne_eeg_channel_name'
            mne_eeg_channel_name=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option);
            return;
    end;
end;



process_id=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	Read data into matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n%d. READ DATA FROM FILES...\n',process_id);
process_id=process_id+1;

if(~flag_mne_toolbox)
	% dip and dec information
	if(~isempty(file_dip))
	    for i=1:size(file_dip,1)
    		[DIP{i},DEC{i}]=inverse_read_dipdec(file_dip{i}, file_dec{i});
	    	dec{i}=find(DEC{i});
    		dip{i}=DIP{i}(:,dec{i});
	    end;
	end;
else
	%skipping DIP/DEC files
end;

if(flag_mne_toolbox)
	if(isempty(mne_meg_channel_name))
		fprintf('loading default MEG channel names...\n');
		fp=fopen('inverse_mne_meg_channel_default.txt','r');
		for ch=1:306
			mne_meg_channel_name{ch}=fgetl(fp);
		end;
		fclose(fp);
	end;
	if(isempty(mne_eeg_channel_name))
		fprintf('loading default EEG channel names...\n');
		fp=fopen('inverse_mne_eeg_channel_default.txt','r');
		for ch=1:0
			mne_eeg_channel_name{ch}=fgetl(fp);
		end;
		fclose(fp);
	end;

	mne_eeg_badchannel_idx=[];
	mne_meg_badchannel_idx=[];
end;


% % forward solutions
% fprintf('Reading MEG/EEG forward solution...\n');
% A_EEG_3D_tmp={};
% A_EEG_2D_tmp={};
% for i=1:size(file_eeg_forward,1)
%     if(flag_mne_toolbox)
% 	fwd=mne_read_forward_solution(file_eeg_forward{i},0,0);
% 	eeg_idx=[];
% 	mne_eeg_badchannel_idx=ones(1,length(mne_eeg_channel_name));
% 
% 	for idx=1:length(fwd.sol.row_names)
% 		if(~isempty(findstr(fwd.sol.row_names{idx},'EEG')))
% 			eeg_idx=cat(1,eeg_idx,idx);
% 			mne_channel{end+1}=fwd.sol.row_names{idx};
% 		end;
% 		for ch_idx=1:length(mne_eeg_channel_name)
% 			if(strcmp(fwd.sol.row_names{idx},mne_eeg_channel_name{ch_idx}))
% 				mne_eeg_badchannel_idx(ch_idx)=0;
% 				break;
% 			end;
% 		end;
% 	end;
% 	fprintf('[%d] channel EEG forward solution...([%d] bad channels)\n',length(eeg_idx),length(find(mne_meg_badchannel_idx)));
% 	
% 	A_EEG_2D_tmp{i}=fwd.sol.data(eeg_idx,:);
% 	
% 	for ii=1:fwd.source_ori
% 		DIP{ii}=(fwd.src(ii).rr)';
% 		DIP{ii}=cat(1,DIP{ii},(fwd.src(ii).nn)');
% 
% 		DEC{ii}=zeros(size(DIP{ii},2),1);
% 		DEC{ii}(fwd.src(ii).vertno)=1;
% 
% 	    	dec{ii}=find(DEC{ii});
% 		dip{ii}=DIP{ii}(:,dec{ii});
% 	end;
%     else
% 	if(isempty(findstr(file_eeg_forward{i},'mat')))
%         	[A_EEG_3D_tmp{i},A_EEG_2D_tmp{i}]=inverse_read_fwd(file_eeg_forward{i},nperdip);
% 	else
%         	tmp=load(file_eeg_forward{i});
%         	if(isfield(tmp,'MNE_fwd'))
% 			if(isfield(tmp.MNE_fwd,'fwd'))
% 				A_EEG_2D_tmp{i}=double((tmp.MNE_fwd.fwd)');
% 			else
% 				A_EEG_2D_tmp{i}=(tmp.MNE_fwd)';
% 			end;
% 		elseif(isfield(tmp,'A'));
% 			A_EEG_2D_tmp{i}=tmp.A;
% 		end;
%     	end;
%     end;
% end;
% if(length(A_EEG_2D_tmp)>0)
%     n_eeg=size(A_EEG_2D_tmp{1},1);
% else
%     n_eeg=0;
% end;
% 
% 
% 
% 
% A_MEG_3D_tmp={};
% A_MEG_2D_tmp={};
% for i=1:size(file_meg_forward,1)
%     if(flag_mne_toolbox)
% 	fwd=mne_read_forward_solution(file_meg_forward{i},0,0);
% 	meg_idx=[];
% 	mne_meg_badchannel_idx=ones(1,length(mne_meg_channel_name));
% 
% 	for idx=1:length(fwd.sol.row_names)
% 		if(~isempty(findstr(fwd.sol.row_names{idx},'MEG')))
% 			meg_idx=cat(1,meg_idx,idx);
% 			mne_channel{end+1}=fwd.sol.row_names{idx};
% 		end;
% 		for ch_idx=1:length(mne_meg_channel_name)
% 			if(strcmp(fwd.sol.row_names{idx},mne_meg_channel_name{ch_idx}))
% 				mne_meg_badchannel_idx(ch_idx)=0;
% 				break;
% 			end;
% 		end;
% 	end;
% 	fprintf('[%d] channel MEG forward solution...([%d] bad channels)\n',length(meg_idx),length(find(mne_meg_badchannel_idx)));
% 
% 	A_MEG_2D_tmp{i}=fwd.sol.data(meg_idx,:);
% 
% 	for ii=1:fwd.source_ori
% 		DIP{ii}=(fwd.src(ii).rr)';
% 		DIP{ii}=cat(1,DIP{ii},(fwd.src(ii).nn)');
% 
% 		DEC{ii}=zeros(size(DIP{ii},2),1);
% 		DEC{ii}(fwd.src(ii).vertno)=1;
% 
% 	    	dec{ii}=find(DEC{ii});
% 		dip{ii}=DIP{ii}(:,dec{ii});
% 	end;
%     else
% 	if(isempty(findstr(file_meg_forward{i},'mat')))
% 		[A_MEG_3D_tmp{i},A_MEG_2D_tmp{i}]=inverse_read_fwd(file_meg_forward{i},nperdip);
% 	else
%         	tmp=load(file_meg_forward{i});
%         	if(isfield(tmp,'MNE_fwd'))
% 			if(isfield(tmp.MNE_fwd,'fwd'))
% 				A_MEG_2D_tmp{i}=double((tmp.MNE_fwd.fwd)');
% 			else
% 				A_MEG_2D_tmp{i}=(tmp.MNE_fwd)';
% 			end;
% 		elseif(isfield(tmp,'A'));
% 			A_MEG_2D_tmp{i}=tmp.A;
% 		end;
% 	end;
%     end;
% end;
% if(length(A_MEG_2D_tmp)>0)
%     n_meg=size(A_MEG_2D_tmp{1},1);
% else
%     n_meg=0;
% end;
% 
% 
% %splitting forwad solution if necessary to match dip/dec file
% flag_split=0;
% if(~flag_mne_toolbox)
% 	if(length(file_meg_forward)>0)
% 	    AA_MEG=A_MEG_2D_tmp{1};
% 	    if(length(file_dip)~=length(file_meg_forward))
%         	flag_split=1;
% 	    end;
% 	else
% 	    AA_MEG=[];
% 	end;
% else
% 	if(~isempty(A_MEG_2D_tmp))
% 		AA_MEG=A_MEG_2D_tmp{1};
% 		if(length(dip)>length(file_meg_forward))
% 			flag_split=1;
% 		else
% 			AA_MEG=[];
% 			flag_split=0;	%is splitted already
% 		end;
% 	else
% 		AA_MEG=[];
% 	end;
% end;
% 
% if(~flag_mne_toolbox)
% 	if(length(file_eeg_forward)>0)
% 	    AA_EEG=A_EEG_2D_tmp{1};
% 	    if(length(file_dip)~=length(file_eeg_forward))
%         	flag_split=1;
% 	    end;
% 	else
% 	    AA_EEG=[];
% 	end;
% else
% 	if(~isempty(A_EEG_2D_tmp))
% 		AA_EEG=A_EEG_2D_tmp{1};
% 		if(length(dip)>length(file_eeg_forward))
% 			flag_split=1;
% 		else
% 			AA_EEG=[];
% 			flag_split=0;	%is splitted already
% 		end;
% 	else
% 		AA_EEG=[];
% 	end;
% end;
% 
% if(flag_split)
%     fprintf('splitting forward matrix ....\n');
%     offset=0;
%     for i=1:length(dip)
%         if(~isempty(AA_MEG)) A_MEG_2D_tmp{i}=AA_MEG(:,offset*nperdip+1:offset*nperdip+length(dec{i})*nperdip); end;
%         if(~isempty(AA_EEG)) A_EEG_2D_tmp{i}=AA_EEG(:,offset*nperdip+1:offset*nperdip+length(dec{i})*nperdip); end;
%         offset=offset+length(dec{i});
%     end;
%     fprintf('end of splitting!\n');    
% end;
% 
%         
% for i=1:max(length(A_EEG_2D_tmp),length(A_MEG_2D_tmp))
% 	if(length(A_EEG_2D_tmp)>0&length(A_MEG_2D_tmp)>0)
% 		A_2D_tmp{i}=[A_EEG_2D_tmp{i};A_MEG_2D_tmp{i}];
% 	elseif(length(A_EEG_2D_tmp)>0)
% 		A_2D_tmp{i}=[A_EEG_2D_tmp{i}];
% 	elseif(length(A_MEG_2D_tmp)>0)
% 		A_2D_tmp{i}=[A_MEG_2D_tmp{i}];
% 	end;		
% end;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if(~isempty(file_noisecovariance))
% 	C_ncov=inverse_read_ncov(file_noisecovariance,n_eeg,n_meg,nctype);
% else
% 	C_ncov=[];
% end;
% 
% if(~isempty(file_noisecovariance_null_fif))
% 	C_null=inverse_get_C_fif(file_noisecovariance_null_fif,'null');
% else
% 	C_null=[];
% end;
% 
% if(~isempty(file_noisecovariance_evoke_fif))
% 	C_evoke=inverse_get_C_fif(file_noisecovariance_evoke_fif,'evoke');
% else
% 	C_evoke=[];
% end;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% % bad channels
% BAD_extra=inverse_read_badchannel(file_badchannel, flag_badchannel_neuromag);
% if(flag_mne_toolbox)
% 	BAD_mne_meg=[];
% 	BAD_mne_eeg=[];
% 	if(~isempty(BAD_extra))
% 		meg_idx=find(BAD_extra(1,:)==1)
% 		tmp=union(BAD_extra(2,meg_idx),find(mne_meg_badchannel_idx));
% 		for idx=1:length(tmp)
% 			BAD_mne_meg(2,idx)=tmp(idx);
% 			BAD_mne_meg(1,idx)=1;
% 		end;
% 
% 		eeg_idx=find(BAD_extra(1,:)==0)
% 		tmp=union(BAD_extra(2,eeg_idx),find(mne_eeg_badchannel_idx));
% 		for idx=1:length(tmp)
% 			BAD_mne_eeg(2,idx)=tmp(idx);
% 			BAD_mne_eeg(1,idx)=0;
% 		end;
% 	else
% 		tmp=find(mne_meg_badchannel_idx);
% 		for idx=1:length(tmp)
% 			BAD_mne_meg(2,idx)=tmp(idx);
% 			BAD_mne_meg(1,idx)=1;
% 		end;
% 
% 		tmp=find(mne_eeg_badchannel_idx);
% 		for idx=1:length(tmp)
% 			BAD_mne_eeg(2,idx)=tmp(idx);
% 			BAD_mne_eeg(1,idx)=0;
% 		end;
% 	end;	
% 	BAD=cat(2,BAD_mne_meg,BAD_mne_eeg);
% end;
% 
% % bad channels
% GOOD=inverse_read_badchannel(file_goodchannel, flag_goodchannel_neuromag);
% if(~isempty(GOOD))
% 	fprintf('defined GOOD channels instead of BAD channels...\n');
% 	[dummy,idx]=unique(GOOD(2,:));
% 	GOOD=GOOD(:,idx);
% 	BAD=zeros(2,306-size(GOOD,2));
% 	BAD(1,:)=1;
% 	BAD(2,:)=setdiff([1:306]',GOOD(2,:));
% end;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% %	SSP projection matrix
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% if(flag_ssp|~isempty(file_ssp_fiff))
%     if(flag_mne_toolbox)
%         fprintf('\n\n%d. SSP matrix setup and forward model whitening...\n',process_id);
%         process_id=process_id+1;
% 
%         raw=fiff_setup_read_raw(file_ssp_fiff);
%         for k=1:size(raw.info.projs)
%             raw.info.projs(k).active=true;
%         end;
%         [SSP_data,SSP_n]=mne_make_projector(raw.info.projs,raw.info.ch_names);
%         SSP_n=length(raw.info.projs);
% 
%         pick=[];
%         for ii=1:length(mne_channel)
%             for jj=1:length(raw.info.ch_names)
%                 if(strmatch(raw.info.ch_names{jj},mne_channel{ii},'exact'))
%                     pick=cat(1,pick,jj);
%                     break;
%                 end;
%             end;
%         end;
%         SSP.data=SSP_data(pick,pick);
%         SSP.n_proj=SSP_n;
% 
%         A_2D_tmp{1}=SSP.data*A_2D_tmp{1};
%     end;
% else
%     SSP=[];
% end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Cortical orientation constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. CORTICAL ORIENTATION CONSTRAINT ADJUSTMENT...\n',process_id);
process_id=process_id+1;

if(flag_cortical_constraint)
	if(nperdip==3)
		for i=1:length(dip)
			if(~flag_cortical_constraint_cone)           
				fprintf('3 directional dipoles in original forward solution...\n');
				fprintf('They will be collapsed into 1 dipole prependicular to cortical surface now...\n');
			else
				fprintf('using dipole-specific cone for cortical orientation constration...\n');
			end;
            
			if(isempty(cortical_constraint_normal))
				cortical_normal=dip{i}(4:6,:);	%normal vector to the cortical surface for the decimated dipoles.
			else
				cortical_normal=cortical_constraint_normal{i};
			end;
            
            		if(flag_cortical_constraint_cone)
				cortical_tangent1=zeros(size(cortical_normal));
				cortical_tangent1(1,:)=cortical_normal(2,:);
				cortical_tangent1(2,:)=cortical_normal(1,:).*(-1);
				cortical_tangent1(3,:)=0;
				cortical_tangent1=cortical_tangent1./repmat(sqrt(sum(cortical_tangent1.^2,1)),[3,1]);
            
				cortical_tangent2=zeros(size(cortical_normal));
				cortical_tangent2(1,:)=cortical_normal(1,:);
				cortical_tangent2(2,:)=cortical_normal(2,:);
				idx0=find(cortical_normal(3,:)==0);
				idx1=find(cortical_normal(3,:)~=0);
				cortical_tangent2(3,idx1)=(cortical_normal(1,idx1).^2+cortical_normal(2,idx1).^2)./cortical_normal(3,idx1).*(-1);
				cortical_tangent2(3,idx0)=-1.0;
				cortical_tangent2=cortical_tangent2./repmat(sqrt(sum(cortical_tangent2.^2,1)),[3,1]);            
            		end;
            
% 			if(size(A_2D_tmp{i},2)==nperdip.*length(dec{i}))
% 				A3D_tmp{i}=reshape(A_2D_tmp{i},[size(A_2D_tmp{1},1),nperdip,length(dec{i})]);
% 				
% 				if(~flag_cortical_constraint_cone)
% 					
% 					A2D_tmp{i}=zeros(size(A_2D_tmp{i},1),length(dec{i}));
%     					
%     					for k=1:size(A3D_tmp{i},1)
% 				    		A2D_tmp{i}(k,:)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_normal,1);
%     					end;
% 					
% 					A_2D_tmp{i}=A2D_tmp{i};
%            			else
% 					A2D_tmp{i}=zeros(size(A_2D_tmp{i},1),length(dec{i})*3);
% 					
% 					if(isempty(cortical_constraint_cone))
% 						fprintf('automatic contical orienatation cone...\n');
% 						if(~isempty(file_curv{i}))
% 							[curv{i}]=inverse_read_curv(file_curv{i});
% 							coritcal_constraint_cone_cell{i}=pi/2-atan(curv{i});
% 						else
% 							fprintf('no cone definition!\nerror!\n');
% 							return;
% 						end;
% 					else
% 						if((prod(size(cortical_constraint_cone))==1)&(~iscell(cortical_constraint_cone))) %same cone is applied on every dec. dipole
% 							cortical_constraint_cone_cell{i}=ones(1,size(cortical_normal,2)).*cortical_constraint_cone;
% 						else
% 							cortical_constraint_cone_cell{i}=cortical_constraint_cone{i};                        
% 						end;
% 					end;
% 
% 					for k=1:size(A3D_tmp{i},1)
% %						A2D_tmp{i}(k,1:3:end)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_normal.*repmat(cos(cortical_constraint_cone_cell{i}),[3,1]),1);
% %						A2D_tmp{i}(k,2:3:end)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_tangent1.*repmat(sin(cortical_constraint_cone_cell{i}),[3,1]),1);
% %						A2D_tmp{i}(k,3:3:end)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_tangent2.*repmat(sin(cortical_constraint_cone_cell{i}),[3,1]),1);
% 						A2D_tmp{i}(k,1:3:end)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_normal,1);
% 						A2D_tmp{i}(k,2:3:end)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_tangent1,1);
% 						A2D_tmp{i}(k,3:3:end)=sum(squeeze(A3D_tmp{i}(k,:,:)).*cortical_tangent2,1);
% 					end;
% 					A_2D_tmp{i}=A2D_tmp{i};
% 				end;
% 	   			fprintf('Cortical orientation constraint applied!!\n');
% 			else
% 				fprintf('Dimension of forward solution does not match the dimension of decimated dipole!\n');
% 				fprintf('size(A)=%s; size(dec)=%s nperdip=%d\n',mat2str(size(A_2D_tmp{i})),mat2str(size(dec{i})),nperdip);	
% 			end;
% 		end;

	elseif(nperdip==1)
		fprintf('1 directional dipoles in original forward solution...\n');
	
	else
		fprintf('%d directional dipoles at each cortical surface location...\n',nperdip);
		fprintf('Confusion about cortical surface constraint. GIVE UP CORTICAL SURFACE CONSTRAINT!\n');
	end;

else
	fprintf('no cortical constraint applied! all x, y and z directional dipoles are estimated!\n');
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% %	collapse forward solutions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fprintf('\n\n%d. COLLAPSE FORWARD SOLUTIONS...\n',process_id);
% process_id=process_id+1;
% 
% 
% if(~isempty(cortical_area))
% 	fprintf('weighting cortical area...\n');
% 	
% 	for i=1:length(A_2D_tmp)
% 		if((nperdip==1)|(flag_cortical_constraint==1&flag_cortical_constraint_cone==0))
% 			A_2D_tmp{i}=A_2D_tmp{i}.*repmat(cortical_area{i},[size(A_2D_tmp{i},1),1]);
% 		else
% 			cortical_area{i}=reshape(repmat(cortical_area{i},[3,1]),[1,3*length(cortical_area{i})]);
% 			A_2D_tmp{i}=A_2D_tmp{i}.*repmat(cortical_area{i},[size(A_2D_tmp{i},1),1]);
% 		end;
% 	end;
% end;
% 	
% A=[];
% for i=1:length(A_2D_tmp)
% 	A=cat(2,A,A_2D_tmp{i});
% end;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% %	Remove bad channel
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fprintf('\n\n%d. REMOVE BAD CHANNEL...\n',process_id);
% process_id=process_id+1;
% 
% if(~isempty(BAD))
% 
% 	%EEG
% 	eeg_idx=BAD(2,find(BAD(1,:)==0));
% 	if(~isempty(BAD_extra))
% 		eeg_extra_idx=BAD_extra(2,find(BAD_extra(1,:)==0));
% 	else
% 		eeg_extra_idx=[];
% 	end;
% 	if(~isempty(eeg_idx))
% 		A(eeg_extra_idx,:)=[];
% 		n_eeg=n_eeg-length(eeg_extra_idx);
% 		
% 		if(~isempty(R))
% 			if(min(size(R))==1)
% 				R(eeg_idx)=[];
% 			else
% 				R(eeg_idx,:)=[];
% 				R(:,eeg_idx)=[];
% 			end;
% 		end;
% 		
% 		if(~isempty(C_ncov))
% 			C_ncov(eeg_idx,:)=0;
% 			C_ncov(:,eeg_idx)=0;
% 		end;
% 		if(~isempty(C_null))
% 			C_null(eeg_idx,:)=0;
% 			C_null(:,eeg_idx)=0;
% 		end;
% 		if(~isempty(C_evoke))
% 			C_evoke(eeg_idx,:)=0;
% 			C_evoke(:,eeg_idx)=0;
% 		end;
% 		fprintf('EEG bad channel %s removed!\n',mat2str(eeg_idx));
% 		fprintf('(NOTE: channel numbers are 1-based!)\n');
% 	end;
% 	
% 	%MEG
% 	meg_idx=BAD(2,find(BAD(1,:)==1));
% 	if(~isempty(BAD_extra))
% 		meg_extra_idx=BAD_extra(2,find(BAD_extra(1,:)==1));
% 	else
% 		meg_extra_idx=[];
% 	end;
% 	if(~isempty(meg_idx))
% 		A(n_eeg+meg_extra_idx,:)=[];
% 		n_meg=n_meg-length(meg_extra_idx);
% 		
% 		if(~isempty(R))
% 			if(min(size(R))==1)
% 				R(n_eeg+meg_idx)=[];
% 			else
% 				R(n_eeg+meg_idx,:)=[];
% 				R(:,n_eeg+meg_idx)=[];
% 			end;
% 		end;
% 		
% 		if(~isempty(C_ncov))
% 			C_ncov(n_eeg+meg_idx,:)=0;
% 			C_ncov(:,n_eeg+meg_idx)=0;
% 		end;
% 		
% 		if(~isempty(C_null))
% 			C_null(n_eeg+meg_idx,:)=0;
% 			C_null(:,n_eeg+meg_idx)=0;
% 		end;
% 		
% 		if(~isempty(C_evoke))
% 			C_evoke(n_eeg+meg_idx,:)=0;
% 			C_evoke(:,n_eeg+meg_idx)=0;
% 		end;
% 		
% 		fprintf('MEG bad channel %s removed!\n',mat2str(meg_idx));
% 		fprintf('(NOTE: channel numbers are 1-based!)\n');
% 	end;
% end;	
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Process the dipole prior
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. PROCESS DIPOLE PRIOR INFO...\n',process_id);
process_id=process_id+1;
if(~isempty(file_prior))
	for i=1:length(file_prior)
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
			R(offset+(ib-1)*nn+j)=data_prior(ia);
		end;
		offset=offset+nn*length(index_dec);
	end;


	if(flag_prior_continous) 	%use continouse prior values
        	fprintf('using CONTINUOUS prior!\n');
	        R=abs(R);
	else				%use thresholded prior values
        	fprintf('using DISCRETE prior!\n');
        	idx1=find(abs(R)>=prior_threshold);
        	idx0=find(abs(R)<prior_threshold);
		fprintf('[%2.2f%%] prior exceeding threshold [%2.2f]\n',length(idx1)/length(R).*100,prior_threshold);
		R(idx1)=prior_max;
		R(idx0)=prior_min;
	end;
else
	fprintf('No prior information is created/read!\n');
	R=[];
end;

if((flag_cortical_constraint)&(flag_cortical_constraint_cone))
	cortical_constraint_cone_total=[];

	for i=1:length(dip)
		if(isempty(cortical_constraint_normal))
			cortical_normal=dip{i}(4:6,:);	%normal vector to the cortical surface for the decimated dipoles.
		else
			cortical_normal=cortical_constraint_normal{i};
		end;

		if((prod(size(cortical_constraint_cone))==1)&(~iscell(cortical_constraint_cone))) %same cone is applied on every dec. dipole
			cortical_constraint_cone_total=[cortical_constraint_cone_total,ones(1,size(cortical_normal,2)).*cortical_constraint_cone];
		else
			cortical_constraint_cone_total=[cortical_constraint_cone_total,cortical_constraint_cone{i}];                        
		end;
	end;
	cortical_constraint_cone_total(find(cortical_constraint_cone_total>pi/2))=pi/2;
	cortical_constraint_cone_total(find(cortical_constraint_cone_total<eps))=eps;
	rr=[ones(1,length(cortical_constraint_cone_total));sin(cortical_constraint_cone_total);sin(cortical_constraint_cone_total)];
	rr=reshape(rr,[1,prod(size(rr))]);
	if(~isempty(R))
		R=R.*rr;	
	else
		R=rr;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varargout{1}=R;
output_count=1;
fprintf('output[%d]--> diagonal entries of the source covariance matrix [R]\n',output_count);
output_count=output_count+1;

fprintf('\nINVERSE PREPARATION PRIOR DONE!!\n');








