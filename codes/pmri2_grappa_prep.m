function [G,C]=pmri2_grappa_prep(varargin)
%
%	pmri2_grappa_prep		prepare for 2D GRAPPA reconstruction
%
%
%	[G]=pmri2_grappa_prep('obs',obs,'sample_matrix',sample_matrix,'acc_matrix',acc_matrix, 'flag_display', 1);
%
%	INPUT:
%	obs: input accelerated data of [n_PE1, n_PE2, n_FE, n_chan]. 
%		n_PE1: # of phase encoding 1
%		n_PE2: # of phase encoding 2
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	obs: input accelerated data of [n_PE1, n_PE2, n_chan]. 
%		n_PE1: # of phase encoding 1
%		n_PE2: # of phase encoding 2
%		n_chan: # of channel
%	sample_matrix: 2D matrix with entries of 0 or 1: [n_PE1, n_PE2].
%		n_PE1: # of phase encoding 1 before acceleration
%		n_PE2: # of phase encoding 2 before acceleration
%		"0" indicates the correponding entries are not sampled in accelerated scan.
%		"1" indicates the correponding entries are sampled in accelerated scan.
%	acc_matrix: 2D matrix with entries of 0 or 1: [n_PE1, n_PE2].
%		n_PE1: # of phase encoding 1 before acceleration
%		n_PE2: # of phase encoding 2 before acceleration
%		"0" indicates the correponding entries are sampled in accelerated scan.
%		Other numerical values indicates the correponding entries are NOT sampled in accelerated scan. 
%		But they belong to the same reconstruction kernel
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%	'flag_common_coil': value of either 0 or 1 (default: 1)
%		It indicates use same GRAPPA kernel for all coils (default) or separate GRAPPA kernels for individual coil.
%
%
%	OUTPUT:
%	G: GRAPPA reconstruction kernel
%		It contains the reconstruction coefficients and definitions of acceleration scans and auto-calibration scans.
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%   fhlin@may 10, 2006

G=[];

C=[];

obs=[];

sample_matrix=[];
acc_matrix=[];
acs_matrix=[];

flag_display=0;

flag_common_coil=0;

freq_encode_grappa_block=0;
phase1_encode_grappa_block=2;
phase2_encode_grappa_block=2;
	
for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
	case 'c'
		C=option_value;
	case 'obs'
		obs=option_value;
	case 'sample_matrix';
		sample_matrix=option_value;
	case 'acc_matrix';
		acc_matrix=option_value;
	case 'acs_matrix';
		acs_matrix=option_value;
	case 'flag_display'
		flag_display=option_value;
	case 'flag_common_coil'
		flag_common_coil=option_value;
	case 'freq_encode_grappa_block'
		freq_encode_grappa_block=option_value;
	case 'phase1_encode_grappa_block'
		phase1_encode_grappa_block=option_value;
	case 'phase2_encode_grappa_block'
		phase2_encode_grappa_block=option_value;
	otherwise
	        fprintf('unknown option [%s]!\n',option);
        	fprintf('error!\n');
        return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	check data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
	fprintf('checking data and ACC info...\n');
end;


if(flag_display)
	fprintf('estimating grappa kernel...\n');
end;

%make the observation into 4D if there is no frequency encoded data
if(ndims(obs)==3)
    obs=permute(obs,[1 2 4 3]);
end;

%finding ACC tokens
sacc=sort(acc_matrix(:)');
acc_token_idx=find(diff(sacc))+1;
acc_token_idx=[1 acc_token_idx];
acc_token=sacc(acc_token_idx);
acc_token=setdiff(acc_token,0);     % token [0] is reserved as the actual sampled data
[rr_acc,cc_acc]=ind2sub(size(acc_matrix),find(acc_matrix==0));

if(flag_display)
    fprintf('finding [%d] ACC tokens : {%s}\n',length(acc_token),mat2str(acc_token));
end;

for i=1:length(acc_token)
	if(flag_display)
		fprintf('token [%d] kernel...',acc_token(i));
	end;

    if(isempty(acs_matrix))
    	acs_idx=intersect(find(sample_matrix),find(acc_matrix==acc_token(i)));
    else
        acs_idx=intersect(find(acs_matrix),find(acc_matrix==acc_token(i)));
    end;
    [rr_acs,cc_acs]=ind2sub(size(acs_matrix),acs_idx);

    if(isempty(acs_idx))
        fprintf('cannot find ACS points!'); return;
    end;
	if(flag_display)
		fprintf('ACS points : %s...',mat2str(acs_idx));
	end;

	%prepare frequency encoding block indices (cyclic indices)
    xx=size(obs,3); %number of frequency encoded data

    freq_idx=[];
    if(freq_encode_grappa_block<xx)
        for j=-freq_encode_grappa_block:freq_encode_grappa_block
            freq_idx=cat(1,freq_idx,[j:j+xx-1]);
        end;
        freq_idx=freq_idx+1;
        freq_idx=mod(freq_idx,xx);
        freq_idx(find(freq_idx==0))=xx;
    else
        for j=-(length(xx)-1):(length(xx)-1)
            freq_idx=cat(1,freq_idx,[j:j+xx-1]);
        end;
        freq_idx=freq_idx+1;
        freq_idx=mod(freq_idx,xx);
        freq_idx(find(freq_idx==0))=xx;
    end;

  	reg=[];
	A=[];
	for j=1:length(acs_idx)
        %locate indices for local ACC data
        rr_range=abs(rr_acs(j)-rr_acc);
        [rr_range_sort,rr_range_sort_idx]=sort(rr_range);
        rr_range_step=setdiff([rr_range_sort(find(abs(diff(rr_range_sort)))); rr_range_sort(end)],0);
        rr_local_idx=find(rr_range<=rr_range_step(phase1_encode_grappa_block));
        
        cc_range=abs(cc_acs(j)-cc_acc);
        [cc_range_sort,cc_range_sort_idx]=sort(cc_range);
        cc_range_step=setdiff([cc_range_sort(find(abs(diff(cc_range_sort)))); cc_range_sort(end)],0);
        cc_local_idx=find(cc_range<=cc_range_step(phase2_encode_grappa_block));
        
        local_idx=intersect(rr_local_idx,cc_local_idx);
        %zz=zeros(64,64);
        %zz(rr_acc(local_idx),cc_acc(local_idx))=1;
        
        %calculate indices for local ACC data
        idx_rr_local_acc(:,j)=rr_acc(local_idx);
        idx_cc_local_acc(:,j)=cc_acc(local_idx);
        idx_local_acc(:,j)=sub2ind(size(acc_matrix),idx_rr_local_acc(:,j),idx_cc_local_acc(:,j));
       
		A0=[];
		for k=1:size(freq_idx,2)
            rr_idxx=repmat(idx_rr_local_acc(:,j),[length(freq_idx(:,k))*size(obs,4),1]);
            cc_idxx=repmat(idx_cc_local_acc(:,j),[length(freq_idx(:,k))*size(obs,4),1]);
            [pp_idxx,ff_idxx,ll_idxx]=ndgrid(idx_local_acc(:,j),freq_idx(:,k),[1:size(obs,4)]);
            idxx=sub2ind(size(obs),rr_idxx(:),cc_idxx(:),ff_idxx(:),ll_idxx(:));
			A0=cat(1,A0,transpose(obs(idxx)));
		end;
		if(flag_common_coil)
            A0=repmat(A0,[size(obs,4),1]);
        end;
		A=cat(1,A,A0);
        
		if(flag_display)
			%fprintf('REGRESSOR data : %s...',mat2str(idx_local_acc(:,j)));
		end;
	end;
	%the rows of A is nested: # of frequency_encoding -> # of coil -> # of phase_encoding

	%get grappa kernel for each coil from ACS data
	if(flag_display)
		fprintf('preparing ACS data...');
	end;
    
    if(flag_common_coil)  
	    Y=permute(obs(acs_idx,:,:),[2 3,1]);
	    Y=Y(:);
	    %the rows of Y is nested: # of frequency_encoding -> # of coil -> # of phase_encoding
	    if(flag_display)
		    fprintf('grappa kernel estimate...');
	    end;
    	beta=inv(A'*A)*A'*Y;		
	
    	if(flag_display)
		    fprintf('\n');
    	end;
    	G{i}.beta=beta;
    else
        for coil_idx=1:size(obs,4)
            rr_idxx=repmat(rr_acs,[1,size(obs,3)]);
            cc_idxx=repmat(cc_acs,[1,size(obs,3)]);
            ff_idxx=repmat([1:size(obs,3)],[length(rr_idxx),1]);
            ll_idxx=coil_idx.*ones(size(rr_idxx));
            acs_idxx=sub2ind(size(obs),rr_idxx(:),cc_idxx(:),ff_idxx(:),ll_idxx(:));
	        Y=obs(acs_idxx);
	        %the rows of Y is nested: # of frequency_encoding -> # of coil -> # of phase_encoding
	        if(flag_display)
		        fprintf('\ngrappa kernel estimate {coil [%d])...',coil_idx);
	        end;
    	    beta=inv(A'*A)*A'*Y;		
	
    	    G{i}.beta{coil_idx}=beta;
        end;
        if(flag_display)
            fprintf('\n');
        end;
    end;
	G{i}.token=acc_token(i);
	G{i}.phase1_encode_grappa_block=phase1_encode_grappa_block;
	G{i}.phase2_encode_grappa_block=phase2_encode_grappa_block;
	G{i}.freq_encode_grappa_block=freq_encode_grappa_block;
end;

fprintf('grappa prep done!\n');
return;

