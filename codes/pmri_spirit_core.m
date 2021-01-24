
function [k_recon, b, l1_history] = pmri_spirit_core(k_acc, g, kernel, varargin)
%
% [k_recon] =pmri_spirit_prep(k_acc, g, kernel, ....)
%
% k_acc: 3D complex valued k-space data [k_x,k_y, n_chan];
%
% g: estimated spirit reconstruction kernel over iterations
% kernel: a structure of parameters needed in estimation/application of
% spirit kernel
%
% fhlin@sep 11 2012
%



difference_kernel_size=[1 1];
n_iteration=10;
n_l1_iteration=1;

sample_matrix=[];

flag_normalize_recon_power=1;

flag_display=1;

flag_l1=0;
flag_tv=1;
SNR=5;

lambda=1.0;
lambda_TV=0;



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
        case 'flag_display'
            flag_display=option_value;
        case 'flag_normalize_recon_power'
            flag_normalize_recon_power=option_value;
        case 'flag_tv'
            flag_tv=option_value;
        case 'flag_l1'
            flag_l1=option_value;
        case 'snr'
            SNR=option_value;
        case 'lambda'
            lambda=option_value;
        case 'lambda_tv'
            lambda_TV=option_value;
        case 'n_iteration'
            n_iteration=option_value;
        otherwise
            fprintf('unknown option [%s]...\nerror!\n',option);
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data consistency recon...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialization

image_matrix=kernel.image_matrix;
n_chan=kernel.n_chan;
spirit_idx_matrix=kernel.spirit_idx_matrix;



%preparing of 'g_t', the kernel for G'
g_t=g;
g_t=reshape(g_t,[prod(size(kernel.spirit_kernel_mask))-1 n_chan n_chan]);
g_t=permute(g_t,[1 3 2]);
g_t=flipdim(g_t,1);
g_t=reshape(g_t,[(prod(size(kernel.spirit_kernel_mask))-1)*n_chan n_chan]);
g_t=conj(g_t);

%preparing of 'E'
E=zeros(prod(image_matrix),(prod(size(kernel.spirit_kernel_mask))-1).*n_chan);
spirit_idx_matrix_tmp=kernel.spirit_idx_matrix;
spirit_idx_matrix_nan_idx=find(isnan(spirit_idx_matrix(:)));
spirit_idx_matrix_tmp(spirit_idx_matrix_nan_idx)=1;
for ch_idx=1:n_chan
    kspace=k_acc(:,:,ch_idx);
    k_tmp=kspace(spirit_idx_matrix_tmp);
    k_tmp(spirit_idx_matrix_nan_idx)=0;
    E(:,(ch_idx-1)*(prod(size(kernel.spirit_kernel_mask))-1)+1:ch_idx*(prod(size(kernel.spirit_kernel_mask))-1))=k_tmp;
end;



%prepare difference index matrix construction
difference_kernel_mask=ones(difference_kernel_size.*2+1);

image_matrix=[size(k_acc,1),size(k_acc,2)];
base_data_idx=zeros(image_matrix);
base_data_idx(1:end)=[1:prod(image_matrix)];
data_idx=zeros(image_matrix+2.*difference_kernel_size);

data_idx(1:difference_kernel_size(1),:)=nan;
data_idx(end-difference_kernel_size(1)+1:end,:)=nan;
data_idx(:,1:difference_kernel_size(2))=nan;
data_idx(:,end-difference_kernel_size(2)+1:end)=nan;
data_idx(difference_kernel_size(1)+1:difference_kernel_size(1)+image_matrix(1),difference_kernel_size(2)+1:difference_kernel_size(2)+image_matrix(2))=base_data_idx;

%construct difference index matrix
difference_idx_matrix=zeros(prod(image_matrix),prod(size(difference_kernel_mask)));
for idx=1:prod(image_matrix)
    [rr,cc]=ind2sub(size(data_idx),find(data_idx==idx));
    
    difference_idx_tmp=data_idx(rr-difference_kernel_size(1):rr+difference_kernel_size(1),cc-difference_kernel_size(2):cc+difference_kernel_size(2));
    difference_idx_matrix(idx,:)=difference_idx_tmp(:)';
end;

difference_idx_matrix_nan_idx=find(isnan(difference_idx_matrix(:)));
difference_idx_matrix_tmp=difference_idx_matrix;
difference_idx_matrix_tmp(difference_idx_matrix_nan_idx)=1;

D=zeros(prod(image_matrix),(prod(size(difference_kernel_mask))));
difference_idx_matrix_tmp=difference_idx_matrix;
difference_idx_matrix_nan_idx=find(isnan(difference_idx_matrix(:)));
difference_idx_matrix_tmp(difference_idx_matrix_nan_idx)=1;

diag_TV=ones(size(k_acc(:)));
l1_history=[];
if(isempty(sample_matrix))
    S=ones(size(k_acc,1)*size(k_acc,2),1);
else
    S=zeros(prod(size(sample_matrix)),1);
    S(find(sample_matrix(:)))=1;
end;
S=repmat(S,[n_chan,1]);

for l1_idx=1:n_l1_iteration
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % a=E'*y;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % a=E'*k_acc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for ch_idx=1:n_chan
    %     a(:,ch_idx)=E*g_t(:,ch_idx);
    % end;
    a=S.*k_acc(:);
    
    
    
    b(:,1)=zeros(prod(size(k_acc)),1);
    p(:,1)=a;
    r(:,1)=a;
    
    
    for iteration_idx=2:n_iteration
        fprintf('#')
        if(iteration_idx==2)
            p(:,iteration_idx)=r(:,1);
        else
            ww=sum(sum(abs(r(:,iteration_idx-1)).^2))/sum(sum(abs(r(:,iteration_idx-2)).^2));
            p(:,iteration_idx)=r(:,iteration_idx-1)+ww.*p(:,iteration_idx-1);
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % tmp1=I*I'*p(:,iteration_idx)=p(:,iteration_idx);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        tmp1=S.*S.*p(:,iteration_idx);

      
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % tmp2=lambda*(G-I)'*(G-I)*p(:,iteration_idx);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        p_tmp=p(:,iteration_idx);
        p_tmp=reshape(p_tmp,[size(k_acc,1)*size(k_acc,2) n_chan]);
        for ch_idx=1:n_chan
            kspace=p_tmp(:,ch_idx);
            k_tmp=kspace(spirit_idx_matrix_tmp);
            k_tmp(spirit_idx_matrix_nan_idx)=0;
            E(:,(ch_idx-1)*(prod(size(kernel.spirit_kernel_mask))-1)+1:ch_idx*(prod(size(kernel.spirit_kernel_mask))-1))=k_tmp;
        end;
        tmp=[];
        for ch_idx=1:n_chan
            tmp(:,ch_idx)=E*g(:,ch_idx);
        end;
        %(G-I)x
        tmp=tmp-p_tmp;
        
        
        tmp0=tmp;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %tmp=(G-I)'*tmp;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %G'x
        for ch_idx=1:n_chan
            kspace=tmp(:,ch_idx);
            k_tmp=kspace(spirit_idx_matrix_tmp);
            k_tmp(spirit_idx_matrix_nan_idx)=0;
            E(:,(ch_idx-1)*(prod(size(kernel.spirit_kernel_mask))-1)+1:ch_idx*(prod(size(kernel.spirit_kernel_mask))-1))=k_tmp;
        end;
        for ch_idx=1:n_chan
            tmp(:,ch_idx)=E*g_t(:,ch_idx);
        end;
        tmp=tmp(:);
        %(G-I)'x
        tmp=tmp-tmp0(:);
        
        %lambda*(G-I)'*(G-I)x
        tmp2=lambda.*tmp;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % tmp3=lambda_TV*(Diag_TV*DE)'*(Diag_TV*DE)*p(:,iteration_idx);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        p_tmp=p(:,iteration_idx);
        p_tmp=reshape(p_tmp,[size(k_acc,1), size(k_acc,2) n_chan]);
        % Fourier encoding
        for ch_idx=1:n_chan
            p_tmp(:,:,ch_idx)=fftshift(fft2(fftshift(p_tmp(:,:,ch_idx))));
        end;
        % finite difference
        tmp=[];
        for ch_idx=1:n_chan
            kspace=p_tmp(:,:,ch_idx);
            %kspace=kspace(:);
            k_tmp=kspace(difference_idx_matrix_tmp);
            k_tmp(difference_idx_matrix_nan_idx)=0;
            D(:,1:prod(size(difference_kernel_mask)))=k_tmp;
            
            D_idx=sum((abs(D)>eps),2);
            
            dd=difference_kernel_mask.*(-1);
            dd((length(difference_kernel_mask(:))+1)/2)=prod(size(difference_kernel_mask))-1;
            
            D(:,(prod(size(difference_kernel_mask))+1)/2)=D(:,(prod(size(difference_kernel_mask))+1)/2)./(prod(size(difference_kernel_mask))-1).*D_idx;
            
            tmp(:,ch_idx)=D*dd(:);
        end;
        
        % diag_TV
        tmp=tmp(:).*diag_TV(:);
        
        %hermittian of diag_TV
        tmp=tmp(:).*conj(diag_TV(:));
        
        tmp=reshape(tmp,[size(k_acc,1)*size(k_acc,2) n_chan]);
        
        %hermittian of finite difference
        for ch_idx=1:n_chan
            kspace=tmp(:,ch_idx);
            k_tmp=kspace(difference_idx_matrix_tmp);
            k_tmp(difference_idx_matrix_nan_idx)=0;
            D(:,1:prod(size(difference_kernel_mask)))=k_tmp;
            
            D_idx=sum((abs(D)>eps),2);
            
            dd=difference_kernel_mask.*(-1);
            dd((length(difference_kernel_mask(:))+1)/2)=prod(size(difference_kernel_mask))-1;
            
            D(:,(prod(size(difference_kernel_mask))+1)/2)=D(:,(prod(size(difference_kernel_mask))+1)/2)./(prod(size(difference_kernel_mask))-1).*D_idx;
            
            tmp(:,ch_idx)=D*dd(:);
        end;
        % hermittian of Fourier encoding
        for ch_idx=1:n_chan
            p_tmp(:,:,ch_idx)=reshape(tmp(:,ch_idx),[size(k_acc,1), size(k_acc,2)]);
            p_tmp(:,:,ch_idx)=fftshift(fft2(fftshift(p_tmp(:,:,ch_idx))));
        end;
        tmp3=lambda_TV.*p_tmp(:);
        
        
        tmp=tmp1+tmp2+tmp3;
   
        
        %%% CG starts
        q=tmp;
        w=sum(sum(abs(r(:,iteration_idx-1)).^2))/sum(sum(conj(p(:,iteration_idx)).*q));
        b(:,iteration_idx)=b(:,iteration_idx-1)+p(:,iteration_idx).*w;
        r(:,iteration_idx)=r(:,iteration_idx-1)-q.*w;
        %%% CG ends
   
        
    end;
    fprintf('\n');
    
    
    k_recon=reshape(b(:,end),size(k_acc));
    k_acc=k_recon;
    
    %update
    % Fourier encoding
    p_tmp=reshape(k_acc,[size(k_acc,1) size(k_acc,2) n_chan]);
    for ch_idx=1:n_chan
        p_tmp(:,:,ch_idx)=fftshift(fft2(fftshift(p_tmp(:,:,ch_idx))));
    end;
    % finite difference
    tmp=[];
    for ch_idx=1:n_chan
        kspace=p_tmp(:,:,ch_idx);
        %kspace=kspace(:);
        k_tmp=kspace(difference_idx_matrix_tmp);
        k_tmp(difference_idx_matrix_nan_idx)=0;
        D(:,1:prod(size(difference_kernel_mask)))=k_tmp;
        
        D_idx=sum((abs(D)>eps),2);
        
        dd=difference_kernel_mask.*(-1);
        dd((length(difference_kernel_mask(:))+1)/2)=prod(size(difference_kernel_mask))-1;
        
        D(:,(prod(size(difference_kernel_mask))+1)/2)=D(:,(prod(size(difference_kernel_mask))+1)/2)./(prod(size(difference_kernel_mask))-1).*D_idx;
        
        tmp(:,ch_idx)=D*dd(:);
    end;
    
    diag_TV0=diag_TV;
    diag_TV=1./sqrt(eps+abs(tmp(:)).^2);
    diag_TV=diag_TV./max(diag_TV);
    

    l1_history=cat(2,l1_history,b(:,end));
    
end;

return;



