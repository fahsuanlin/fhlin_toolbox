function [y,E]=pmri_patloc_cs_forward_func_defaul(x,pmri_cs_obj)
% pmri_patloc_cs_forward_func_defaul       default forward solution of CS pMRI with PatLoc
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_patloc_cs_forward_func_defaul(x,pmri_cs_obj);
%
% x: n-dimensional input image
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the forward solution of the CS pMRI, including channle-wise 1) spatial
% modulation of coil sensitivity profile, 2) transform from image domain to
% k-space domain, and 3) k-space sub-sampling;
%
% fhlin@sep 21 2009
%

E=[];
y=[];

flag_explicit_encoding=0;


x=x.*pmri_cs_obj.I;

for i=1:pmri_cs_obj.n_chan
    temp(:,:,i)=x.*pmri_cs_obj.sensitivity_profile{i};
end;

if(pmri_cs_obj.patloc_obj.flag_vec4)
%     Temp=[];
%     for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
%         Temp{g_idx}=zeros(pmri_cs_obj.patloc_obj.n_phase,pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan);
%         for i=1:pmri_cs_obj.n_chan
%             X=repmat(temp(:,:,i),[1 1 pmri_cs_obj.patloc_obj.n_phase pmri_cs_obj.patloc_obj.n_freq]);
%             Temp{g_idx}(:,:,i)=squeeze(sum(sum(X.*pmri_cs_obj.patloc_obj.K_freq{g_idx}.*pmri_cs_obj.patloc_obj.K_phase{g_idx},1),2));
%         end;
%     end;
% 
%     y=Temp;
% 
%     for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
%         k_idx=find(pmri_cs_obj.patloc_obj.K{g_idx}<eps);
%         for i=1:pmri_cs_obj.n_chan
%             %K-space acceleration
%             buffer0=y{g_idx}(:,:,i);
%             buffer0(k_idx)=0;
%             y{g_idx}(:,:,i)=buffer0;
%         end;
%     end;
elseif(pmri_cs_obj.patloc_obj.flag_vec2)
    k_size=size(pmri_cs_obj.patloc_obj.K{1});

    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
        kspace=find(pmri_cs_obj.patloc_obj.K{g_idx}>eps);
        y{g_idx}=zeros(pmri_cs_obj.patloc_obj.n_phase,pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan);
        for i=1:pmri_cs_obj.n_chan
            X=temp(:,:,i);
            X=transpose(X(:));
            tmp=zeros(pmri_cs_obj.patloc_obj.n_phase,pmri_cs_obj.patloc_obj.n_freq);
            buffer=zeros(1,length(kspace));
            if(pmri_cs_obj.flag_pct)
                parfor k_idx=1:length(kspace)
                    [rr,cc]=ind2sub(k_size,kspace(k_idx));
                    cc1=cc-floor(pmri_cs_obj.patloc_obj.n_freq./2)-1;
                    rr1=rr-floor(pmri_cs_obj.patloc_obj.n_phase./2)-1;
                    kk=X*(exp(sqrt(-1).*(+1).*(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1)));
                    buffer(k_idx)=kk;
                end;
            elseif(pmri_cs_obj.flag_gpu)
		kspace_gpu=gdouble(kspace);
		n_freq_gpu=gsingle(pmri_cs_obj.patloc_obj.n_freq);
		n_phase_gpu=gsingle(pmri_cs_obj.patloc_obj.n_phase);
		K_freq_gpu=gdouble(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:));
		K_phase_gpu=gdouble(pmri_cs_obj.patloc_obj.K_phase{g_idx}(:));
	        X_gpu=gdouble(X);
		buffer_gpu=gdouble(gzeros(1,length(kspace)));

		%for k_idx=gsingle(1:length(kspace))
		%    [rr,cc]=ind2sub(gsingle(k_size),gsingle(kspace(k_idx)));
		%    cc1=cc-floor(n_freq_gpu./2)-1;
		%    rr1=rr-floor(n_phase_gpu./2)-1;
		%    kk=X_gpu*(exp(sqrt(-1).*(K_freq_gpu.*cc1+K_phase_gpu.*rr1)));
		%    buffer_gpu(k_idx)=kk;
		%end;
		gfor k_idx=(1:length(kspace))
		    dd=kspace_gpu(k_idx);
		    [rr,cc]=ind2sub(k_size,dd);
		    cc1=cc-floor(n_freq_gpu./2)-1;
		    rr1=rr-floor(n_phase_gpu./2)-1;
		    kk=X_gpu*(exp(sqrt(-1).*(K_freq_gpu.*cc1+K_phase_gpu.*rr1)));
		    buffer_gpu(k_idx)=kk;
		gend;

		buffer=gforce(double(buffer_gpu));
	    else
                for k_idx=1:length(kspace)
                    [rr,cc]=ind2sub(k_size,kspace(k_idx));
                    cc1=cc-floor(pmri_cs_obj.patloc_obj.n_freq./2)-1;
                    rr1=rr-floor(pmri_cs_obj.patloc_obj.n_phase./2)-1;
                    kk=X*(exp(sqrt(-1).*(+1).*(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1)));
                    buffer(k_idx)=kk;
                end;
            end;
            tmp(kspace)=buffer;
            tmp=tmp./sqrt(prod(size(tmp)));

            y{g_idx}(:,:,i)=tmp;
        end;
    end;

end;
if(~iscell(y))
    y{1}=y;
end;

%explicit encoding; coil sensitivity
if(flag_explicit_encoding);
    E_coil=[];
    for i=1:pmri_cs_obj.n_chan
        E_coil{i}=diag(pmri_cs_obj.sensitivity_profile{i}(:).*pmri_cs_obj.I(:));
    end;
    
    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
        kspace=find(pmri_cs_obj.patloc_obj.K{g_idx}>eps);
        E_kspace{g_idx}=zeros(pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq);
        for k_idx=1:length(kspace)
            [rr,cc]=ind2sub(k_size,kspace(k_idx));
            cc1=cc-floor(pmri_cs_obj.patloc_obj.n_freq./2)-1;
            rr1=rr-floor(pmri_cs_obj.patloc_obj.n_phase./2)-1;
            kk=(exp(sqrt(-1).*(+1).*(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1)));
            E_kspace{g_idx}(kspace(k_idx),:)=transpose(kk);
        end;
    end;

    E=[];
    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
        for ch_idx=1:pmri_cs_obj.n_chan
            E=cat(1,E,E_kspace{g_idx}*E_coil{ch_idx});
        end;
    end;
    E=E./sqrt(prod(pmri_cs_obj.image_size));
end;

%  y1=E*x(:);
%  subplot(211);plot(real(y1(:)),'b');
%  y0=y{1}(:);
%  subplot(212);plot(real(y0(:)),'r');

return;
