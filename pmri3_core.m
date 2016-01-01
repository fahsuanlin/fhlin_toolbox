function [x_unreg, g_unreg, x_reg, g_reg]=pmri3_core(varargin);
%
%	pmri3_core		perform SENSE/Inverse reconstruction for 3D parallel
%	MRI
%
%
%	[recon_unreg, g_unreg, recon_reg, g_reg]=pmri3_core('K',K,'Y',Y,'S',S,'C',C);
%
%	INPUT:
%	K: 3D fourier aliasing matrix of [n_PE1, n_PE2].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 2
%	Y: input data of [n_PE1, n_PE2, n_PE3, n_chan]. 
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 2
%		n_chan: # of channel
%	S: coil sensitivity maps of [n_PE1, n_PE2, n_PE3, n_chan].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 2
%		n_chan: # of channel
%	Omega:  phase maps of [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%	C: noise covariance matrix of [n_chan, n_chan].
%		n_chan: # of channel
%	P: prior of [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%	R: source covariance matrix of [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%	'flag_unreg': value of either 0 or 1
%		reconstruct un-regularized SENSE image
%	'flag_reg': value of either 0 or 1
%		reconstruct regularized SENSE image
%	'flag_unreg_g': value of either 0 or 1
%		computer un-regularized g-factor map
%	'flag_reg_g': value of either 0 or 1
%		computer regularized g-factor map
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%
%	OUTPUT:
%	recon_unreg: 3D un-regularized SENSE reconstruction [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%	g_unreg: 3D un-regularized g-factor map [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%	recon_reg: 3D regularized SENSE reconstruction [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%	g_reg: 3D regularized g-factor map [n_PE1, n_PE2, n_PE3].
%		n_PE1: # phase encoding steps in direction 1
%		n_PE2: # phase encoding steps in direction 2
%		n_PE3: # phase encoding steps in direction 3
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@jul 11, 2006

K=[];

S=[];

C=[];

Y=[];

P=[];

R=[];

Omega=[];

lambda=[];

sample_vector=[];

flag_display=0;

flag_reg=0;
flag_reg_g=0;

flag_unreg=1;
flag_unreg_g=0;

flag_lsqr=0;
flag_phase_constraint=0;
flag_loose_phase_constraint=0;
flag_ivs=0;
flag_smooth_constraint=0;

max_recon_counter=[];

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'k'
            K=option_value;
        case 's'
            S=option_value;
        case 'omega'
            Omega=option_value;
        case 'c'
            C=option_value;
        case 'p'
            P=option_value;
        case 'r'
            R=option_value;
        case 'y'
            Y=option_value;
        case 'lambda'
            lambda=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'reg_lambda'
            reg_lambda=option_value;
        case 'flag_reg'
            flag_reg=option_value;
        case 'flag_reg_g'
            flag_reg_g=option_value;
        case 'flag_unreg'
            flag_unreg=option_value;
        case 'flag_ivs'
            flag_ivs=option_value;    
        case 'flag_smooth_constraint'
            flag_smooth_constraint=option_value;    
        case 'flag_lsqr'
            flag_lsqr=option_value;
        case 'flag_phase_constraint'
            flag_phase_constraint=option_value;
        case 'flag_loose_phase_constraint'
            flag_loose_phase_constraint=option_value;
        case 'flag_unreg_g'
            flag_unreg_g=option_value;
        case 'recon_channel_weight'
            recon_channel_weight=option_value;
        case 'max_recon_counter'
            max_recon_counter=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

%Y0=Y;
%%apply appropriate extrapolation
%k_row=max(abs(K),[],2);
%k_col=max(abs(K),[],1);
%r_row=median(diff(find(diff(k_row)==-1)));
%r_col=median(diff(find(diff(k_col)==-1)));
%row_new=size(Y0,1); row_add=0;
%col_new=size(Y0,2); col_add=0;
%flag_interp=0;
%if(mod(size(Y0,1),r_row)~=0)
%    row_new=ceil(size(Y0,1)/r_row)*r_row;
%    row_add=row_new-size(Y0,1);
%    flag_interp=1;
%    fprintf('the row dimension is interpolated from [%d] to [%d]\n',size(Y0,1),row_new);
%end;
%if(mod(size(Y0,2),r_col)~=0)
%    col_new=ceil(size(Y0,2)/r_col)*r_col;
%    col_add=col_new-size(Y0,1);
%    flag_interp=1;
%    fprintf('the column dimension is interpolated from [%d] to [%d]\n',size(Y0,2),col_new);
%end;
%
%if(flag_interp)
%    if(~isempty(P)) P=imresize(P,[row_new, col_new]); end;
%    if(~isempty(R)) R=imresize(R,[row_new, col_new]); end;
%    if(~isempty(Omega)) Omega=imresize(Omega,[row_new, col_new]); end;
%    for idx=1:size(S,3) S1(:,:,idx)=imresize(S(:,:,idx),[row_new, col_new]); end; S=S1;
%    k_center_row_old=ceil((size(K,1)+1)/2);
%    k_center_col_old=ceil((size(K,2)+1)/2);
%    k_center_row_new=ceil((row_new+1)/2);
%    k_center_col_new=ceil((col_new+1)/2);
%    
%    K1=zeros(row_new,col_new); K1(1+k_center_row_new-k_center_row_old:k_center_row_new-k_center_row_old+size(K,1),1+k_center_col_new-k_center_col_old:k_center_col_new-k_center_col_old+size(K,2))=K; K=K1;
%    for idx=1:size(S,3) S1(:,:,idx)=imresize(S(:,:,idx),[row_new, col_new]); end; S=S1;
%    
%    Y1=zeros(row_new,col_new,size(Y0,3));
%    for idx=1:size(Y0,3) 
%        Y_tmp=fftshift(ifft2(fftshift(Y0(:,:,idx))));
%        Y1(1+floor(row_add/2):floor(row_add/2)+size(Y0,1),1+floor(col_add/2):floor(col_add/2)+size(Y0,2))=Y_tmp;
%    end;
%    Y=Y1;
%end;


x_unreg=zeros(size(Y,1),size(Y,2),size(Y,3));
x_reg=zeros(size(Y,1),size(Y,2),size(Y,3));

g_unreg=zeros(size(Y,1),size(Y,2),size(Y,3));
g_reg=zeros(size(Y,1),size(Y,2),size(Y,3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	preparation of noise covariance and whitening matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isempty(C))
    if(isempty(Y))	%no data
        fprintf('no data to build noise covariance matrix model!\nerror!\n');
        return;
    else
        C=eye(size(Y,4));
    end;
end;

% if(flag_smooth_constraint)
%     fprintf('smooth constraint, preparing laplacian...\n');
%     SS=2.*eye(size(K,2))+circshift(eye(size(K,2)).*-1,[0 1])+circshift(eye(size(K,2)).*-1,[0 -1]);
%     SS(1,:)=0; SS(1,1)=2; 
%     SS(end,:)=0; SS(end,end)=2; 
%     Rsmooth=inv(SS'*SS);
% else
%     Rsmooth=eye(size(A,2));
% end;

if(isempty(R))
    R=ones(size(Y,1),size(Y,2),size(Y,3));
end;
r_p=sqrt(R);
%r_n=sqrt(pinv(r_p));


%prepare whitening data
[u,s,v]=svd(C);
W=pinv(sqrt(s))*u';	%whitening matrix

if(isempty(Omega))
    Omega=zeros(size(S));
end;

n_coil=size(Y,4);

tic;

cont=1;
recon_source_index=zeros(size(Y,1),size(Y,2),size(Y,3));
recon_obs_index=zeros(size(Y,1),size(Y,2),size(Y,3));
recon_counter=0;
current_ss=1;
current_cc=1;

for ii=1:n_coil
    tmp=Y(:,:,:,ii);
    Y_tmp(:,ii)=tmp(:);
end;
for ii=1:n_coil
    tmp=S(:,:,:,ii);
    S_tmp(:,ii)=tmp(:);
end;

while(cont)
    obs_idx=find(recon_obs_index(:)==0);
    if(isempty(obs_idx))
        cont=0;
    else
        obs_idx=obs_idx(1);
        recon_counter=recon_counter+1;
        tmp=zeros(size(Y,1),size(Y,2),size(Y,3));
        tmp(obs_idx)=1;

        %point spread function
        psf=fftshift(fftn(fftshift(fftshift(ifftn(fftshift(tmp))).*K)));
        
        ttmp=abs(psf);
        source_idx=find(abs(ttmp(:))>eps);
        [rr,cc,ss]=ind2sub([size(Y,1),size(Y,2),size(Y,3)],source_idx);
        if(cc(1)>current_cc)
            if(flag_display)
                fprintf('.')
            end;
            current_cc=cc(1);
        end;
        if(ss(1)>current_ss)
            if(flag_display)
                fprintf('*\n')
            end;
            current_cc=1;
            current_ss=ss(1);
        end;
        
        flag_do_recon=~isempty(setdiff(source_idx,find(recon_source_index)));
        
        recon_source_index(source_idx)=1;
        recon_obs_index(obs_idx)=1;
        
        fmri_mont(recon_source_index); pause(0.1);

        
        if(flag_do_recon)
            
            %iterate through SENSE recon.
            A=transpose(psf(source_idx));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %	preparation of observation data
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %for ii=1:n_coil
                %Y_tmp=Y(:,:,:,ii);
            %    Y_w(:,ii)=Y_tmp(obs_idx);
            %end;
            Y_w=Y_tmp(obs_idx,:);
            Y_w=Y_w*W';
            
            Z=[];	
%             for i=1:n_coil
%                 if(flag_phase_constraint)
%                     Z=cat(1,Z,real(Y_w(:,i)));
%                     Z=cat(1,Z,imag(Y_w(:,i)));
%                 else
%                     Z=cat(1,Z,Y_w(:,i));
%                 end;
%             end;
            if(~flag_phase_constraint)
                Z=Y_w(:);
            else
                tmp=[real(Y_w(:)) imag(Y_w(:))]';
                Z=tmp(:);
            end;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %	preparation of encoding matrix
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %for ii=1:n_coil
                %S_tmp=S(:,:,:,ii);
            %    S_w(:,ii)=S_tmp(source_idx);
            %end;
            S_w=S_tmp(source_idx,:);
            S_w=S_w*W';
            
            E=[];
            for i=1:n_coil
                if(flag_phase_constraint)
                    if(~flag_loose_phase_constraint)
                        E=cat(1,E,real(A.*(ones(size(A,1),1)*transpose(cos(Omega(source_idx)).*S_w(:,i)))));
                        E=cat(1,E,imag(A.*(ones(size(A,1),1)*transpose(sin(Omega(source_idx)).*S_w(:,i)))));
                    else
                        A_rp=real(A.*(ones(size(A,1),1)*transpose(cos(Omega(source_idx)).*S_w(:,i))));
                        A_rt=real(A.*(ones(size(A,1),1)*transpose(-sin(Omega(source_idx)).*S_w(:,i))));
                        E=cat(1,E,[A_rp A_rt]);
                        A_ip=imag(A.*(ones(size(A,1),1)*transpose(sin(Omega(source_idx)).*S_w(:,i))));
                        A_it=imag(A.*(ones(size(A,1),1)*transpose(cos(Omega(source_idx)).*S_w(:,i))));
                        E=cat(1,E,[A_ip A_it]);
                    end;
                else
                    E=cat(1,E,A.*(ones(size(A,1),1)*transpose(S_w(:,i))));
                end;
            end;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %	SENSE reconstruction using least squares
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(flag_unreg)
                if(flag_lsqr)
                    x_unreg(source_idx)=lsqr(E,Z,0.1,size(E,2));
                else
                    M=E'*E;
                    x_unreg(source_idx)=inv(M)*E'*Z;
                end;
            end;
            
            if(flag_unreg_g)
                M=E'*E;
                g_unreg(source_idx)=sqrt(diag(inv(M)).*diag(M));
            end;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %	SENSE reconstruction using regularized least squares
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %prepare source covariance
            %[ux,sx,vx]=svd(diag(R(source_idx))*Rsmooth);
            %[ux,sx,vx]=svd(diag(R(source_idx)));
            
            %r_p=ux*sqrt(sx);
            r_p=sqrt(R(source_idx));
            
            %                     r_p=chol(diag(R(source_idx)));
            
            %E=E*r_p;
            E=E.*repmat(transpose(r_p(:)),[size(E,1),1]);
            
            if(flag_reg|flag_reg_g)
                if(size(E,1)>=size(E,2))
                    [u_e,s_e,v_e]=svd(E,0);
                else
                    [v_e,s_e,u_e]=svd(E',0);
                    %v_e=v_e(:,1:size(E,1));
                end;	
                
                if(isempty(lambda))
                    Gamma=diag(diag(s_e)./(diag(s_e).^2+(s_e(1,1).*0.01).^2));
                    Gamma2=diag(s_e).^2./(diag(s_e).^2+(s_e(1,1).*0.01).^2);
                    Phi=diag((s_e(1,1).*0.01).^2./(diag(s_e).^2+(s_e(1,1).*0.01).^2));
                else
                    Gamma=diag(diag(s_e)./(diag(s_e).^2+mean2(lambda(source_idx)).^2));
                    Gamma2=diag(s_e).^2./(diag(s_e).^2+mean2(lambda(source_idx)).^2);
                    Phi=diag(mean2(lambda(source_idx)).^2./(diag(s_e).^2+mean2(lambda(source_idx)).^2));
                end;
                
                if(size(E,1)<size(E,2))
                    %Gamma=[Gamma;zeros(size(E,2)-size(E,1),size(E,1))];
                    %Gamma2(end+1:size(E,2))=0;
                    PP=eye(size(E,2));
                    PP(1:size(E,1),1:size(E,1))=Phi;
                    Phi=PP;
                end;
                if(flag_reg)
                    if(~flag_phase_constraint)
                        if(sum(abs(P(source_idx)))>0)
                            tmp=r_p(:).*(v_e*Gamma*u_e'*Z)+P(source_idx)-r_p(:).*((v_e.*repmat(Gamma2',[size(v_e,1),1])*v_e')*P(source_idx));   
                        else
                            tmp=r_p(:).*(v_e*Gamma*u_e'*Z);   
                        end;
                    else
                        if(~flag_loose_phase_constraint)
                            if(sum(abs(P(source_idx)))>0)
                                tmp=r_p(:).*(v_e*Gamma*u_e'*Z)+P(source_idx)-r_p(:).*((v_e.*repmat(Gamma2',[size(v_e,1),1])*v_e')*P(source_idx));   
                            else
                                tmp=r_p(:).*(v_e*Gamma*u_e'*Z);   
                            end;
                        else
                            r_p2=[r_p(source_idx); 0.5.*r_p(source_idx)];
                            P2=[P(source_idx); P(source_idx)];
                            %tmp=r_p2*(v_e*Gamma*u_e'*Z)+(eye(size(v_e,1))-r_p2*(v_e.*repmat(Gamma2',[size(v_e,1)*2,1]))*v_e')*P2(source_idx);   
                            if(sum(abs(P2(source_idx)))>0)
                                tmp=r_p2(:).*(v_e*Gamma*u_e'*Z)+P2(source_idx)-r_p2(:).*((v_e.*repmat(Gamma2',[size(v_e,1),1])*v_e')*P2(source_idx));   
                            else
                                tmp=r_p2(:).*(v_e*Gamma*u_e'*Z);   
                            end;
                        end;
                    end;
                    if(~flag_phase_constraint)
                        x_reg(source_idx)=tmp;
                    else
                        if(~flag_loose_phase_constraint)
                            x_reg(source_idx)=tmp.*exp(sqrt(-1).Omega(source_idx));
                        else
                            tmp1=tmp(1:length(tmp)/2).*exp(sqrt(-1).*Omega(source_idx));
                            tmp2=tmp(length(tmp)/2+1:end).*exp(sqrt(-1).*(Omega(source_idx)+pi/2));
                            x_reg(source_idx)=tmp1+tmp2;
                        end;
                    end;
                end;
                if(flag_reg_g)
                    if(size(E,1)<size(E,2))
                        g_reg(source_idx)=sqrt(diag(v_e*(Gamma).^2*v_e(:,1:size(E,1))').*diag(v_e(:,1:size(E,1))*(s_e).^2*v_e'));
                    else
                        g_reg(source_idx)=sqrt(diag(v_e*(Gamma).^2*v_e').*diag(v_e*(s_e).^2*v_e'));
                    end;
                else
                    g_reg(source_idx)=0;
                end;
            else
                x_reg(source_idx)=0;
                g_reg(source_idx)=0;
            end;
        end;
        
        if(~isempty(max_recon_counter))
            if(recon_counter>=max_recon_counter)
                cont=0;
            end;
        end;
    end;
end;

if(flag_display)
    fprintf('\n');
    tt=toc;
    fprintf('SENSE3 recon. time=%2.2f\n',tt);
end;

return;
