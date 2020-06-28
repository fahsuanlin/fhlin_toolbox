function [y, Eh]=pmri_patloc_cs_forward_h_func_default(x,pmri_cs_obj)
% pmri_patloc_cs_forward_h_func_default       default the adjoint of the forward solution of CS pMRI with PatLoc
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_patloc_cs_forward_h_func_default(x,pmri_cs_obj);
%
% x: n-dimensional input k-space across ch channels
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the adjoint forward solution of the CS pMRI (in image space)
%
% fhlin@sep 21 2009
%

y=[];
Eh=[];
flag_explicit_encoding=0;


% FT1
%implemeting IFT part by time-domin reconstruction (TDR)
%get the sampling time k-space coordinate.
if(pmri_cs_obj.patloc_obj.flag_vec4)
%     recon=zeros(pmri_cs_obj.patloc_obj.n_phase, pmri_cs_obj.patloc_obj.n_freq,  pmri_cs_obj.n_chan);
%     for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
%         for i=1:pmri_cs_obj.n_chan
%             X=repmat(x{g_idx}(:,:,i),[1 1 pmri_cs_obj.patloc_obj.n_phase pmri_cs_obj.patloc_obj.n_freq]);
%             X=permute(X,[3 4 1 2]);
%             recon(:,:,i)=recon(:,:,i)+sum(sum(X.*conj(pmri_cs_obj.patloc_obj.K_freq{g_idx}).*conj(pmri_cs_obj.patloc_obj.K_phase{g_idx}),4),3);
%         end;
%     end;
elseif(pmri_cs_obj.patloc_obj.flag_vec2)
    k_size=size(pmri_cs_obj.patloc_obj.K{1});
    recon=zeros(pmri_cs_obj.patloc_obj.n_phase, pmri_cs_obj.patloc_obj.n_freq,  pmri_cs_obj.n_chan);
    recon_buffer=zeros(pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan);

    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
        ff=0;
	if(pmri_cs_obj.patloc_obj.flag_cart)
	        X=reshape(x{g_idx}(:),[prod(pmri_cs_obj.image_size),pmri_cs_obj.n_chan])./sqrt(prod(pmri_cs_obj.image_size));
	        kspace=find(pmri_cs_obj.patloc_obj.K{g_idx}>eps);
	else
	        X=x{g_idx}./sqrt(prod(pmri_cs_obj.image_size));
	        kspace=pmri_cs_obj.patloc_obj.K{g_idx}.x(:);
	        kspace_x=pmri_cs_obj.patloc_obj.K{g_idx}.x(:);
	        kspace_y=pmri_cs_obj.patloc_obj.K{g_idx}.y(:);
	end;

        if(pmri_cs_obj.flag_pct)
	    if(pmri_cs_obj.patloc_obj.flag_cart)
		parfor k_idx=1:length(kspace)
		    [rr,cc]=ind2sub(k_size,kspace(k_idx));
		    cc1=cc-floor(pmri_cs_obj.patloc_obj.n_freq./2)-1;
		    rr1=rr-floor(pmri_cs_obj.patloc_obj.n_phase./2)-1;
		    phi=repmat(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1,[1,pmri_cs_obj.n_chan]);
		    if(pmri_cs_obj.patloc_obj.flag_cart)
			recon_buffer=recon_buffer+exp(sqrt(-1).*(-phi))*diag(X(kspace(k_idx),:));                
		    else
			recon_buffer=recon_buffer+exp(sqrt(-1).*(-phi))*diag(X(k_idx,:));                
		    end;
		end;
	    else
		parfor k_idx=1:length(kspace)
		    rr1=kspace_y(k_idx);
		    cc1=kspace_x(k_idx);
		    phi=repmat(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1,[1,pmri_cs_obj.n_chan]);
		    if(pmri_cs_obj.patloc_obj.flag_cart)
			recon_buffer=recon_buffer+exp(sqrt(-1).*(-phi))*diag(X(kspace(k_idx),:));                
		    else
			recon_buffer=recon_buffer+exp(sqrt(-1).*(-phi))*diag(X(k_idx,:));                
		    end;
		end;
            end;
        else
             for k_idx=1:length(kspace)
                if(pmri_cs_obj.patloc_obj.flag_cart)
		    [rr,cc]=ind2sub(k_size,kspace(k_idx));
		    cc1=cc-floor(pmri_cs_obj.patloc_obj.n_freq./2)-1;
		    rr1=rr-floor(pmri_cs_obj.patloc_obj.n_phase./2)-1;
		else
		    rr1=kspace_y(k_idx);
		    cc1=kspace_x(k_idx);
		end;
		phi=repmat(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1,[1,pmri_cs_obj.n_chan]);
                if(pmri_cs_obj.patloc_obj.flag_cart)
			recon_buffer=recon_buffer+exp(sqrt(-1).*(-phi))*diag(X(kspace(k_idx),:));                
		else
			recon_buffer=recon_buffer+exp(sqrt(-1).*(-phi))*diag(X(k_idx,:));                
		end;
            end;
        end;
        if(ff) fprintf('\n'); end;
    end;
    recon=reshape(recon_buffer,[pmri_cs_obj.patloc_obj.n_phase, pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan]);
end;
%recon=recon.*sqrt(prod(pmri_cs_obj.image_size));

for i=1:pmri_cs_obj.n_chan
    temp(:,:,i)=recon(:,:,i).*conj(pmri_cs_obj.sensitivity_profile{i});
end;

%intensity correction here
y=sum(temp,3).*pmri_cs_obj.I;
%y=sum(temp,3);


if(flag_explicit_encoding)
    k_size=size(pmri_cs_obj.patloc_obj.K{1});
    recon=zeros(pmri_cs_obj.patloc_obj.n_phase, pmri_cs_obj.patloc_obj.n_freq,  pmri_cs_obj.n_chan);
    recon_buffer=zeros(pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan);

    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
        kspace=find(pmri_cs_obj.patloc_obj.K{g_idx}>eps);

        E_kspace{g_idx}=zeros(pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq);
         for k_idx=1:length(kspace)
            [rr,cc]=ind2sub(k_size,kspace(k_idx));
            cc1=cc-floor(pmri_cs_obj.patloc_obj.n_freq./2)-1;
            rr1=rr-floor(pmri_cs_obj.patloc_obj.n_phase./2)-1;
            phi=(pmri_cs_obj.patloc_obj.K_freq{g_idx}(:).*cc1+pmri_cs_obj.patloc_obj.K_phase{g_idx}(:).*rr1);
            E_kspace{g_idx}(:,kspace(k_idx))=exp(sqrt(-1).*(-phi(:)));
        end;
    end;
    
    E_coil=[];
    for i=1:pmri_cs_obj.n_chan
        E_coil{i}=diag(pmri_cs_obj.I(:).*conj(pmri_cs_obj.sensitivity_profile{i}(:)));
    end;
    
    Eh=zeros(pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan*pmri_cs_obj.patloc_obj.n_phase*pmri_cs_obj.patloc_obj.n_freq);
    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)
        tmp=[];
        for ch_idx=1:pmri_cs_obj.n_chan
            tmp=cat(2,tmp,E_coil{ch_idx}*E_kspace{g_idx});
        end;
        Eh=Eh+tmp;
    end;
%     y1=Eh*x{1}(:);
%     subplot(211);plot(real(y1(:)),'b');
%     y0=y(:);
%     subplot(212);plot(real(y0(:)),'r');

end;

return;
