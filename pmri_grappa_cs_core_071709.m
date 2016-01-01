function [R,G,C]=pmri_grappa_cs_core(varargin)
%
%	pmri_grappa_cs_core		perform CS GRAPPA reconstruction
%
%
%	[R]=pmri_grappa_cs_core('obs',obs,'sample_array',sample_array,'flag_display', 1);
%
%	INPUT:
%	obs: input accelerated data of [n_PE1, n_PE2, n_FE, n_chan].
%		n_PE1: # of phase encoding
%		n_PE2: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	sample_array: 2D array with entries of 0 or 1 or: [n_PE2, n_PE2].
%		n_PE: # of phase encoding steps before acceleration
%		"0" indicates the correponding entries are not sampled in accelerated scan.
%		"1" indicates the correponding entries are sampled in accelerated scan.
%		"2" indicates the correponding entries are auto-calibrating scan
%		(ACS)
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%
%	OUTPUT:
%	R: GRAPPA reconstruction of [n_PE1, n_PE2, n_FE, n_chan].
%		n_PE1: # of phase encoding
%		n_PE2: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%   fhlin@jul. 13, 2009
%	fhlin@mar. 20, 2005
%   fhlin@nov. 10, 2005

R=[];
P=[];

obs=[];

sample_array=[];
prior_half_acs=[];

flag_display=0;
flag_graphic_display=1;
flag_reg=0;
flag_smooth_constraint=0;

phase_encode_grappa_block=2;
freq_encode_grappa_block=1;
freq_encode_grappa_block_fraction=[];

flag_recon_l2=0;
flag_recon_l1=1;
flag_recon_l1_wavelet=0;
flag_recon_l1_TV=0;


for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'r'
            R=option_value;
        case 'p'
            P=option_value;
        case 'g'
            G=option_value;
        case 'obs'
            obs=option_value;
        case 'sample_array';
            sample_array=option_value;
        case 'prior_half_acs'
            prior_half_acs=option_value;
        case 'phase_encode_grappa_block'
            phase_encode_grappa_block=option_value;
        case 'freq_encode_grappa_block'
            freq_encode_grappa_block=option_value;
        case 'freq_encode_grappa_block_fraction'
            freq_encode_grappa_block_fraction=option_value;
        case 'flag_reg'
            flag_reg=option_value;
        case 'flag_smooth_constraint'
            flag_smooth_constraint=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_graphic_display'
            flag_graphic_display=option_value;
        case 'flag_recon_l2'
            flag_recon_l2=option_value;
        case 'flag_recon_l1'
            flag_recon_l1=option_value;
        case 'flag_recon_l1_wavelet'
            flag_recon_l1_wavelet=option_value;
        case 'flag_recon_l1_tv'
            flag_recon_l1_TV=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

matrix_2d=[size(obs,1),size(obs,2)];
flag_2d=1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	check data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
    fprintf('\tchecking data and ACC info...\n');
end;


%prepare frequency encoding block indices (cyclic indices)
freq_idx=[];
for j=-freq_encode_grappa_block:freq_encode_grappa_block
    freq_idx=cat(1,freq_idx,[j:j+size(obs,3)-1]);
end;
freq_idx=freq_idx+1;
freq_idx=mod(freq_idx,size(obs,3));
freq_idx(find(freq_idx==0))=size(obs,3);

if(~isempty(freq_encode_grappa_block_fraction))
    dd=max(abs(freq_idx-round(size(obs,3)./2)),[],1);
    freq_exclude_idx=find(dd>round(size(obs,3).*freq_encode_grappa_block_fraction/2));
    freq_idx(:,freq_exclude_idx)=[];
    freq_select_idx=setdiff([1:size(obs,2)],freq_exclude_idx);
else
    freq_exclude_idx=[];
    freq_select_idx=[1:size(obs,3)];
end;


%prepare phase encoding block indices
% % sample_array=zeros(10,10);
% % idx=randperm(100);
% % idx=idx(1:25);
% % sample_array(idx)=1;
% % sample_array(3:7,4:6)=2;

%ACS data entries
acs_candidate_idx=find(sample_array(:)>(1+eps));
acs_center_x=round(size(sample_array,2)./2);
acs_center_y=round(size(sample_array,1)./2);
[acs_candidate_xx0,acs_candidate_yy0]=meshgrid([acs_center_x-prior_half_acs(2):acs_center_x+prior_half_acs(2)],[acs_center_y-prior_half_acs(1):acs_center_y+prior_half_acs(1)]);

non_sample_idx=find(sample_array(:)<eps);
R=obs;
for idx=1:length(non_sample_idx)
    acs_candidate_xx=acs_candidate_xx0;
    acs_candidate_yy=acs_candidate_yy0;

    [acc_center_y,acc_center_x]=ind2sub(size(sample_array),non_sample_idx(idx));
    [acc_candidate_xx,acc_candidate_yy]=meshgrid([acc_center_x-prior_half_acs(2):acc_center_x+prior_half_acs(2)],[acc_center_y-prior_half_acs(1):acc_center_y+prior_half_acs(1)]);

    %check if the ACS data entries are outside the k-space boundary
    acc_candidate_top_outside_idx=union(find(acc_candidate_xx(:)<eps),find(acc_candidate_yy(:)<eps));
    acc_candidate_bottom_outside_idx=union(find(acc_candidate_xx(:)>size(sample_array,2)),find(acc_candidate_yy(:)>size(sample_array,1)));
    acc_candidate_outside_idx=union(acc_candidate_top_outside_idx,acc_candidate_bottom_outside_idx);
    acc_candidate_xx(acc_candidate_outside_idx)=[];
    acc_candidate_yy(acc_candidate_outside_idx)=[];
    acs_candidate_xx(acc_candidate_outside_idx)=[];
    acs_candidate_yy(acc_candidate_outside_idx)=[];

    %get corresponding ACS data entries
    tmp=sub2ind(size(sample_array),acc_candidate_yy(:),acc_candidate_xx(:));
    acc_acs_idx=find(sample_array(tmp)>eps&sample_array(tmp)<(2-eps));
    acs_idx=sub2ind(size(sample_array),acs_candidate_yy(acc_acs_idx),acs_candidate_xx(acc_acs_idx));

    if(isempty(acc_acs_idx))
        fprintf('ERROR! leakage in ACS data! no corresponding entries for calibration!\n');
        R=[];
        return;
    else
        if(flag_graphic_display)
            hold off;
            imagesc(sample_array); hold on;
            for graphic_idx=1:length(acc_acs_idx)
                ww=1;
                hh=1;
                yy=acs_candidate_yy(acc_acs_idx(graphic_idx))-0.5;
                xx=acs_candidate_xx(acc_acs_idx(graphic_idx))-0.5;
                h(graphic_idx)=rectangle('pos',[xx yy ww hh]); set(h(graphic_idx),'linewidth',2,'facecolor','none','edgecolor','c');
                yy=acs_center_y-0.5;
                xx=acs_center_x-0.5;
                h(graphic_idx)=rectangle('pos',[xx yy ww hh]); set(h(graphic_idx),'linewidth',5,'facecolor','none','edgecolor','b');
                yy=acc_candidate_yy(acc_acs_idx(graphic_idx))-0.5;
                xx=acc_candidate_xx(acc_acs_idx(graphic_idx))-0.5;
                g(graphic_idx)=rectangle('pos',[xx yy ww hh]); set(g(graphic_idx),'linewidth',2,'facecolor','none','edgecolor','m');
                yy=acc_center_y-0.5;
                xx=acc_center_x-0.5;
                g(graphic_idx)=rectangle('pos',[xx yy ww hh]); set(g(graphic_idx),'linewidth',5,'facecolor','none','edgecolor','r');
            end;


            %prepare estimaging coefficients
            if(flag_display)
                fprintf('grappa cs recon. data entry <<%04d|%04d>> (%2.2f%%)...',non_sample_idx(idx),length(non_sample_idx),idx./length(non_sample_idx).*100);
            end;

            A_acs=[];
            for k=1:size(freq_idx,2)
                T=[];
                for tmp_idx=1:length(acc_acs_idx)
                    A_acs_tmp=obs(acs_candidate_yy(acc_acs_idx(tmp_idx)),acs_candidate_xx(acc_acs_idx(tmp_idx)),freq_idx(:,k),:);
                    tmp=permute(A_acs_tmp,[3 1 2 4]);
                    T=cat(2,T,transpose(tmp(:)));
                end;
                A_acs=cat(1,A_acs,T);
            end;

            A_acc=[];
            for k=1:size(freq_idx,2)
                T=[];
                for tmp_idx=1:length(acc_acs_idx)
                    A_acc_tmp=obs(acc_candidate_yy(acc_acs_idx(tmp_idx)),acc_candidate_xx(acc_acs_idx(tmp_idx)),freq_idx(:,k),:);
                    tmp=permute(A_acc_tmp,[3 1 2 4]);
                    T=cat(2,T,transpose(tmp(:)));
                end;
                A_acc=cat(1,A_acc,T);
            end;
            if(flag_recon_l2)
                if(size(A_acs,1)>size(A_acs,2))
                    A_recon=A_acc*inv(A_acs'*A_acs)*A_acs';
                else
                    A_recon=A_acc*A_acs'*inv(A_acs*A_acs');
                end;
            elseif(flag_recon_l1)
                if(flag_recon_l1_wavelet)
                    wavelet=[];
                    dwtmode('per');
                    for wav_idx=1:size(A_acs,2)
                        probe=zeros(1,size(A_acs,2));
                        probe(wav_idx)=1;
                        [C,L]=wavedec(probe,4,'db4');
                        wavelet(:,wav_idx)=C;
                    end;
                    inv_wavelet=inv(wavelet);

                    A_acs=A_acs*inv_wavelet;
                end;

                if(flag_recon_l1_TV)
                    tv=[];
                    for tv_idx=1:size(A_acs,2)
                        probe=zeros(1,size(A_acs,2));
                        probe(tv_idx)=1;
                        C=conv([-1 2 -1]./2,probe);
                        C=C(2:end-1);
                        tv(:,tv_idx)=C;
                    end;
                    inv_TV=inv(tv);

                    A_acs=A_acs*inv_TV;
                end;

                %factor out real/imag. parts
                A_acs_l1=[real(A_acs), imag(A_acs); (-1).*imag(A_acs), real(A_acs)];

                %expand column dimension for positive/negative signs
                A_acs_l1=cat(2,A_acs_l1,(-1).*A_acs_l1);

                A_acs_reg_rank=round(min(size(A_acs))*0.3);

                %prepare for l-1 norm minimization
                [A_acs_reg, Y_acs_reg, dummy, A_acs_reg_u]=inverse_mce_prep('A',A_acs_l1,'A_reg_rank',A_acs_reg_rank,'flag_prep_Y',0,'flag_prep_orient',0,'flag_display',0);

            end;

            for target_coil=1:size(obs,4)
                fprintf('*');
                Y_acs_tmp=obs(acs_center_y,acs_center_x,freq_select_idx,target_coil);
                Y_acs=permute(Y_acs_tmp,[3 1 2 4]);

                if(flag_recon_l2)
                    if(size(A_acs,1)>size(A_acs,2))
                        Y_recon=A_recon*Y_acs(:);
                    else
                        Y_recon=A_recon*Y_acs(:);
                    end;
                elseif(flag_recon_l1)

                    %factor out real/imag. parts
                    Y_acs_l1=cat(1,real(Y_acs),imag(Y_acs));
                    Y_acs_reg=A_acs_reg_u(:,1:A_acs_reg_rank)'*Y_acs_l1;

                    [recon,value]=inverse_mce_core(Y_acs_l1,'A_reg',A_acs_reg,'Y_reg',Y_acs_reg,'flag_estimate_orientation',0,'flag_collapse_A_reg',0,'flag_display',0,'mce_weight_order',0);

                    X_l1_pos=recon(1:length(recon)/2);
                    X_l1_neg=recon(length(recon)/2+1:end);
                    X_l1=X_l1_pos+(-1).*X_l1_neg;

                    X_l1_recon=X_l1(1:length(X_l1)/2)+sqrt(-1).*X_l1(length(X_l1)/2+1:end);

                    if(flag_recon_l1_wavelet)
                        X_l1_recon=inv_wavelet*X_l1_recon(:);
                    end;
                    if(flag_recon_l1_TV)
                        X_l1_recon=inv_TV*X_l1_recon(:);
                    end;

                    Y_recon=A_acc*X_l1_recon;
                    
                    R(acc_center_y,acc_center_x,:,target_coil)=Y_recon;
                    
                end;
            end;

            fprintf('\r');
        end;
    end;
end;

if(flag_display)
    fprintf('\ngrappa cs core done!\n');
end;

return;

