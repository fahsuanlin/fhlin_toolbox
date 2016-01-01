
function [g, kernel] = pmri_spirit_prep(k_acc, varargin)
%
% [g, kernel] =pmri_spirit_prep(k_acc,....)
%
% k_acc: 3D complex valued k-space data [k_x,k_y, n_chan];
%
% g: estimated spirit reconstruction kernel over iterations
% kernel: a structure of parameters needed in estimation/application of
% spirit kernel
%
% fhlin@sep 11 2012
%


g=[];
kernel=[];

spirit_kernel_size=[1 1];
n_iteration=10;
n_l1_iteration=1;
Lambda=[1];
sample_matrix=[];
ref_sample_matrix=[];

flag_normalize_recon_power=1;

flag_display=1;

flag_l1=0;
flag_tv=1;

flag_prep_kernel=0; %only prepare kernel parameters without estimating the kernel

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
        case 'flag_prep_kernel'
            flag_prep_kernel=option_value;
        case 'ref_sample_matrix'
            ref_sample_matrix=option_value;
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

for ch_idx=1:size(k_acc,3)
    im_acc(:,:,ch_idx)=fftshift(fft2(fftshift(k_acc(:,:,ch_idx))));
end;
n_chan=size(k_acc,3);

%prepare kernel index matrix construction
spirit_kernel_mask=ones(spirit_kernel_size.*2+1);

image_matrix=[size(k_acc,1),size(k_acc,2)];
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


kernel.spirit_idx_matrix_tmp=spirit_idx_matrix_tmp;
kernel.spirit_idx_matrix_nan_idx=spirit_idx_matrix_nan_idx;
kernel.spirit_kernel_mask=spirit_kernel_mask;
kernel.image_matrix=image_matrix;
kernel.spirit_kernel_mask=spirit_kernel_mask;
kernel.n_chan=n_chan;
kernel.spirit_kernel_size=spirit_kernel_size;
kernel.spirit_idx_matrix=spirit_idx_matrix;

if(flag_prep_kernel)
    g=[];
    
    return;
end;

k_history(:,:,:,1)=k_acc;

recon_sos_history(:,:,1)=sqrt(sum(abs(im_acc).^2,3));

if(isempty(ref_sample_matrix))
    ref_sample_matrix=ones(image_matrix);
end;

ref_sample_idx=find(ref_sample_matrix(:)>eps);
sample_idx=find(sample_matrix(:)>eps);
ref_recon_idx=find(ref_sample_matrix(:)>eps);
recon_idx=find(sample_matrix(:)>eps);

power_orig=real(k_acc(:)'*k_acc(:));



%estimate spirit kernel from fully sampled reference data
fprintf('spirit kernel estimation....');
E=zeros(prod(image_matrix),(prod(size(spirit_kernel_mask))-1).*n_chan);
for ch_idx=1:n_chan
    kspace=k_acc(:,:,ch_idx);
    k_tmp=kspace(spirit_idx_matrix_tmp);
    k_tmp(spirit_idx_matrix_nan_idx)=0;
    E(:,(ch_idx-1)*(prod(size(spirit_kernel_mask))-1)+1:ch_idx*(prod(size(spirit_kernel_mask))-1))=k_tmp;
end;

if(size(E,2)<size(E,1)) %over-determined spirit kernel
    E_prep=inv(E(ref_sample_idx,:)'*E(ref_sample_idx,:))*E(ref_sample_idx,:)';
    for ch_idx=1:n_chan
        tmp=k_acc(:,:,ch_idx);
        g(:,ch_idx)=E_prep*tmp(:);
    end;
else %under-determined spirit kernel
    AAt=E(ref_sample_idx,:)*E(ref_sample_idx,:)';
    ll=trace(AAt)/size(AAt,1).*0.05;
    %E_prep=E(ref_sample_idx,:)'*inv(AAt+ll.*eye(size(AAt)));
    E_prep=E(ref_sample_idx,:)'*inv(AAt);
    
    for ch_idx=1:n_chan
        tmp=k_acc(:,:,ch_idx);
        g(:,ch_idx)=E_prep*tmp(:);
    end;
end;
fprintf('\n');


return;

