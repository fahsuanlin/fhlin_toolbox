function y=pmri_traj_cs_forward_h_func_default(x,pmri_cs_obj)
% pmri_traj_cs_forward_h_func_default       default the adjoint of the
% forward solution of CS pMRI with a specified trajectory given input 
% image x and CS pMRI object pmri_cs_obj
%
% y=pmri_traj_cs_forward_h_func_default(x,pmri_cs_obj);
%
% x: n-dimensional input k-space across ch channels
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the adjoint forward solution of the CS pMRI (in image space)
%
% fhlin@dec 31 2009
%

y=[];

% FT1
%implemeting IFT part by time-domin reconstruction (TDR)
%get the sampling time k-space coordinate.
if(pmri_cs_obj.patloc_obj.flag_vec4)
    %to be done....
elseif(pmri_cs_obj.patloc_obj.flag_vec2)
    k_size=pmri_cs_obj.traj_obj.k_size;
    recon=zeros(pmri_cs_obj.traj_obj.n_phase, pmri_cs_obj.traj_obj.n_freq,  pmri_cs_obj.n_chan);

    recon_buffer=zeros(pmri_cs_obj.traj_obj.n_phase*pmri_cs_obj.traj_obj.n_freq,pmri_cs_obj.n_chan);

    [cc,rr]=meshgrid([1:pmri_cs_obj.traj_obj.n_freq],[1:pmri_cs_obj.traj_obj.n_phase]);
    cc1=cc-floor(pmri_cs_obj.traj_obj.n_freq./2)-1;
    rr1=rr-floor(pmri_cs_obj.traj_obj.n_phase./2)-1;

    for g_idx=1:length(pmri_cs_obj.patloc_obj.G)

        kspace=[1:prod(k_size)];

        n_pixel=pmri_cs_obj.traj_obj.n_freq*pmri_cs_obj.traj_obj.n_phase;
        offset=[0:n_pixel:(pmri_cs_obj.n_chan-1)*n_pixel];
        X=reshape(x{g_idx}(:),[n_pixel,pmri_cs_obj.n_chan]);
        ff=0;

        if(pmri_cs_obj.flag_pct)
            parfor k_idx=1:prod(k_size)
                %if(mod(k_idx,100)==0) fprintf('*'); ff=1; end;
                phi=repmat(pmri_cs_obj.patloc_obj.K_freq{g_idx}(k_idx).*(cc1(:))+pmri_cs_obj.patloc_obj.K_phase{g_idx}(k_idx).*(rr1(:)),[1,pmri_cs_obj.n_chan]);
                recon_buffer(k_idx,:)=recon_buffer(k_idx,:)+sum(exp(sqrt(-1).*(-phi)).*X,1);
            end;
        else
            for k_idx=1:prod(k_size)
                %if(mod(k_idx,100)==0) fprintf('*'); ff=1; end;
                phi=repmat(pmri_cs_obj.patloc_obj.K_freq{g_idx}(k_idx).*(cc1(:))+pmri_cs_obj.patloc_obj.K_phase{g_idx}(k_idx).*(rr1(:)),[1,pmri_cs_obj.n_chan]);
                recon_buffer(k_idx,:)=recon_buffer(k_idx,:)+sum(exp(sqrt(-1).*(-phi)).*X,1);
            end;
        end;
        if(ff) fprintf('\n'); end;
    end;

    recon=reshape(recon_buffer,[pmri_cs_obj.patloc_obj.n_phase, pmri_cs_obj.patloc_obj.n_freq,pmri_cs_obj.n_chan]);
end;


for i=1:pmri_cs_obj.n_chan
    temp(:,:,i)=recon(:,:,i).*conj(pmri_cs_obj.sensitivity_profile{i});
end;

%intensity correction here
%y=sum(temp,3).*pmri_cs_obj.I;
y=sum(temp,3);

return;
