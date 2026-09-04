close all; clear all;
% Calculate the g-factor map by an iterative solver
% "G-factor Maps of Conjugate Gradient SENSE Reconstruction", Liu et al.,
% Proc. ISMRM (2008): 1285

%load data
load b1_8ch.mat; %coil sensitivity maps

load mprage_slice160.mat; %a structural image
data=imcrop(data,[32    26   194   194]);


R={
    [2 2],
    };

matrix={[64 64]};

SNR=[100]; %amplitude SNR

output_stem='8ch_itr_gfactor';

for m_idx=1:length(matrix)
    for snr_idx=1:length(SNR)
        %_______________________________________________________________
        %setting up sensitivity maps
        for i=1:8
            b1_tmp=imresize(b1(:,:,i),matrix{1});
            B1(:,:,i)=b1_tmp;
        end;
        b1=B1;
        %_______________________________________________________________
        
        
        %_______________________________________________________________
        %setting up the ground truth
        
        x=imresize(data,matrix{1});
        x=etc_threshold(x,0.95);
        x0=x;
        
        mask=ones(size(x)).*eps;
        mask(find(x>mean(x(:))./2))=1;
        mask=imfill(mask,'holes');
        mask(find(mask(:)<eps))=eps;
        
        
        ORIG=zeros(matrix{m_idx}(1),matrix{m_idx}(2),8);
        
        for i=1:8
            ORIG(:,:,i)=imresize(x.*b1(:,:,i),matrix{m_idx});
        end;
        
        rms_ref=zeros(size(ORIG(:,:,1)));
        for i=1:8
            rms_ref=rms_ref+abs(ORIG(:,:,i)).^2;
        end;
        rms_ref=sqrt(rms_ref./8);
        
        ACC=zeros(size(ORIG));
        
        %simulate noises based on a given SNR
        noise=randn(size(ORIG))+sqrt(-1).*randn(size(ORIG));
        noise_power=sum(abs(noise(:)).^2);
        signal_power=sum(abs(ORIG(:)).^2);
        noise=noise./sqrt(noise_power).*sqrt(signal_power)./SNR(snr_idx);
        
        %combine "signal" and "noise"
        orig=ORIG+noise;
        %_______________________________________________________________
        
        
        
        %_______________________________________________________________
        %setting up graident fields
        n_freq=matrix{m_idx}(2);
        n_phase1=matrix{m_idx}(1);
        
        [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase1/2) :1:ceil(n_phase1/2)-1]);
        grid_freq=fmri_scale(grid_freq,ceil(n_freq/2)-1,-floor(n_freq/2));
        grid_phase=fmri_scale(grid_phase,ceil(n_phase1/2)-1,-floor(n_phase1/2));
        
        G_general(:,:,1)=grid_phase;
        G_general(:,:,2)=grid_freq;
        %_______________________________________________________________
        
        
        
        
        for r_idx=1:length(R)
            %_______________________________________________________________
            %sampling of gradient-field encoded data
            for g_idx=1:1
                K{g_idx}=zeros(n_phase1,n_freq);
                K{g_idx}(1:R{r_idx}(1):end,1:R{r_idx}(2):end)=1;
                
                [k_phase1,k_freq, k_phase2]=ind2sub(matrix{1},find(K{g_idx}));
                
                k_phase1=((k_phase1-1)-n_phase1./2)./n_phase1.*2;
                k_freq=((k_freq-1)-n_freq./2)./n_freq.*2;
                K_general=[k_phase1(:) k_freq(:)];
            end;
            %_______________________________________________________________
            
            
            %_______________________________________________________________
            % time-domain recon::encoding
            tic;
            [ACC_enc]=mri_patloc_tdr_forward_op('n_freq',matrix{m_idx}(2),'n_phase',matrix{m_idx}(1),'S',b1,'flag_display',1,'K_general',K_general,'G_general',G_general,'X',x0);
            time_encoding_matrix=toc;

            %simulate noises based on a given SNR
            noise=randn(size(ACC_enc))+sqrt(-1).*randn(size(ACC_enc));
            noise_power=sum(abs(noise(:)).^2);
            signal_power=sum(abs(ACC_enc(:)).^2);
            noise=noise./sqrt(noise_power).*sqrt(signal_power)./SNR(snr_idx);

            
            %combine "signal" and "noise"
            ACC_enc=ACC_enc+noise;
            
            % time-domain recon::decoding
            tic;
            [recon_opt,recon_history_opt,error_opt]=itdr4_core_ktraj_cg('n_freq',matrix{m_idx}(2),'n_phase',matrix{m_idx}(1),'Y',ACC_enc,'S',b1,'flag_display',0,'K_general',K_general,'G_general',G_general,'iteration_max',50,'epsilon',1e-80);
            time_recon=toc;            
            %_______________________________________________________________
            
            %_______________________________________________________________
            % assemble results
            Recon_opt=zeros(size(recon_opt));
            for i=1:8
                Recon_opt=Recon_opt+abs(recon_opt.*b1(:,:,i)).^2;
            end;
            Recon_opt=sqrt(Recon_opt./8);
            
            Recon_history_opt=zeros(size(recon_history_opt));
            for j=1:size(recon_history_opt,3)
                for i=1:8
                    Recon_history_opt(:,:,j)=Recon_history_opt(:,:,j)+abs(recon_history_opt(:,:,j).*b1(:,:,i)).^2;
                end;
                Recon_history_opt(:,:,j)=sqrt(Recon_history_opt(:,:,j)./8);
            end;
            %_______________________________________________________________
            
            
            
            g_1=zeros(matrix{1});
            g_2=zeros(matrix{1});
            mm=zeros(matrix{1});
            %only calculate a fraction of image voxels because the
            %computation is slow!
            mm(1:4:end,1:4:end)=1;
            mm(1:end,1:end)=1;
            ll=find(mm(:));
            tic;
            g_1_tmp=zeros(length(ll),1);
            g_2_tmp=zeros(length(ll),1);
            parfor v_idx=1:length(ll)
                fprintf('[%04d|%04d]:: %1.1f%%...\r',v_idx,length(ll),v_idx./length(ll).*100);
                b=zeros(matrix{1});
                b(ll(v_idx))=1;
                [recon,recon_history_optd0,d0,g2]=itdr4_core_ktraj_cg('n_freq',matrix{m_idx}(2),'n_phase',matrix{m_idx}(1),'Y',{b},'S',b1,'flag_display',0,'K_general',K_general,'G_general',G_general,'iteration_max',20,'epsilon',1e-80,'flag_cg_gfactor',1);
                g_1_tmp(v_idx)=recon(ll(v_idx));
                g_2_tmp(v_idx)=g2(ll(v_idx));
            end;
            g_1(ll)=g_1_tmp(:);
            g_2(ll)=g_2_tmp(:);
            t_cpu=toc;
            fprintf('\n');
            gfactor=sqrt(real(g_1).*real(g_2));

            imagesc(mask.*gfactor); colorbar; axis off image;
            r_stem=sprintf('[%dx%d]',R{r_idx});
            exportgraphics(gcf,sprintf('%s_%s.png',output_stem,r_stem),'Resolution',300);
            
            imagesc(mask./gfactor,[0 1]); colorbar; axis off image;
            r_stem=sprintf('[%dx%d]',R{r_idx});
            exportgraphics(gcf,sprintf('%s_inv_%s.png',output_stem,r_stem),'Resolution',300);


            
        end;
    end;
end;

return;

