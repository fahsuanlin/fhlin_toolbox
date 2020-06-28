
function [k_acc] = pmri_spirit_kernel_apply(k_acc, coeff, kernel, varargin)
%
% [k_acc] =pmri_spirit_kernel_apply(k_acc, coeff, kernel....)
%
% k_acc: estimated noise-suppressed k-space data
% coeff: estimated spirit reconstruction kernel over iterations
% kernel: a structure of parameters needed in estimation/application of
% spirit kernel
%
% k_acc: 3D complex valued k-space data [k_x,k_y, n_chan];
%
% fhlin@sep 11 2012
%


flag_normalize_recon_power=1;

flag_display=1;


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]...\nerror!\n',option);
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data consistency recon...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

power_orig=real(k_acc(:)'*k_acc(:));

for repeat_idx=1:kernel.n_repeat
    
    if(flag_display) fprintf('*'); end;
    E=zeros(prod(kernel.image_matrix),(prod(size(kernel.spirit_kernel_mask))-1).*kernel.n_chan);
    for ch_idx=1:kernel.n_chan
        kspace=k_acc(:,:,ch_idx);
        k_tmp=kspace(kernel.spirit_idx_matrix_tmp);
        k_tmp(kernel.spirit_idx_matrix_nan_idx)=0;
        E(:,(ch_idx-1)*(prod(size(kernel.spirit_kernel_mask))-1)+1:ch_idx*(prod(size(kernel.spirit_kernel_mask))-1))=k_tmp;
    end;
    
    for ch_idx=1:kernel.n_chan
        recon_k=k_acc(:,:,ch_idx);
        recon_k(kernel.recon_idx)=E(kernel.recon_idx,:)*squeeze(coeff(:,ch_idx));
        k_acc(:,:,ch_idx)=reshape(recon_k,kernel.image_matrix);
    end
    
    if(kernel.flag_normalize_recon_power)
        power_now=real(k_acc(:)'*k_acc(:));
        k_acc=k_acc./sqrt(power_now./power_orig);
        
    end;
end;

if(flag_display) fprintf('\n'); end;
return;

