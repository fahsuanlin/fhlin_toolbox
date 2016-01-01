function [recon, recon_image, recon_image_sos]=pmri_grappa_cs_prep(varargin)
%
%	pmri_grappa_cs_prep		prepare for GRAPPA CS reconstruction
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
%	recon: GRAPPA reconstruction
%		It contains the reconstruction k-space data.
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%   fhlin@apr. 10, 2009
%	fhlin@mar. 20, 2005
%   fhlin@nov. 10, 2005

recon=[];
recon_image=[];

obs=[];

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
        case 'flag_common_coil'
            flag_common_coil=option_value;
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
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	check data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grappa_vector=sample_vector;
grappa_vector(acs_vector)=2;

sampled_vector=zeros(size(grappa_vector));
sampled_vector(find(grappa_vector))=1;

flag_recon_acs=0;
if(flag_recon_acs)
    recon_idx=find(sample_vector<eps);
else
    recon_idx=find(grappa_vector<eps);
end;

if(flag_display)
    fprintf('[%d]|[%d] samples to be reconstructed. R_effective=%1.1f...\n',length(recon_idx), length(grappa_vector),length(grappa_vector)/length(find(sampled_vector)));
end;

%prepare frequency encoding block indices (cyclic indices)
freq_idx=[];
for j=-freq_encode_grappa_block:freq_encode_grappa_block
    freq_idx=cat(1,freq_idx,[j:j+size(obs,2)-1]);
end;
freq_idx=freq_idx+1;
freq_idx=mod(freq_idx,size(obs,2));
freq_idx(find(freq_idx==0))=size(obs,2);

freq_select_idx=[1:size(obs,2)];

recon=obs;
acc_source_idx_prev=[];
A_acs=[];
Y_acs=[];
A_acc=[];

for i=1:length(recon_idx)
    for b_idx=1:length(acs_vector)
        %for b_idx=round(length(acs_vector)/2):round(length(acs_vector)/2)
        %acc_target_idx
        acc_target_idx=recon_idx(i);

        %search indices for one block
        search_idx=[1:length(acs_vector)]-b_idx;

        acc_search_idx=acc_target_idx+search_idx;
        %remove phase encoding data above the top and below the bottom
        acc_search_idx(find(acc_search_idx<=0))=[];
        acc_search_idx(find(acc_search_idx>length(grappa_vector)))=[];

        %acc_source_idx
        acc_source_idx=intersect(find(grappa_vector>eps),acc_search_idx);

        %remove phase encoding data above the top and below the bottom
        acc_idx=[1:length(acs_vector)]+1-b_idx;
        acc_idx(find(acc_idx<=0))=[];
        acc_idx(find(acc_idx>length(grappa_vector)))=[];

        acs_source_idx=acs_vector(acc_source_idx-acc_target_idx+b_idx);
        acs_target_idx=acs_vector(b_idx);


        if(flag_display)
            fprintf('ACS: %s--> %s...\t',mat2str(acs_source_idx),mat2str(acs_target_idx));
        end;

        check1=length(acc_source_idx_prev)==length(acc_source_idx);
        if(check1)
            if((~isempty(acc_source_idx))&(last_acc_source_idx==acc_source_idx))
                if(flag_display)
                    fprintf('===>{ACC: %s--> %s...}\t',mat2str(acc_source_idx),mat2str(acc_target_idx));
                end;
            end;
        else
            A_acs_prev=A_acs;
            A_acc_prev=A_acc;
            Y_acs_prev=Y_acs;
            
            A_acs=[];
            A_acc=[];
            Y_acs=[];
            flag_est=1;
        end;

        A0_acs=[];
        A0_acc=[];

        for k=1:size(freq_idx,2)
            tmp=permute(obs(acs_source_idx,freq_idx(:,k),:),[2,1,3]);
            A0_acs=cat(1,A0_acs,transpose(tmp(:)));
            tmp=permute(obs(acc_source_idx,freq_idx(:,k),:),[2,1,3]);
            A0_acc=cat(1,A0_acc,transpose(tmp(:)));
        end;

        if(size(A0_acs,2)>size(A_acs,2))
            A_acs=cat(2,zeros(size(A_acs,1),size(A0_acs,2)-size(A_acs,2)),A_acs);
        end;
        if(size(A0_acs,2)<size(A_acs,2))
            A0_acs=cat(2,A0_acs,zeros(size(A0_acs,1),size(A_acs,2)-size(A0_acs,2)));
        end;
        if(size(A0_acc,2)>size(A_acc,2))
            A_acc=cat(2,zeros(size(A_acc,1),size(A0_acc,2)-size(A_acc,2)),A_acc);
        end;
        if(size(A0_acc,2)<size(A_acc,2))
            A0_acc=cat(2,A0_acc,zeros(size(A0_acc,1),size(A_acc,2)-size(A0_acc,2)));
        end;
        
        A_acs=cat(1,A_acs,A0_acs);
        A_acc=A0_acc;
        
        Y=permute(obs(acs_target_idx,freq_select_idx,coil_idx),[2 1 3]);
        Y=Y(:);
        Y_acs=cat(1,Y_acs,Y);
        
        if(flag_est)
            %estimating interpolation coefficients
            if(rank(A_acs_prev)<min(size(A_acs_prev)))
                if(flag_display)
                    flag_underdetermined_grappa=1;
                    fprintf('under-determined recon.\t');
                end;
                if(isempty(grappa_snr))
                    grappa_snr=3;
                end;
                C=eye(size(A_acs_prev,1));
                lambda=trace(A_acs_prev*A_acs_prev')./trace(C)./grappa_snr;
                pinv_A_acs=A_acs_prev'*inv(A_acs_prev*A_acs_prev'+lambda.*C);
            else
                flag_underdetermined_grappa=0;
                if(flag_display)
                    fprintf('over-determined recon.\t');
                end;
                pinv_A_acs=inv(A_acs_prev'*A_acs_prev)*A_acs_prev';
            end;
            %coil-by-coil recon.
            for coil_idx=1:size(obs,3)
                if(flag_display)
                    if(flag_underdetermined_grappa)
                        fprintf('*');
                    else
                        fprintf('#');
                    end;
                end;
%                Y=permute(obs(acs_target_idx,freq_select_idx,coil_idx),[2 1 3]);
%                Y=Y(:);
%                beta=pinv_A_acs*Y;
                beta=pinv_A_acs*Y_acs_prev;
                recon(acc_target_idx_prev,:,coil_idx)=recon(acc_target_idx_prev,:,coil_idx)+transpose(A_acc_prev*beta);

                if(flag_underdetermined_grappa==1)
                    res=sum(Y).^2;
                    %                    fprintf('prior l2 norm=[%2.2e]\t',res);
                else
                    res=sum(abs(A_acc*beta-Y).^2)./sum(abs(Y).^2);
                    %                    fprintf('residual=[%2.2f %%]\t',res*100);
                end;
                
                %update
                flag_est=0;
            end;
            fprintf('\n');
        end;
    end;
    keyboard;
end;

recon=recon./round(length(acs_vector)/2);

for i=1:size(recon,3)
    recon_image(:,:,i)=fftshift(fft2(fftshift(recon(:,:,i))));
end;

recon_image_sos=sqrt(mean(abs(recon_image).^2,3));

if(flag_display)
    fprintf('\tgrappa cs prep done!\n');
end;

return;

