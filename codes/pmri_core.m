function [x_unreg, g_unreg, x_reg, g_reg]=pmri_core(varargin);
%
%	pmri_core		perform SENSE/Inverse reconstruction
%
%
%	[recon_unreg, g_unreg]=pmri_core('A',A,'Y',Y,'S',S,'C',C,'flag_unreg',1,'flag_unreg_g',1);
%
%	INPUT:
%	A: 2D fourier aliasing matrix of [n_PE_acc, n_PE].
%		n_PE_acc: # of accelerated phase encoding steps
%		n_PE: # of phase encoding steps before acceleration
%	Y: input data of [n_PE, n_FE, n_chan]. 
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	Omega:  phase maps of [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	C: noise covariance matrix of [n_chan, n_chan].
%		n_chan: # of channel
%	P: prior of [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	R: source covariance matrix of [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
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
%	recon_unreg: 2D un-regularized SENSE reconstruction [n_PE, n_PE].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%	g_unreg: 2D un-regularized g-factor map [n_PE, n_PE].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@jan. 20, 2005

A=[];

S=[];

C=[];

Y=[];

P=[];

R=[];

Omega=[];

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

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'a'
            A=option_value;
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
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;


x_unreg=zeros(size(A,2),size(Y,2));
x_reg=zeros(size(A,2),size(Y,2));

%g_unreg=zeros(size(A,2),size(Y,2));
%g_reg=zeros(size(A,2),size(Y,2));
g_unreg=[];
g_reg=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	preparation of noise covariance and whitening matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isempty(C))
    if(isempty(Y))	%no data
        fprintf('no data to build noise covariance matrix model!\nerror!\n');
        return;
    else
        C=eye(size(Y,3));
    end;
end;

if(flag_smooth_constraint)
    fprintf('smooth constraint, preparing laplacian...\n');
    SS=2.*eye(size(A,2))+circshift(eye(size(A,2)).*-1,[0 1])+circshift(eye(size(A,2)).*-1,[0 -1]);
    SS(1,:)=0; SS(1,1)=2; 
    SS(end,:)=0; SS(end,end)=2; 
    Rsmooth=inv(SS'*SS);
else
    Rsmooth=eye(size(A,2));
end;

if(isempty(R))
    R=ones(size(A,2),size(Y,2));
end;
r_p=sqrt(R);
r_n=sqrt(pinv(r_p));

%prepare whitening data
[u,s,v]=svd(C);
W=pinv(sqrt(s))*u';	%whitening matrix

%ss=repmat(transpose(diag(C)),[size(Y,1),1]);
%N=diag(ss(:));
%[u_n,s_n,v_n]=svd(N);		
%W_n=sqrt(pinv(s_n))*u_n';


tic;

n_coil=size(Y,3);
Y=permute(Y,[1,3,2]);
S=permute(S,[1,3,2]);
if(isempty(Omega))
    Omega=zeros(size(S));
end;

for fe_idx=1:size(Y,3)
    if(flag_display)
        fprintf('.');
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	preparation of observation data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Y_w=Y(:,:,fe_idx)*W';
    
    Z=[];	
    for i=1:n_coil
        if(flag_phase_constraint)
            Z=cat(1,Z,real(Y_w(:,i)));
            Z=cat(1,Z,imag(Y_w(:,i)));
        else
            Z=cat(1,Z,Y_w(:,i));
        end;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	preparation of encoding matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    S_w=S(:,:,fe_idx)*W';
    
    E=[];
    for i=1:n_coil
        if(flag_phase_constraint)
            if(~flag_loose_phase_constraint)
                E=cat(1,E,real(A.*(ones(size(A,1),1)*transpose(cos(Omega(:,fe_idx)).*S_w(:,i)))));
                E=cat(1,E,imag(A.*(ones(size(A,1),1)*transpose(sin(Omega(:,fe_idx)).*S_w(:,i)))));
            else
                A_rp=real(A.*(ones(size(A,1),1)*transpose(cos(Omega(:,fe_idx)).*S_w(:,i))));
                A_rt=real(A.*(ones(size(A,1),1)*transpose(-sin(Omega(:,fe_idx)).*S_w(:,i))));
                E=cat(1,E,[A_rp A_rt]);
                A_ip=imag(A.*(ones(size(A,1),1)*transpose(sin(Omega(:,fe_idx)).*S_w(:,i))));
                A_it=imag(A.*(ones(size(A,1),1)*transpose(cos(Omega(:,fe_idx)).*S_w(:,i))));
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
            x_unreg(:,fe_idx)=lsqr(E,Z,0.1,size(E,2));
        else
            M=E'*E;
            x_unreg(:,fe_idx)=inv(M)*E'*Z;
        end;
    end;
    
    if(flag_unreg_g)
        M=E'*E;
        g_unreg(:,fe_idx)=sqrt(diag(inv(M)).*diag(M));
    end;
    
    if(flag_display)
        if(fe_idx==round(size(Y,3)/2))
            fprintf('debug at freq. encoding [%d]...\n',fe_idx);
            yy_data=Z;
            yy_recon=E*x_unreg(:,fe_idx);
            xx=[1:length(Z)];
            subplot(221);
            plot(xx,real(yy_data),xx,real(yy_recon));
            legend({'RE(data)','RE(model)'});
            subplot(222);
            plot(xx,imag(yy_data),xx,imag(yy_recon));
            legend({'IM(data)','IM(model)'});
            subplot(223);
            rr=zeros(size(S_w(:,1)));
            for rr_idx=1:size(S_w,2)
                rr=rr+S_w(:,rr_idx).*x_unreg(:,fe_idx); 
            end;
            rr=rr./size(S_w,2);
            plot([real(rr) abs(rr)]);
            legend({'RE(recon)','ABS(recon)'});
            subplot(224);
        end;
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	SENSE reconstruction using regularized least squares
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(flag_reg|flag_reg_g)
        %prepare source covariance
        [ux,sx,vx]=svd(diag(R(:,fe_idx))*Rsmooth);
        %r_p=sqrt(pinv(sx))*ux';
        %r_n=pinv(r_p);
        
        r_p=ux*sqrt(sx);
        r_n=pinv(r_p);
        
        %r_p=chol(diag(R(:,fe_idx))*Rsmooth);
        %r_n=pinv(r_p);
        
        E=E*r_p;

        if(size(E,1)>=size(E,2))
            [u_e,s_e,v_e]=svd(E,0);
        else
            [u_e,s_e,v_e]=svd(E,0);
            u_e=u_e(:,1:size(E,1));
        end;	
        
        Gamma=diag(diag(s_e)./(diag(s_e).^2+lambda(fe_idx).^2));
        
        Gamma2=diag(s_e).^2./(diag(s_e).^2+lambda(fe_idx).^2);

        Phi=diag(lambda(fe_idx).^2./(diag(s_e).^2+lambda(fe_idx).^2));
        
        if(size(E,1)<size(E,2))
            Gamma=[Gamma;zeros(size(E,2)-size(E,1),size(E,1))];
            Gamma2(end+1:size(E,2))=0;
            PP=eye(size(E,2));
            PP(1:size(E,1),1:size(E,1))=Phi;
            Phi=PP;
        end;
        
        if(flag_reg)
            if(~flag_phase_constraint)
                %tmp=r_p(:,fe_idx).*(v_e*Gamma*u_e'*Z)+r_p(:,fe_idx).*(v_e*Phi*v_e'*(r_n(:,fe_idx).*P(:,fe_idx)));
                %tmp=r_p*(v_e*Gamma*u_e'*Z)+r_p*(v_e*Phi*v_e'*(r_n*P(:,fe_idx)));   
                tmp=r_p*(v_e*Gamma*u_e'*Z)+(eye(size(v_e,1))-r_p*(v_e.*repmat(Gamma2',[size(v_e,1),1]))*v_e')*P(:,fe_idx);   
                
                %                    if(fe_idx==32)
                %                         plot([1:64],abs(r_p*(v_e*Gamma*u_e'*Z)),'r',[1:64],abs((v_e*Gamma*u_e'*Z)),'b',[1:64],abs(P(:,fe_idx)),'k');
                %                    end;
                
            else
                if(~flag_loose_phase_constraint)
                    %tmp=r_p(:,fe_idx).*(v_e*Gamma*u_e'*Z)+r_p(:,fe_idx).*(v_e*Phi*v_e'*(r_n(:,fe_idx).*P(:,fe_idx)));
                    %tmp=r_p*(v_e*Gamma*u_e'*Z)+r_p*(v_e*Phi*v_e'*(r_n*P(:,fe_idx)));
                    tmp=r_p*(v_e*Gamma*u_e'*Z)+(eye(size(v_e,1))-r_p*(v_e.*repmat(Gamma2',[size(v_e,1),1]))*v_e')*P(:,fe_idx);   
                else
                    r_p2=[r_p(:,fe_idx); 0.5.*r_p(:,fe_idx)];
                    r_n2=[r_n(:,fe_idx); 2.*r_n(:,fe_idx)];
                    P2=[P(:,fe_idx); P(:,fe_idx)];
                    %tmp=r_p2.*(v_e*Gamma*u_e'*Z)+r_p2.*(v_e*Phi*v_e'*(r_n2.*P2));
                    %tmp=r_p2*(v_e*Gamma*u_e'*Z)+r_p2*(v_e*Phi*v_e'*(r_n2*P2));
                    tmp=r_p2*(v_e*Gamma*u_e'*Z)+(eye(size(v_e,1))-r_p2*(v_e.*repmat(Gamma2',[size(v_e,1)*2,1]))*v_e')*P2(:,fe_idx);   
                end;
            end;
            
%             if(~flag_phase_constraint)
%                 x_reg(:,fe_idx)=tmp;
%             else
%                 if(~flag_loose_phase_constraint)
%                     x_reg(:,fe_idx)=tmp.*exp(sqrt(-1).Omega(:,fe_idx));
%                 else
%                     tmp1=tmp(1:length(tmp)/2).*exp(sqrt(-1).*Omega(:,fe_idx));
%                     tmp2=tmp(length(tmp)/2+1:end).*exp(sqrt(-1).*(Omega(:,fe_idx)+pi/2));
%                     x_reg(:,fe_idx)=tmp1+tmp2;
%                 end;
%             end;
        end;
        
        if(flag_reg_g)
            if(size(E,1)<size(E,2))
                g_reg(:,fe_idx)=sqrt(diag(v_e*(Gamma).^2*v_e(:,1:size(E,1))').*diag(v_e(:,1:size(E,1))*(s_e).^2*v_e'));
            else
                g_reg(:,fe_idx)=(diag(v_e*(Gamma).^2*v_e').*diag(v_e*(s_e).^2*v_e')).^(0.5);
            end;
        else
            g_reg(:,fe_idx)=0;
        end;
    else
        x_reg(:,fe_idx)=0;
        g_reg(:,fe_idx)=0;
    end;
    
end;

S=permute(S,[1,3,2]);
if(flag_ivs)
    if(flag_reg)
        xx_reg=zeros(size(S,1),size(S,2));
        for idx=1:size(S,3)
            xx_reg=xx_reg+abs(S(:,:,idx).*x_reg).^2;
        end;
        x_reg=sqrt(xx_reg);
    end;
    
    if(flag_unreg)
        xx_unreg=zeros(size(S,1),size(S,2));
        for idx=1:size(S,3)
            xx_unreg=xx_unreg+abs(S(:,:,idx).*x_unreg).^2;
        end;
        x_unreg=sqrt(xx_unreg);
    end;
end;

if(flag_display)
    fprintf('\n');
    tt=toc;
    fprintf('SENSE recon. time=%2.2f\n',tt);
end;

