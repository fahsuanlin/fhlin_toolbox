function output=pmri_spirit_forward(g,x,kernel,varargin)



p_tmp=x;
%p_tmp=reshape(p_tmp,[size(k_acc,1)*size(k_acc,2) n_chan]);
n_chan=size(p_tmp,2);

for ch_idx=1:n_chan
    kspace=p_tmp(:,ch_idx);
    k_tmp=kspace(kernel.spirit_idx_matrix_tmp);
    k_tmp(kernel.spirit_idx_matrix_nan_idx)=0;
    E(:,(ch_idx-1)*(prod(size(kernel.spirit_kernel_mask))-1)+1:ch_idx*(prod(size(kernel.spirit_kernel_mask))-1))=k_tmp;
end;
tmp=[];
for ch_idx=1:n_chan
    tmp(:,ch_idx)=E*g(:,ch_idx);
end;

output=reshape(tmp(:),size(x));