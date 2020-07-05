function [recon,b,delta,g2_gfactor,Local_kspace,l1_history]=itdr5_core_ktraj_cg(varargin);
%
%	itdr5_core_ktraj_cg		perform generalized PatLoc reconstruction using
%	time-domain signals and the conjugated gradient method in Cartesian
%	sampling trajectory
%
%
%	[recon,b,delta]=itdr4_core_ktraj_cg('Y',Y,'S',S,'G',G,'K',K,'flag_display',1);
%
%	INPUT:
%	Y: input data of {n_G}[n_PE, n_FE, n_chan].
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%   G_general: spatial encoding magnetic fields for "frequency" and "phase" encoding [n_PE, n_FE, n_G]
%       *must be paired with K_general
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	dF_general: off-resonance map (Hz) [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	dFt_general: time stamps for k-space trajectory to simulate off-resonance (s) [n_encode, 1].
%       *must be paired with K_general
%		n_encode: # of k-space data
%   K_general: n-D k-space coordinates [n_encode, n_G]
%       *must be paired with G_general
%		n_G: # of spatial encoding magnetic fields
%		n_encode: # of k-space data
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	recon: 2D un-regularized SENSE reconstruction [n_PE, n_PE].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%	b: history of all 2D un-regularized SENSE reconstruction [n_PE, n_PE, n_CG].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%		n_CG: # of CG iteration
%	delta: history of all errors in CG iteration [n_CG, 1]
%		n_CG: # of CG iteration
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin,
%   Athinoula A. Martinos Center, Mass General Hospital
%   Institute of Biomedical Engineering, National Taiwan University
%
%	fhlin@nmr.mgh.harvard.edu
%   fhlin@ntu.edu.tw
%
%	fhlin@Dec. 18, 2008
%   fhlin@Oct. 2, 2010
%   fhlin@Aug. 24,2013

S=[];
Y=[];
K_general=[];
G_general=[];
gfactor=[];
X0=[];

%off-resonance
dF_general=[];
dFt_general=[];


lambda=0;
lambda_TV=0;

n_freq=[];
n_phase=[];

flag_cg_gfactor=0;

flag_display=0;
flag_debug=0;

flag_local_k=0;
local_k_size=7;
Local_kspace=[];

iteration_max=[];
epsilon=[];

recon=[];
b=[];
delta=[];
g2_gfactor=[];

n_calc=32;

difference_kernel_size=[1 1];
n_l1_iteration=1;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'df_general'
            dF_general=option_value;
        case 'dft_general'
            dFt_general=option_value;
        case 'y'
            Y=option_value;
        case 'k'
            K=option_value;
        case 'k_general'
            K_general=option_value;
        case 'g_general'
            G_general=option_value;
        case 'lambda'
            lambda=option_value;
        case 'lambda_tv'
            lambda_TV=option_value;
        case 'x0'
            X0=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
        case 'n_calc'
            n_calc=option_value;
        case 'flag_local_k'
            flag_local_k=option_value; %local k-space;
        case 'local_k_size'
            local_k_size=option_value; %local k-space;
        case 'flag_cg_gfactor'
            flag_cg_gfactor=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'iteration_max'
            iteration_max=option_value;
        case 'epsilon'
            epsilon=option_value;
        case 'flag_debug'
            flag_debug=option_value;
        case 'n_l1_iteration'
            n_l1_iteration=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%default prior
if(isempty(X0)) X0=zeros(n_phase,n_freq); end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%local k-space setup
if(flag_local_k)
    dist_freq=floor(n_freq/local_k_size);
    dist_phase=floor(n_phase/local_k_size);
    K_local_x=([1:local_k_size]-(local_k_size+1)/2)*dist_freq+(n_freq)/2+1;
    K_local_y=([1:local_k_size]-(local_k_size+1)/2)*dist_phase+(n_phase)/2+1;
    [K_local_xx,K_local_yy]=meshgrid(K_local_x,K_local_y);
    K_local_idx=sub2ind([n_phase,n_freq],K_local_yy(:),K_local_xx(:));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare gradient information

if(isempty(n_freq))
    n_freq=size(Y{1},2);
end;
if(isempty(n_phase))
    n_phase=size(Y{1},1);
end;

%setup 2D gradient
if(isempty(G_general))
    [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase/2) :1:ceil(n_phase/2)-1]);
    G{1}.freq=grid_freq;
    G{1}.phase=grid_phase;
else
    for g_idx=1:size(G_general,3)
        G_tmp(:,g_idx)=reshape(G_general(:,:,g_idx),[n_phase*n_freq,1]);
    end;
end;
n_chan=size(S,3);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TV regularization preparation
%prepare difference index matrix construction
difference_kernel_mask=ones(difference_kernel_size.*2+1);

image_matrix=[n_phase, n_freq];
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

% difference_idx_matrix_nan_idx=find(isnan(difference_idx_matrix(:)));
% difference_idx_matrix_tmp=difference_idx_matrix;
% difference_idx_matrix_tmp(difference_idx_matrix_nan_idx)=1;

D=zeros(prod(image_matrix),(prod(size(difference_kernel_mask))));
difference_idx_matrix_tmp=difference_idx_matrix;
difference_idx_matrix_nan_idx=find(isnan(difference_idx_matrix(:)));
difference_idx_matrix_tmp(difference_idx_matrix_nan_idx)=1;

diag_TV=ones(n_phase, n_freq);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  vvvvvvvvvvvvvvv  begin reconstruction now  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intensity correction

I=zeros(size(S,1),size(S,2));
for i=1:size(S,3)
    I=I+abs(S(:,:,i)).^2;
end;

%I=I+lambda.*lambda.*ones(size(I));
I=1./sqrt(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initial value
if(~isempty(X0))
    temp=[];
    temp_gfactor=[];
    for i=1:size(S,3)
        % S (sensitivity)
        tmp=X0.*S(:,:,i);
        temp(:,i)=tmp(:);
    end;
    
    Temp=[];
    
    k_prep=sqrt(-1).*(-1).*2.*pi.*G_tmp./2;
    k_idx=[1:size(K_general,1)];
    for calc_idx=1:ceil(size(K_general,1)/n_calc)
        if(calc_idx~=ceil(length(k_idx)/n_calc))
            k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
        else
            k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
        end;
        k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));
        
        Temp(k_idx_now,:)=transpose(k_encode)*temp;
    end;
    Y=Y-Temp;
    temp=[];
end;


if(~flag_cg_gfactor)
    % FT1
    %implemeting IFT part by time-domin reconstruction (TDR)
    %get the sampling time k-space coordinate.
    recon2=zeros(n_phase*n_freq,n_chan);
    
    k_prep=sqrt(-1).*(1).*2.*pi.*G_tmp./2;
    k_idx=[1:size(K_general,1)];
    for calc_idx=1:ceil(size(K_general,1)/n_calc)
        if(calc_idx~=ceil(length(k_idx)/n_calc))
            k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
        else
            k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
        end;
        k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));
        recon2=recon2+(k_encode)*Y(k_idx_now,:);
    end;
    
    recon2=reshape(recon2,[n_phase, n_freq, n_chan]);
    if(flag_display) fprintf('\n'); end;
    
    for i=1:n_chan
        % S' (complex-conjugated sensitivity)
        temp(:,:,i)=recon2(:,:,i).*conj(S(:,:,i));
    end;
    %intensity correction here
    a=sum(temp,3).*I;
    
    %add regularization term.
    %a=a+lambda.*lambda.*X0.*I;
else
    a=Y{1}(:,:,1).*I;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for l1_idx=1:n_l1_iteration
    
    convergence=0;
    iteration_idx=2;
    clear b p r;
    
    b(:,:,1)=zeros(n_phase,n_freq);
    p(:,:,1)=a;
    r(:,:,1)=a;
    
    if(isempty(epsilon))
        epsilon=0;
        for g_idx=1:length(Y)
            epsilon=epsilon+sum(abs(Y{g_idx}(:)).^2)./50./n_chan;
        end;
        if(flag_display)
            fprintf('automatic setting error check in CG to [%2.2e]\n',epsilon);
        end;
    end;
    
    if(isempty(iteration_max))
        iteration_max=round(size(K,1)/3);
        if(flag_display)
            fprintf('automatic setting maximum CG iteration to [%d]\n',iteration_max);
        end;
    end;
    
    
    while(~convergence)
        if(flag_display)
            fprintf('PMRI recon. CG iteration=[%d]...',iteration_idx);
        end;
        
        dd=abs(r(:,:,iteration_idx-1)).^2;
        delta(iteration_idx)=sum(dd(:));
        
        
        if(sum(dd(:))<epsilon)
            convergence=1;
            delta(end)=[];
        else
            if(iteration_idx==2)
                p(:,:,iteration_idx)=r(:,:,1);
            else
                ww=sum(sum(abs(r(:,:,iteration_idx-1)).^2))/sum(sum(abs(r(:,:,iteration_idx-2)).^2));
                p(:,:,iteration_idx)=r(:,:,iteration_idx-1)+ww.*p(:,:,iteration_idx-1);
            end;
            
            %intensity correction here
            ss=p(:,:,iteration_idx).*I;
            
            ss0=p(:,:,iteration_idx).*I;
            
            
            if(flag_cg_gfactor&iteration_idx==2)
                ss_gfactor=Y{1}(:,:,1);
            else
                ss_gfactor=[];
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%         E          %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            temp=[];
            temp_gfactor=[];
            for i=1:size(S,3)
                % S (sensitivity)
                tmp=ss.*S(:,:,i);
                temp(:,i)=tmp(:);
                
                if(~isempty(ss_gfactor))
                    tmp_gfactor=ss_gfactor.*S(:,:,i);
                    temp_gfactor(:,i)=tmp_gfactor(:);
                end;
            end;
            
            Temp=[];
            Temp_gfactor=[];
            
            k_prep=sqrt(-1).*(-1).*2.*pi.*G_tmp./2;
            k_idx=[1:size(K_general,1)];
            for calc_idx=1:ceil(size(K_general,1)/n_calc)
                if(calc_idx~=ceil(length(k_idx)/n_calc))
                    k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
                else
                    k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
                end;
                
                k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));
                if((flag_local_k)&(iteration_idx==2))
                    phi=imag(k_prep*transpose(K_general(k_idx_now,:)));
                    phi=reshape(phi,[n_phase,n_freq,length(k_idx_now)]);
                    for ii=1:length(k_idx_now)
                        [dx,dy]=gradient(phi(:,:,ii));
                        Kx_local(k_idx_now(ii),:)=dx(K_local_idx)';
                        Ky_local(k_idx_now(ii),:)=dy(K_local_idx)';
                    end;
                end;
                
                Temp(k_idx_now,:)=transpose(k_encode)*temp;
                if(~isempty(ss_gfactor))
                    Temp_gfactor(k_idx_now,:)=transpose(k_encode)*temp_gfactor;
                end;
            end;
            
            %local k-space
            if((flag_local_k)&(iteration_idx==2))
                Local_kspace.kx=Kx_local;
                Local_kspace.ky=Ky_local;
                Local_kspace.pos_x=K_local_xx;
                Local_kspace.pos_y=K_local_yy;
            end;
            
            buffer=Temp;
            
            if(~isempty(ss_gfactor))
                buffer_gfactor=Temp_gfactor;
            end;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%         E'          %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % FT1
            %implemeting IFT part by time-domin reconstruction (TDR)
            %get the sampling time k-space coordinate.
            recon2=zeros(n_phase*n_freq,n_chan);
            recon2_gfactor=zeros(n_phase*n_freq,n_chan);
            
            k_prep=sqrt(-1).*(1).*2.*pi.*G_tmp./2;
            k_idx=[1:size(K_general,1)];
            for calc_idx=1:ceil(size(K_general,1)/n_calc)
                if(calc_idx~=ceil(length(k_idx)/n_calc))
                    k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
                else
                    k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
                end;
                
                k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));
                recon2=recon2+(k_encode)*buffer(k_idx_now,:);
                
                if(~isempty(ss_gfactor))
                    recon2_gfactor=recon2_gfactor+(k_encode)*buffer_gfactor(k_idx_now,:);
                end;
            end;
            
            recon2=reshape(recon2,[n_phase, n_freq, n_chan]);
            if(~isempty(ss_gfactor))
                recon2_gfactor=reshape(recon2_gfactor,[n_phase, n_freq, n_chan]);
            end;
            
            temp=[];
            % S' (complex-conjugated sensitivity)
            for i=1:n_chan
                temp(:,:,i)=recon2(:,:,i).*conj(S(:,:,i));
            end;
            
            temp_gfactor=[];
            if(~isempty(ss_gfactor))
                for i=1:n_chan
                    temp_gfactor(:,:,i)=recon2_gfactor(:,:,i).*conj(S(:,:,i));
                end;
            end;
            
            %intensity correction here
            xx=sum(temp,3).*I;
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % tmp3=lambda_TV*(Diag_TV*DE)'*(Diag_TV*DE)*p(:,:,iteration_idx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            p_tmp=p(:,:,iteration_idx);
            % Fourier encoding
            %p_tmp=fftshift(fft2(fftshift(p_tmp)));
            % finite difference
            tmp=[];
            
            kspace=p_tmp;
            k_tmp=kspace(difference_idx_matrix_tmp);
            k_tmp(difference_idx_matrix_nan_idx)=0;
            D(:,1:prod(size(difference_kernel_mask)))=k_tmp;
            
            D_idx=sum((abs(D)>eps),2);
            
            dd=difference_kernel_mask.*(-1);
            dd((length(difference_kernel_mask(:))+1)/2)=prod(size(difference_kernel_mask))-1;
            
            D(:,(prod(size(difference_kernel_mask))+1)/2)=D(:,(prod(size(difference_kernel_mask))+1)/2)./(prod(size(difference_kernel_mask))-1).*D_idx;
            
            tmp=D*dd(:);
            
            % diag_TV
            tmp=tmp(:).*diag_TV(:);
            
            %hermittian of diag_TV
            tmp=tmp(:).*conj(diag_TV(:));
            
            tmp=reshape(tmp,[n_phase n_freq]);
            
            %hermittian of finite difference
            kspace=tmp;
            k_tmp=kspace(difference_idx_matrix_tmp);
            k_tmp(difference_idx_matrix_nan_idx)=0;
            D(:,1:prod(size(difference_kernel_mask)))=k_tmp;
            
            D_idx=sum((abs(D)>eps),2);
            
            dd=difference_kernel_mask.*(-1);
            dd((length(difference_kernel_mask(:))+1)/2)=prod(size(difference_kernel_mask))-1;
            
            D(:,(prod(size(difference_kernel_mask))+1)/2)=D(:,(prod(size(difference_kernel_mask))+1)/2)./(prod(size(difference_kernel_mask))-1).*D_idx;
            
            tmp=D*dd(:);
            
            % hermittian of Fourier encoding
            p_tmp=reshape(tmp,[n_phase n_freq]);
            %p_tmp=fftshift(fft2(fftshift(p_tmp)));
            
            %add TV regularization term
            xx=xx+lambda_TV.*p_tmp.*I;
            %xx=xx+lambda.*lambda.*del2(ss0).*I;
            
            %add regularization term
            %xx=xx+lambda.*lambda.*ss0.*I;
            %xx=xx+lambda.*lambda.*del2(ss0).*I;
            
            if(~isempty(ss_gfactor))
                g2_gfactor=sum(temp_gfactor,3);
            end;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% CG starts
            q=xx;
            w=sum(sum(abs(r(:,:,iteration_idx-1)).^2))/sum(sum(conj(p(:,:,iteration_idx)).*q));
            b(:,:,iteration_idx)=b(:,:,iteration_idx-1)+p(:,:,iteration_idx).*w;
            r(:,:,iteration_idx)=r(:,:,iteration_idx-1)-q.*w;
            %%% CG ends
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if(flag_debug)
                subplot(131);
                imagesc(abs(b(:,:,iteration_idx).*I)); colormap(gray); axis off image; colorbar;
                
                subplot(132);
                imagesc(abs(r(:,:,iteration_idx))); colormap(gray); axis off image; colorbar;
                
                subplot(133);
                imagesc(abs(p(:,:,iteration_idx))); colormap(gray); axis off image; colorbar;
            end;
            iteration_idx=iteration_idx+1;
            
            if(iteration_idx > iteration_max)
                convergence=1;
            end;
        end;
        if(flag_display) fprintf('\n'); end;
    end;
    
    %update L1 TV regularization weighting matrix
    % Fourier encoding
    p_tmp=b(:,:,end).*I;
    %p_tmp=fftshift(fft2(fftshift(p_tmp)));
    
    % finite difference
    kspace=p_tmp;
    k_tmp=kspace(difference_idx_matrix_tmp);
    k_tmp(difference_idx_matrix_nan_idx)=0;
    D(:,1:prod(size(difference_kernel_mask)))=k_tmp;
    
    D_idx=sum((abs(D)>eps),2);
    
    dd=difference_kernel_mask.*(-1);
    dd((length(difference_kernel_mask(:))+1)/2)=prod(size(difference_kernel_mask))-1;
    
    D(:,(prod(size(difference_kernel_mask))+1)/2)=D(:,(prod(size(difference_kernel_mask))+1)/2)./(prod(size(difference_kernel_mask))-1).*D_idx;
    
    tmp=D*dd(:);
    
    diag_TV0=diag_TV;
    diag_TV=1./sqrt(eps+abs(tmp(:)).^2);
    diag_TV=diag_TV./max(diag_TV);
    
    l1_history(:,:,l1_idx)=b(:,:,end).*I;
end;

if(flag_display)
    fprintf('\n');
end;

%finalize output
if(size(b,3)>1)
    b(:,:,1)=[];
    delta(1)=[];
end;

%intensity correction for all;
for i=1:size(b,3)
    b(:,:,i)=b(:,:,i).*I;
end;

recon=b(:,:,end);

if(~isempty(X0))
    recon=recon+X0;
    b=b+repmat(X0,[1 1 size(b,3)]);
end;
