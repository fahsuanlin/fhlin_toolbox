function [X,Enc]=ulfmri_tdr_forward_H(varargin);
%
%	ulfmri_tdr_forward		calculate the hermittian of the forward encoding matrix of
%	ultra low field MRI
%
%
%	[Y,E]=ulfmri_tdr_forward_H('X',x,'S',S,'G',G,'K',K,'flag_display',1);
%
%	INPUT:
%	if enable phase sensitive detection (flag_psd=1)
%   Y: multiple sets of encoded data [n_PE, n_PE, n_chan].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%		n_chan: # of channel
%	if not enable phase sensitive detection (flag_psd=0)
%   Y: multiple sets of encoded data [n_PE, n_PE, 3, n_chan].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%       the third dimension is the total x-, y-, and z-components of the detected
%       magnetic field flux
%		n_chan: # of channel
%	S: coil sensitivity maps of [n_PE, n_FE, 3, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%       the third dimensions are for x-, y-, and z-components of the
%       sensitivity fields
%   G_general: spatial encoding magnetic fields for "frequency" and "phase" encoding [n_PE, n_FE, 3, n_G]
%       *must be paired with K_general
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%       the third dimensions are for x-, y-, and z-components of the
%       gradient fields
%   K_general: k-space structure of [n_encode]
%		n_encode: # of phase encoding steps
%       K_general has the following fields:
%           G: strength of gradient fields [n_G]
%               each value indicates the relative strength of the gradient
%               field (positive or negative)
%               n_G: # of spatial encoding magnetic fields
%           readout_time: [1 n_readout]
%               the data acquisition time for each sample (second)
%               n_readout: number of readout
%           readout_duration: [1 n_readout]
%               the data acquisition dwell time for each sample (second)
%               n_readout: number of readout
%           pre_duation: pre-phase duration (second)
%           k: k-space coordinate [n_readout n_G]
%               n_G: # of spatial encoding magnetic fields
%               n_readout: number of readout
%
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%   X: spatial domain data [n_PE*n_PE, 4].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%
%   E: encoding matrix [n_chan*n_read n_PE*n_FE]
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin,
%   Athinoula A. Martinos Center, Mass General Hospital
%   Institute of Biomedical Engineering, National Taiwan University
%
%	fhlin@nmr.mgh.harvard.edu
%   fhlin@ntu.edu.tw
%
%	fhlin@Oct. 7 2011

S=[];
Y=[];
X=[];
K_general=[];
G_general=[];
E=[];

n_freq=[];
n_phase=[];

flag_psd=1; %phase sensitive detection: demodulating the B0 Larmor frequency

flag_display=0;
flag_debug=0;

iteration_max=[];
epsilon=[];

recon=[];
b=[];
delta=[];
g2_gfactor=[];

n_calc=32;

T1=[];
T2=[];

Bm=[];
Bp=[];
FOV=[];

gamma=42.58*1e6; %proton; Hz/T
G_max=[];

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'y'
            Y=option_value;
        case 'gamma'
            gamma=option_value;
        case 't1'
            T1=option_value;
        case 't2'
            T2=option_value;
        case 'bm'
            Bm=option_value;
        case 'bp'
            Bp=option_value;
        case 'fov'
            FOV=option_value;
        case 'k_general'
            K_general=option_value;
        case 'g_general'
            G_general=option_value;
        case 'g_max'
            G_max=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
        case 'n_calc'
            n_calc=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_psd'
            flag_psd=option_value;
        case 'flag_debug'
            flag_debug=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare gradient information

if(isempty(n_freq))
    n_freq=size(G{1},2);
end;
if(isempty(n_phase))
    n_phase=size(G{1},1);
end;


n_chan=size(S,4);

if(isempty(G_general))
    %    [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase/2) :1:ceil(n_phase/2)-1]);
    %    G_general(:,:,1)=grid_freq./max(grid_freq(:)).*G_max;
    %    G_general(:,:,2)=grid_phase./max(grid_freq(:)).*G_max;
    fprintf('no gradient spec...!\nerror!\n');
    return;
end;

if(isempty(T1))
    T1=ones(n_phase,n_freq).*inf;
end;
if(isempty(T2))
    T2=ones(n_phase,n_freq).*inf;
end;

if(isempty(FOV))
    fprintf('no FOV spec...!\nerror!\n');
    return;
else
    [xx,yy]=meshgrid([0:n_freq-1]-n_freq/2,[0:n_phase-1]-n_phase/2);
    FOV_x=xx./n_freq.*FOV;
    FOV_y=yy./n_phase.*FOV;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         E          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_encode=size(K_general,1);

Bm_tmp(:,1)=reshape(Bm(:,:,1),[n_phase*n_freq,1]);
Bm_tmp(:,2)=reshape(Bm(:,:,2),[n_phase*n_freq,1]);
Bm_tmp(:,3)=reshape(Bm(:,:,3),[n_phase*n_freq,1]);

Bp_tmp(:,1)=reshape(Bp(:,:,1),[n_phase*n_freq,1]);
Bp_tmp(:,2)=reshape(Bp(:,:,2),[n_phase*n_freq,1]);
Bp_tmp(:,3)=reshape(Bp(:,:,3),[n_phase*n_freq,1]);

for g_idx=1:size(G_general,4)
    G_tmp(:,1,g_idx)=reshape(G_general(:,:,1,g_idx),[n_phase*n_freq,1]);
    G_tmp(:,2,g_idx)=reshape(G_general(:,:,2,g_idx),[n_phase*n_freq,1]);
    G_tmp(:,3,g_idx)=reshape(G_general(:,:,3,g_idx),[n_phase*n_freq,1]);
end;

for ch_idx=size(S,4)
    S_tmp(:,1,ch_idx)=reshape(S(:,:,1,ch_idx),[n_phase*n_freq,1]);
    S_tmp(:,2,ch_idx)=reshape(S(:,:,2,ch_idx),[n_phase*n_freq,1]);
    S_tmp(:,3,ch_idx)=reshape(S(:,:,3,ch_idx),[n_phase*n_freq,1]);
    
    %for PSD....
    S_tmp_z=repmat(sum(S_tmp(:,:,ch_idx).*Bm_tmp,2),[1 3]).*Bm_tmp;
    S_tmp_xy=S_tmp(:,:,ch_idx)-S_tmp_z;
    S_tmp_xy_norm=sqrt(sum(S_tmp_xy.^2,2));
    S_tmp_x=cross(Bm_tmp,S_tmp_xy);
    S_tmp_x=S_tmp_x.*repmat(S_tmp_xy_norm./sqrt(sum(S_tmp_x.^2,2)),[1 3]);
    S_tmp_im(:,:,ch_idx)=S_tmp_z+S_tmp_x;
end;

%if(flag_psd)
%    Y=zeros(length(K_general),length(K_general(1).readout_duration),size(S,4));
%else
%    Y=zeros(length(K_general),length(K_general(1).readout_duration),3,size(S,4));
%end;

Enc=[];
%dd=X_init';

X=zeros(n_phase*n_freq*4,1);
T_pre=zeros(n_phase*n_freq,4,4);
T=zeros(n_phase*n_freq,4,4);

for readout_idx=1:length(K_general)
    %    for readout_idx=9:9
    fprintf('readout [%03d|%03d]....\r',readout_idx,length(K_general));
    
    %for readout_idx=1:1
    X_tmp=zeros(n_phase*n_freq*4,1);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% start pre-phasing %%%%%%%%%%%%%
    B_total=Bm_tmp;
    for g_idx=1:size(G_general,4)
        B_total=B_total+G_tmp(:,:,g_idx).*K_general(readout_idx).G(g_idx).pre_amplitude;
    end;
    B_total_norm=sqrt(sum(B_total.^2,2));
    if(flag_psd) %phase sensitive detection: demodulating the B0 Larmor frequency
        B_total_norm=B_total_norm-Bm_tmp(:,1);
    end;
    
    
    
    %define rotation matrix for local coordinates
    %z-direction: aligning with B_total
    R_pre(:,3,1:3)=B_total./repmat(sqrt(sum(B_total.^2,2)),[1 3]);
    %y-direction: global(y) - <global(y), B_total>*B_total
    yy=repmat([0 1 0],[n_phase*n_freq,1]);
    R_pre(:,2,1:3)=yy-repmat(dot(yy,squeeze(R_pre(:,3,1:3)),2),[1 3]).*squeeze(R_pre(:,3,1:3));
    %x-direction: cross <local(y), local(z)>
    yy=repmat([0 1 0],[n_phase*n_freq,1]);
    R_pre(:,1,1:3)=cross(squeeze(R_pre(:,2,1:3)),squeeze(R_pre(:,3,1:3)));
    R_pre(:,1,1:3)=squeeze(R_pre(:,1,1:3))./repmat(sqrt(sum(squeeze(R_pre(:,1,1:3)).^2,2)),[1 3]);
    R_pre(:,4,4)=1;
    
    
    dT=K_general(readout_idx).pre_duration;
    
    
    %define relaxiation matrix
    E_pre=zeros(size(B_total,1),4,4);
    E_pre(:,1,1)=exp(-dT./T2(:));
    E_pre(:,2,2)=exp(-dT./T2(:));
    E_pre(:,3,3)=exp(-dT./T1(:));
    E_pre(:,3,4)=B_total_norm(:)./Bp_tmp(:,3).*(1-exp(-dT./T1(:)));
    E_pre(:,4,4)=1;
    
    %define rotation matrix
    P_pre=zeros(size(B_total,1),4,4);
    P_pre(:,1,1)=cos(2*pi*gamma.*B_total_norm.*dT);
    P_pre(:,1,2)=-sin(2*pi*gamma.*B_total_norm.*dT);
    P_pre(:,2,1)=sin(2*pi*gamma.*B_total_norm.*dT);
    P_pre(:,2,2)=cos(2*pi*gamma.*B_total_norm.*dT);
    P_pre(:,3,3)=1;
    P_pre(:,4,4)=1;
    
    
    for idx=1:n_phase*n_freq
        T_pre(idx,:,:)=squeeze(R_pre(idx,:,:))'*squeeze(P_pre(idx,:,:))*squeeze(E_pre(idx,:,:))*squeeze(R_pre(idx,:,:));
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%% start readout %%%%%%%%%%%%%%%%%
    B_total=Bm_tmp;
    for g_idx=1:size(G_general,4)
        B_total=B_total+G_tmp(:,:,g_idx).*K_general(readout_idx).G(g_idx).readout_amplitude;
    end;
    B_total_norm=sqrt(sum(B_total.^2,2));
    if(flag_psd) %phase sensitive detection: demodulating the B0 Larmor frequency
        B_total_norm=B_total_norm-Bm_tmp(:,1);
    end;
    
    %define rotation matrix for local coordinates
    %z-direction: aligning with B_total
    R(:,3,1:3)=B_total./repmat(sqrt(sum(B_total.^2,2)),[1 3]);
    %y-direction: global(y) - <global(y), B_total>*B_total
    yy=repmat([0 1 0],[n_phase*n_freq,1]);
    R(:,2,1:3)=yy-repmat(dot(yy,squeeze(R(:,3,1:3)),2),[1 3]).*squeeze(R(:,3,1:3));
    %x-direction: cross <local(y), local(z)>
    yy=repmat([0 1 0],[n_phase*n_freq,1]);
    R(:,1,1:3)=cross(squeeze(R(:,2,1:3)),squeeze(R(:,3,1:3)));
    R(:,1,1:3)=squeeze(R(:,1,1:3))./repmat(sqrt(sum(squeeze(R(:,1,1:3)).^2,2)),[1 3]);
    
    R(:,4,4)=1;
    
    dT=0;
    for t_idx=1:length(K_general(readout_idx).readout_time)
        %dT=dT+K_general(readout_idx).readout_duration(t_idx);
        dT=K_general(readout_idx).readout_duration(t_idx);
        
        %define relaxiation matrix
        E=zeros(size(B_total,1),4,4);
        E(:,1,1)=exp(-dT./T2(:));
        E(:,2,2)=exp(-dT./T2(:));
        E(:,3,3)=exp(-dT./T1(:));
        E(:,3,4)=B_total_norm(:)./Bp_tmp(:,3).*(1-exp(-dT./T1(:)));
        E(:,4,4)=1;
        
        %define rotation matrix
        P=zeros(size(B_total,1),4,4);
        P(:,1,1)=cos(2*pi*gamma.*B_total_norm.*dT);
        P(:,1,2)=-sin(2*pi*gamma.*B_total_norm.*dT);
        P(:,2,1)=sin(2*pi*gamma.*B_total_norm.*dT);
        P(:,2,2)=cos(2*pi*gamma.*B_total_norm.*dT);
        P(:,3,3)=1;
        P(:,4,4)=1;
        
        
        for ch_idx=1:size(S,4)
            if(flag_psd)
                Es_tmp=[S_tmp(:,1,ch_idx)-sqrt(-1).*S_tmp_im(:,1,ch_idx),S_tmp(:,2,ch_idx)-sqrt(-1).*S_tmp_im(:,2,ch_idx),S_tmp(:,3,ch_idx)-sqrt(-1).*S_tmp_im(:,3,ch_idx),zeros(n_phase*n_freq,1)].';
            else
                Es_tmp=[S_tmp(:,1,ch_idx), S_tmp(:,2,ch_idx), S_tmp(:,3,ch_idx), zeros(n_phase*n_freq,1)].';
            end;
            Es_tmp=Es_tmp(:);
            
            X_tmp0=X_tmp;
            if(t_idx>1) T_before=T; end;
                
            for idx=1:n_phase*n_freq
                T(idx,:,:)=squeeze(R(idx,:,:))'*squeeze(P(idx,:,:))*squeeze(E(idx,:,:))*squeeze(R(idx,:,:));
            end;
            
            for idx=1:n_phase*n_freq
                if(t_idx==1)
                    E_tmp((idx-1)*4+1:idx*4,:)=squeeze(T(idx,:,:));
                else
                    E_tmp((idx-1)*4+1:idx*4,:)=squeeze(T(idx,:,:))*E_tmp((idx-1)*4+1:idx*4,:);
                end;
            end;
            
            EE=zeros(n_phase*n_freq*4,1);
            XX=zeros(n_phase*n_freq*4,1);
            for idx=1:n_phase*n_freq
                EE((idx-1)*4+1:idx*4,1)=squeeze(T_pre(idx,:,:))'*squeeze(E_tmp((idx-1)*4+1:idx*4,:))'*Es_tmp((idx-1)*4+1:idx*4,:);
                XX((idx-1)*4+1:idx*4)=EE((idx-1)*4+1:idx*4).*squeeze(Y(readout_idx,t_idx,ch_idx));
            end;

            Enc=cat(2,Enc,EE(:));
            X=X+XX(:);
        end;
    end;
end;

Enc=Enc(3:4:end,:);
X=X(3:4:end);

fprintf('\n');

return;





