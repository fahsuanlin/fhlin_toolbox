function y=pmri_patloc_cs_forward_h_forward_func_defaul(x,pmri_cs_obj)
% pmri_patloc_cs_forward_h_forward_func_defaul       default forward'forward solution of CS pMRI with PatLoc
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_patloc_cs_forward_h_forward_func_defaul(x,pmri_cs_obj);
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

y=[];


for i=1:pmri_cs_obj.n_chan
    temp(:,:,i)=x.*pmri_cs_obj.sensitivity_profile{i};
end;


Temp=[];
for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
    Temp{g_idx}=zeros(pmri_cs_obj.patloc_obj.n_phase,pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan);
    for i=1:pmri_cs_obj.n_chan
        X=repmat(temp(:,:,i),[1 1 pmri_cs_obj.patloc_obj.n_phase pmri_cs_obj.patloc_obj.n_freq]);
        Temp{g_idx}(:,:,i)=squeeze(sum(sum(X.*pmri_cs_obj.patloc_obj.K_freq{g_idx}.*pmri_cs_obj.patloc_obj.K_phase{g_idx},1),2));
    end;
end;

y=Temp;

for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
    k_idx=find(pmri_cs_obj.patloc_obj.K{g_idx}<eps);
    for i=1:pmri_cs_obj.n_chan
        %K-space acceleration
        buffer0=y{g_idx}(:,:,i);
        buffer0(k_idx)=0;
        y{g_idx}(:,:,i)=buffer0;
    end;
end;



%FT1
%implemeting IFT part by time-domin reconstruction (TDR)
%get the sampling time k-space coordinate.
recon=zeros(pmri_cs_obj.patloc_obj.n_phase, pmri_cs_obj.patloc_obj.n_freq,  pmri_cs_obj.n_chan);
for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
    for i=1:pmri_cs_obj.n_chan
        X=repmat(y{g_idx}(:,:,i),[1 1 pmri_cs_obj.patloc_obj.n_phase pmri_cs_obj.patloc_obj.n_freq]);
        X=permute(X,[3 4 1 2]);
        recon(:,:,i)=recon(:,:,i)+sum(sum(X.*conj(pmri_cs_obj.patloc_obj.K_freq{g_idx}).*conj(pmri_cs_obj.patloc_obj.K_phase{g_idx}),4),3);
    end;
end;

for i=1:pmri_cs_obj.n_chan
    temp(:,:,i)=recon(:,:,i).*conj(pmri_cs_obj.sensitivity_profile{i});
end;

%intensity correction here
%y=sum(temp,3).*pmri_cs_obj.I;
y=sum(temp,3);


return;
