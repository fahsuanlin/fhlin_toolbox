
function [k_acc_ref, Coeff, kernel] = pmri_spirit_kernel_est(k_acc, varargin)
%
% [k_acc, Coeff, kernel] =pmri_spirit_kernel_est(k_acc,....)
%
% k_acc: 3D complex valued k-space data [k_x,k_y, n_chan];
%
% k_acc: estimated noise-suppressed k-space data
% Coeff: estimated spirit reconstruction kernel over iterations
% kernel: a structure of parameters needed in estimation/application of
% spirit kernel
%
% fhlin@sep 11 2012
%



spirit_kernel_size=[1 1];
n_iteration=10;
n_l1_iteration=1;
Lambda=[0.01];
sample_matrix=[];

flag_normalize_recon_power=1;

flag_display=1;

flag_l1=0;
flag_tv=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'sample_matrix'
            sample_matrix=option_value;
        case 'spirit_kernel_size'
            spirit_kernel_size=option_value;
        case 'n_iteration'
            n_iteration=option_value;
        case 'n_l1_iteration'
            n_l1_iteration=option_value;
        case 'flag_l1'
            flag_l1=option_value;
        case 'flag_tv'
            flag_tv=option_value;
        case 'lambda'
            Lambda=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_normalize_recon_power'
            flag_normalize_recon_power=option_value;
        case 'flag_tv'
            flag_tv=option_value;
        case 'flag_l1'
            flag_l1=option_value;
        otherwise
            fprintf('unknown option [%s]...\nerror!\n',option);
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data consistency recon...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialization

k_history=[];
recon_sos_history=[];
recon_history=[];
img_history=[];



image_matrix=[size(k_acc,1),size(k_acc,2)];

if(isempty(sample_matrix))
    sample_matrix=zeros(image_matrix);
    sample_matrix(:)=1;
end;

%%%%%%%%%%%%%%%%%

%prepare kernel index matrix construction
spirit_kernel_mask=ones(spirit_kernel_size.*2+1);

base_data_idx=zeros(image_matrix);
base_data_idx(1:end)=[1:prod(image_matrix)];
data_idx=zeros(image_matrix+2.*spirit_kernel_size);

data_idx(1:spirit_kernel_size(1),:)=nan;
data_idx(end-spirit_kernel_size(1)+1:end,:)=nan;
data_idx(:,1:spirit_kernel_size(2))=nan;
data_idx(:,end-spirit_kernel_size(2)+1:end)=nan;
data_idx(spirit_kernel_size(1)+1:spirit_kernel_size(1)+image_matrix(1),spirit_kernel_size(2)+1:spirit_kernel_size(2)+image_matrix(2))=base_data_idx;

%construct kernel index matrix
spirit_idx_matrix=zeros(prod(image_matrix),prod(size(spirit_kernel_mask)));
for idx=1:prod(image_matrix)
    [rr,cc]=ind2sub(size(data_idx),find(data_idx==idx));
    
    spirit_idx_tmp=data_idx(rr-spirit_kernel_size(1):rr+spirit_kernel_size(1),cc-spirit_kernel_size(2):cc+spirit_kernel_size(2));
    spirit_idx_matrix(idx,:)=spirit_idx_tmp(:)';
end;

center_idx=(prod(spirit_kernel_size.*2+1)+1)/2;
spirit_idx_matrix(:,center_idx)=[];

spirit_idx_matrix_nan_idx=find(isnan(spirit_idx_matrix(:)));
spirit_idx_matrix_tmp=spirit_idx_matrix;
spirit_idx_matrix_tmp(spirit_idx_matrix_nan_idx)=1;

k_acc_ref=k_acc(:,:,:);
k_history(:,:,:,1)=k_acc_ref;

sample_idx=find(sample_matrix(:)>eps); %all chosen entries represented by the sample_idx will be used to estimate the kernel
recon_idx=find(sample_matrix(:)>eps); %all chosen entries represented by the recon_idx will be updated.

flag_spirit_kernel_coeff_update=0;

power_orig=real(k_acc_ref(:)'*k_acc_ref(:));

img_size=[size(k_acc_ref,1),size(k_acc_ref,2)];
%2D DFT matrix and differential matrix
F=zeros(prod(img_size),prod(img_size));
D=zeros(prod(img_size),prod(img_size));
for t=1:prod(img_size)
    im=zeros(img_size);
    im(t)=1;
    y=fftshift(fft2(fftshift(im)));
    F(:,t)=y(:);
    
    [rr,cc]=ind2sub(img_size,t);
    [xx,yy]=meshgrid(cc-1:cc+1,rr-1:rr+1);
    xx((length(xx(:))+1)/2)=0;
    yy((length(yy(:))+1)/2)=0;
    ii=find(xx(:)>=1&xx(:)<=img_size(2)&yy(:)>=1&yy(:)<=img_size(1));
    sub=sub2ind(img_size,yy(ii),xx(ii));
    D(sub,t)=-1./length(ii);
    D(t,t)=1;
end;

n_chan=size(k_acc,3);

for itr_idx=1:n_iteration
    if(flag_display)
        fprintf('DC kernel estimation iteration [%03d|%03d]...\r',itr_idx,n_iteration);
    end;
    
    %prepare spirit kernel estimate
    E=zeros(prod(image_matrix),(prod(size(spirit_kernel_mask))-1).*n_chan);
    for ch_idx=1:n_chan
        kspace=k_acc_ref(:,:,ch_idx);
        k_tmp=kspace(spirit_idx_matrix_tmp);
        k_tmp(spirit_idx_matrix_nan_idx)=0;
        E(:,(ch_idx-1)*(prod(size(spirit_kernel_mask))-1)+1:ch_idx*(prod(size(spirit_kernel_mask))-1))=k_tmp;
    end;
    
    E_prep=inv(E(sample_idx,:)'*E(sample_idx,:))*E(sample_idx,:)';
    
    AtA=E(sample_idx,:)'*E(sample_idx,:);
    epss=1e-8;
    
    if(itr_idx==1)
        FE=F*E(recon_idx,:);
        DFE=D*FE;
    end;
    
    %estimate spirit kernel
    for ch_idx=1:n_chan
        kspace=k_acc_ref(:,:,ch_idx);
        %coeff(:,ch_idx)=E_prep*kspace(sample_idx);
        Aty=E(sample_idx,:)'*kspace(sample_idx);
        
        if(flag_l1)
            D_l1=eye(prod(img_size)); %an initial diagonal weighting matrix for min. L1-norm optimization
        elseif(flag_tv)
            D_tv=eye(prod(img_size)); %an initial diagonal weighting matrix for TV regularization
        else
            D_l2=eye(prod(img_size)); %an initial diagonal weighting matrix for min. L2-norm optimization
        end;
        
        for l1_itr_idx=1:n_l1_iteration
            
            if(flag_l1)
                Ml1=D_l1*FE;
                Ml1tMl1=Ml1'*Ml1;
                lambda=trace(AtA)/trace(Ml1tMl1)*Lambda(1);
                x_l1_itr(:,l1_itr_idx)=(AtA+lambda*(Ml1tMl1))\(Aty); %min. L-2 norm solution
                D_l1=diag(1./sqrt(epss+abs(FE*x_l1_itr(:,l1_itr_idx)))); %update the diagonal weighting matrix for min. L1-norm optimization
            elseif(flag_tv)
                Mtv=D_tv*DFE;
                MtvtMtv=Mtv'*Mtv;
                lambda=trace(AtA)/trace(MtvtMtv)*Lambda(1);
                x_tv_itr(:,l1_itr_idx)=(AtA+lambda*(MtvtMtv))\(Aty); %min. L-2 norm solution
                D_tv=diag(1./sqrt(epss+abs(DFE*x_tv_itr(:,l1_itr_idx)))); %update the diagonal weighting matrix for TV regularization
            else
                Ml2=FE;
                Ml2tMl2=Ml2'*Ml2;
                lambda=trace(AtA)/trace(Ml2tMl2)*Lambda(1);
                x_l2_itr(:,l1_itr_idx)=(AtA+lambda*(Ml2tMl2))\(Aty); %min. L-2 norm solution
                break;
                %D_l2=diag(1./sqrt(epss+abs(DFE*x_tv_itr(:,l1_itr_idx)))); %update the diagonal weighting matrix for TV regularization
            end;
       end;
       if(flag_display) fprintf('*'); end;
       
        if(flag_l1)
            coeff(:,ch_idx)=x_l1_itr(:,end);
        elseif(flag_tv)
            coeff(:,ch_idx)=x_tv_itr(:,end);
        else
            coeff(:,ch_idx)=x_l2_itr(:,end);            
        end;
    end
    if(flag_display) fprintf('\n'); end;
    
    Coeff(:,:,itr_idx)=coeff;
    
    %spirit reconstruction
    k_history(:,:,:,end+1)=k_acc_ref;
    for ch_idx=1:n_chan
        img_history(:,:,ch_idx,itr_idx+1)=fftshift(fft2(fftshift(k_history(:,:,ch_idx,end))));
    end;
    
    
    for ch_idx=1:n_chan
        recon_k=k_acc_ref(:,:,ch_idx);
        recon_k(recon_idx)=E(recon_idx,:)*squeeze(coeff(:,ch_idx));
        k_acc_ref(:,:,ch_idx)=reshape(recon_k,image_matrix);
    end
        
    if(flag_normalize_recon_power)
        %normalize power
        power_now=real(k_acc(:)'*k_acc(:));
        k_acc_ref=k_acc_ref./sqrt(power_now./power_orig);
    end;
    
    %finalize reconstruction
    for i=1:n_chan
        recon(:,:,i)=fftshift(fft2(fftshift(k_acc_ref(:,:,i))));
    end;
    recon_sos=sqrt(sum(abs(recon).^2,3));
    recon_sos_history(:,:,end+1)=recon_sos;
    recon_history(:,:,:,end+1)=recon;
    
end;

kernel.spirit_idx_matrix_tmp=spirit_idx_matrix_tmp;
kernel.spirit_idx_matrix_nan_idx=spirit_idx_matrix_nan_idx;
kernel.spirit_kernel_mask=spirit_kernel_mask;
kernel.image_matrix=image_matrix;
kernel.spirit_kernel_mask=spirit_kernel_mask;
kernel.n_chan=n_chan;
kernel.flag_normalize_recon_power=flag_normalize_recon_power;

return;

