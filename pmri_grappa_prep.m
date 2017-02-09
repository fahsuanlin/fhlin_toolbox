function [G,res, A_prep, y]=pmri_grappa_prep(varargin)
%
%	pmri_grappa_prep		prepare for GRAPPA reconstruction
%
%
%	[G]=pmri_grappa_prep('obs',obs,'sample_vector',sample_vector,'acc_vector',acc_vector, 'flag_display', 1);
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
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	example:the following indicates a R=3 acceleration for 24 PE lines with line 11, 12, 14, 15 as auto-calibration scan (ACS) lines
%		sample_vector = [1 0 0 1 0 0 1 0 0 1 1 1 1 1 1 1 0 0 1 0 0 1 0 0];
%		acc_vector    = [0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2 0 1 2];
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
%	fhlin@mar. 20, 2005
%   fhlin@nov. 10, 2005

G=[];

C=[];

obs=[];

res=[];

sample_vector=[];
acc_vector=[];
acs_vector=[];

flag_display=0;

flag_reg_prep=0;
flag_irls_prep=0;


phase_encode_grappa_block=2;
freq_encode_grappa_block=1;
freq_encode_grappa_block_fraction=[];

flag_2d=0;%2d grappa
matrix_2d=[]; %phase/partition encoding matrix for 2d grappa

grappa_snr=3; %default values of SNR for regularization paraeter estimation

acs2d_block_shift=[];

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'c'
            C=option_value;
        case 'obs'
            obs=option_value;
        case 'sample_vector';
            sample_vector=option_value;
        case 'acc_vector';
            acc_vector=option_value;
        case 'acs_vector';
            acs_vector=option_value;
        case 'flag_reg_prep'
            flag_reg_prep=option_value;
        case 'flag_irls_prep'
            flag_irls_prep=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'phase_encode_grappa_block'
            phase_encode_grappa_block=option_value;
        case 'freq_encode_grappa_block'
            freq_encode_grappa_block=option_value;
        case 'freq_encode_grappa_block_fraction'
            freq_encode_grappa_block_fraction=option_value;
        case 'flag_2d'
            flag_2d=option_value;
        case 'matrix_2d'
            matrix_2d=option_value;
        case 'grappa_snr'
            grappa_snr=option_value;
        case 'acs2d_block_shift'
            acs2d_block_shift=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;
if(~flag_2d)
    if(ndims(phase_encode_grappa_block)==1)
        phase_encode_grappa_block=[-phase_encode_grappa_block +phase_encode_grappa_block];
    end;
else
    if(isempty(acs2d_block_shift))
        acs2d_block_shift=[0 0];
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	check data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
    fprintf('\tchecking data and ACC info...\n');
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
    fprintf('\testimating grappa kernel...\n');
end;

%finding ACC tokens
sacc=sort(acc_vector);
acc_token_idx=find(diff(sacc))+1;
acc_token_idx=[1 acc_token_idx(:)'];
acc_token=sacc(acc_token_idx);
acc_token=setdiff(acc_token,0);     % token [0] is reserved as the actual sampled data

if(flag_display)
    fprintf('\tfinding [%d] ACC tokens : {%s}\n',length(acc_token),mat2str(acc_token));
end;

if(flag_2d)
    tmp=reshape(acc_vector,matrix_2d);
    tmp1=zeros(matrix_2d);
    tmp1(find(tmp==acc_token(1)))=1;
    tmp1_x=max(tmp1,[],1);
    tmp1_y=max(tmp1,[],2);
    acs2d_block_shift_scale_x=median(diff(find(tmp1_x)));
    acs2d_block_shift_scale_y=median(diff(find(tmp1_y)));
end;

for i=1:length(acc_token)
    if(flag_display)
        fprintf('\ttoken [%d] kernel...',acc_token(i));
    end;
    
    
    if(isempty(acs_vector))
        acs_idx=intersect(find(acc_vector==acc_token(i)),find(sample_vector));
    else
        acs_idx=acs_vector(find(acc_vector(acs_vector)==acc_token(i)));
    end;
    
    if(isempty(acs_idx))
        fprintf('cannot find ACS lines!'); return;
    end;
    if(flag_display)
        fprintf('\tACS lines : %s...\n',mat2str(acs_idx));
    end;
    
    
    %prepare frequency encoding block indices (cyclic indices)
    freq_idx=[];
    for j=-freq_encode_grappa_block:freq_encode_grappa_block
        freq_idx=cat(1,freq_idx,[j:j+size(obs,2)-1]);
    end;
    freq_idx=freq_idx+1;
    freq_idx=mod(freq_idx,size(obs,2));
    freq_idx(find(freq_idx==0))=size(obs,2);
    
    if(~isempty(freq_encode_grappa_block_fraction))
        dd=max(abs(freq_idx-round(size(obs,2)./2)),[],1);
        freq_exclude_idx=find(dd>round(size(obs,2).*freq_encode_grappa_block_fraction/2));
        freq_idx(:,freq_exclude_idx)=[];
        freq_select_idx=setdiff([1:size(obs,2)],freq_exclude_idx);
    else
        freq_exclude_idx=[];
        freq_select_idx=[1:size(obs,2)];
    end;
    
    reg=[];
    A=[];
    bidx=[];
    for j=1:length(acs_idx)
        if(~flag_2d)
            acc_idx=find(acc_vector==0);
            acc_idx=sort(union(acc_idx,acs_idx(j)));
            acc_block_idx=[1:length(acc_idx)];
            acc_block_idx=acc_block_idx-find(acc_idx==acs_idx(j));
            acc_block_idx=setdiff(acc_block_idx,0);
            acc_idx=setdiff(acc_idx,acs_idx(j));
            %idx=find(abs(acc_block_idx)<=phase_encode_grappa_block);
            idx=find((acc_block_idx<=max(phase_encode_grappa_block))&(acc_block_idx>=min(phase_encode_grappa_block)));
            bidx=union(bidx,acc_block_idx(idx));
        else
            acc_idx=find(acc_vector==0);
            acc_idx=sort(union(acc_idx,acs_idx(j)));
            acc_block_idx=[1:length(acc_idx)];
            acc_block_idx=acc_block_idx-find(acc_idx==acs_idx(j));
            acc_block_idx=setdiff(acc_block_idx,0);
            acc_idx=setdiff(acc_idx,acs_idx(j));
            acc_block_idx_0=acc_block_idx;
            [acc_block_idx_xx acc_block_idx_yy]=meshgrid([1:matrix_2d(2)],[1:matrix_2d(1)]);
            [acs_idx_y, acs_idx_x]=ind2sub(matrix_2d,acs_idx(j));
            acc_block_idx_1=acc_block_idx_xx-acs_idx_x-acs2d_block_shift(1).*acs2d_block_shift_scale_x;
            acc_block_idx_2=acc_block_idx_yy-acs_idx_y-acs2d_block_shift(2).*acs2d_block_shift_scale_y;
            acc_block_idx=sqrt(acc_block_idx_1.^2+acc_block_idx_2.^2);
            acc_block_idx=acc_block_idx(find(acc_vector==0));
            idx=find(acc_block_idx<=phase_encode_grappa_block);
            %keyboard;
            ii=acc_block_idx_1(acc_idx).*10.^(ceil(log10(matrix_2d(1))))+acc_block_idx_2(acc_idx);
            %bidx=union(bidx,acc_block_idx_0(idx));
            bidx=union(bidx,ii(idx));
        end;
        
        A0=[];
        for k=1:size(freq_idx,2)
            tmp=permute(obs(acc_idx(idx),freq_idx(:,k),:),[2,1,3]);
            A0=cat(1,A0,transpose(tmp(:)));
        end;
        
        
        if(size(A0,2)>size(A,2))
            A=cat(2,zeros(size(A,1),size(A0,2)-size(A,2)),A);
        end;
        
        if(size(A0,2)<size(A,2))
            A0=cat(2,A0,zeros(size(A0,1),size(A,2)-size(A0,2)));
        end;
        
        A=cat(1,A,A0);
        
        if(flag_display)
            if(flag_2d)
                [row, col]=ind2sub(matrix_2d,acc_idx(idx));
                str='';
                for k=1:length(row)
                    str=sprintf('%s {%d %d}',str,row(k),col(k));
                end;
                fprintf('\tREGRESSOR lines : %s...\r',str);
            else
                fprintf('\tREGRESSOR lines : %s...\r',mat2str(acc_idx(idx)));
            end;
        end;
    end;
    if(flag_display)
        fprintf('\n');
    end;
    %the rows of A is nested: # of frequency_encoding -> # of coil -> # of phase_encoding
    
    A_prep{i}=A;
    
    %get grappa kernel for each coil
    if(flag_display)
        fprintf('\tpreparing ACS data...\n');
    end;
    
    %preparation for kernel estimation
    rank_A=rank(A);
    
    if(rank_A<size(A,2)|flag_reg_prep)
        if(isempty(grappa_snr))
            grappa_snr=3;
        end;
        C=eye(size(A,1));
        lambda=trace(A*A')./trace(C)./grappa_snr;
        pinv_A=A'*inv(A*A'+lambda.*C);
    else
        pinv_A=inv(A'*A)*A';
    end;
    
    for coil_idx=1:size(obs,3)
        Y=permute(obs(acs_idx,freq_select_idx,coil_idx),[2 1 3]);
        Y=Y(:);
        y{i}(:,coil_idx)=Y;
        %the rows of Y is nested: # of frequency_encoding -> # of coil -> # of phase_encoding
        if(flag_display)
            fprintf('\tgrappa kernel estimate {coil [%d]}...',coil_idx);
        end;
        if(rank_A<size(A,2)|flag_reg_prep)
            beta=pinv_A*Y;
        else
            if(flag_irls_prep)
                for idx=1:10
                    fprintf('#');
                    if(idx==1)
                        beta(:,idx)=pinv_A*Y;
                    else
                        R=(Y-A*beta(:,idx-1)).*1e10;
                        R(find(abs(R)<eps))=eps;
                        beta(:,idx)=inv(A'*diag(abs(1./R))*A)*A'*diag(abs(1./R))*Y;
                    end;
                end;
            else
                beta=pinv_A*Y;
                res=sum(abs(A*beta-Y).^2);
                if(flag_display) fprintf('error=[%2.2f %%]\r',res*100); end;
            end;
        end;
        G{i}.beta{coil_idx}=beta;
    end;
    if(flag_display)
        fprintf('\n');
    end;
    
    G{i}.block_idx=bidx;
    G{i}.token=acc_token(i);
    G{i}.phase_encode_grappa_block=phase_encode_grappa_block;
    G{i}.freq_encode_grappa_block=freq_encode_grappa_block;
    G{i}.freq_encode_grappa_block_fraction=freq_encode_grappa_block_fraction;
    G{i}.freq_exclude_idx=freq_exclude_idx;
    G{i}.freq_select_idx=freq_select_idx;
    
    if(flag_2d)
        G{i}.acs2d_block_shift=acs2d_block_shift;
        G{i}.acs2d_block_shift_scale_x=acs2d_block_shift_scale_x;
        G{i}.acs2d_block_shift_scale_y=acs2d_block_shift_scale_y;
    end;
end;

if(flag_display)
    fprintf('\tgrappa prep done!\n');
end;
return;

