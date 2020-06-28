function [R,G,C]=pmri_grappa_core(varargin)
%
%	pmri_grappa_core		perform GRAPPA reconstruction
%
%
%	[R]=pmri_grappa_core('obs',obs,'sample_vector',sample_vector,'acc_vector',acc_vector,'G',G,'flag_display', 1);
%
%	INPUT:
%	obs: input accelerated data of [n_PE, n_FE, n_chan]. 
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	sample_vector: 1D vector with entries of 0 or 1: [1, n_PE].
%		n_PE: # of phase encoding steps before acceleration
%		"0" indicates the correponding entries are not sampled in accelerated scan.
%		"1" indicates the correponding entries are sampled in accelerated scan.
%	acc_vector: 1D vector: [1, n_PE].
%		n_PE: # of phase encoding steps before acceleration
%		"0" indicates the correponding entries are sampled in accelerated scan.
%		Other numerical values indicates the correponding entries are NOT sampled in accelerated scan. 
%		But they belong to the same reconstruction kernel
%	G: GRAPPA reconstruction kernel
%		It contains the reconstruction coefficients and definitions of acceleration scans and auto-calibration scans.
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%	'flag_common_coil': value of either 0 or 1 (default: 1)
%		It indicates use same GRAPPA kernel for all coils (default) or separate GRAPPA kernels for individual coil.
%
%	example:the following indicates a R=3 acceleration for 24 PE lines with line 11, 12, 14, 15 as auto-calibration scan (ACS) lines
%		sample_vector = [1 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0];
%		acc_vector    = [0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2];
%
%	OUTPUT:
%	R: GRAPPA reconstruction of [n_PE, n_FE, n_chan]. 
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@mar. 20, 2005
%   fhlin@nov. 10, 2005

R=[];
P=[];

obs=[];

sample_vector=[];
acc_vector=[];

flag_display=0;
flag_reg=0;
flag_common_coil=1;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
	case 'p'
        P=option_value;
	case 'g'
		G=option_value;
	case 'obs'
		obs=option_value;
	case 'sample_vector';
		sample_vector=option_value;
	case 'acc_vector';
		acc_vector=option_value;
	case 'flag_common_coil'
		flag_common_coil=option_value;
	case 'flag_reg'
		flag_reg=option_value;
	case 'flag_display'
		flag_display=option_value;
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
xx=length(find(sample_vector(:)|acc_vector(:)));


if(xx~=size(obs,1))
	fprintf('ACC and sampling information error [GAP in k-space]!\n\n');
	return;
end;

xx=find(acc_vector==0);
if(length(find(sample_vector(xx)==0))>0)
	fprintf('ACC and sampling information error! [Sampling leakage]\n\n');
	return;
end;

if(flag_display)
	fprintf('estimating grappa kernel...\n');
end;

%finding ACC tokens
sacc=sort(acc_vector);
acc_token_idx=find(diff(sacc))+1;
acc_token_idx=[1 acc_token_idx];
acc_token=sacc(acc_token_idx);
acc_token=setdiff(acc_token,0);     % token [0] is reserved as the actual sampled data
if(flag_display)
    fprintf('finding [%d] ACC tokens : {%s}\n',length(acc_token),mat2str(acc_token));
end;

if(flag_display)
	fprintf('grappa reconstruction...\n');
end;

R=obs;
for i=1:length(acc_token)

	phase_encode_grappa_block=G{i}.phase_encode_grappa_block;
	freq_encode_grappa_block=G{i}.freq_encode_grappa_block;
		
	if(flag_display)
		fprintf('token [%d] kernel...',acc_token(i));
	end;

	acs_idx=intersect(find(acc_vector==acc_token(i)),find(sample_vector==0));
	if(flag_display)
		fprintf('DATA lines : %s...',mat2str(acs_idx));
	end;

	%prepare frequency encoding block indices (cyclic indices)
	freq_idx=[];
	for j=-freq_encode_grappa_block:freq_encode_grappa_block
		freq_idx=cat(1,freq_idx,[j:j+size(obs,2)-1]);
	end;
	freq_idx=freq_idx+1;
	freq_idx=mod(freq_idx,size(obs,2));
	freq_idx(find(freq_idx==0))=size(obs,2);
	
	reg=[];

    for ff=1:size(freq_idx,2)
        A=[];
    	for j=1:length(acs_idx)
    		acc_idx=find(acc_vector==0);
    		acc_idx=sort(union(acc_idx,acs_idx(j)));
    		acc_block_idx=[1:length(acc_idx)];
    		acc_block_idx=acc_block_idx-find(acc_idx==acs_idx(j));
    		acc_block_idx=setdiff(acc_block_idx,0);
    		acc_idx=setdiff(acc_idx,acs_idx(j));
    		idx=find(abs(acc_block_idx)<=phase_encode_grappa_block);
    		bidx=acc_block_idx(idx);
		
			T=zeros(length(G{i}.block_idx),size(freq_idx,1),size(obs,3));
			
			tmp=obs(acc_idx(idx),freq_idx(:,ff),:);
			[dummy,xx]=intersect(G{i}.block_idx,bidx);
			
			T(xx,:,:)=tmp;
			tmp=permute(T,[2,1,3]);
			
			A0=transpose(tmp(:));

            if(flag_common_coil)
        		A0=repmat(A0,[size(obs,3),1]);
            end;
        
    		A=cat(1,A,A0);

		    if(flag_display)
			    %fprintf('%s.',mat2str(acs_idx(j)));
                %fprintf('.');
		    end;
	    end;
	    %the rows of A is nested: # of frequency_encoding -> # of coil -> # of phase_encoding
	
        if(flag_reg)% regularized
            [v_e,sinv_e,u_e]=svd(A);
            s_e=pinv(sinv_e)';
            if(size(s_e,2)<size(s_e,1))
                s_e(:,end+1:size(s_e,1))=0;
            end;
        
            lambda=s_e(1,1)./1;
            
            Gamma=zeros(size(s_e));
   		    Gamma(:,1:size(s_e,1))=diag(diag(s_e)./(diag(s_e).^2+lambda.^2));
		
		    Phi=diag(lambda.^2./(diag(s_e).^2+lambda.^2));

            if(flag_common_coil)
                pp=P(acs_idx,:,:);
                tmp=v_e*Gamma*u_e'*G{i}.beta+v_e*(Phi*v_e'*pp(:));
                %tmp=v_e*(v_e'*pp(:));
                recon=permute(reshape(tmp,[size(freq_idx,2),size(obs,3),length(acs_idx)]),[3,1,2]);
            else
                tmp=[];
                for coil_idx=1:size(obs,3)
                    pp=P(acs_idx,ff,coil_idx);
                    tmpp=v_e*Gamma*u_e'*G{i}.beta{coil_idx}+v_e*(Phi*v_e'*pp(:));
                    %tmpp=v_e*(v_e'*pp(:));
                    tmp=cat(3,tmp,reshape(tmpp,[1,length(acs_idx)]));
                end;
                recon=permute(tmp,[2,1,3]);               
            end;
        else %unregularized
            if(flag_common_coil)
            	recon=permute(reshape(A*G{i}.beta,[size(freq_idx,2),size(obs,3),length(acs_idx)]),[3,1,2]);
            else
                tmp=[];
                for coil_idx=1:size(obs,3)
                    tmp=cat(3,tmp,reshape(A*G{i}.beta{coil_idx},[1,length(acs_idx)]));
                end;
                recon=permute(tmp,[2,1,3]);    
            end;
        end;
    
    
	    R(acs_idx,ff,:)=recon;
		
    end;
    
	if(flag_display)
		fprintf('\n');
	end;
end;

if(flag_display)
	fprintf('grappa core done!\n');
end;

return;

