function [Local_kspace]=itdr4_core_ktraj_localk(varargin);
%
%	itdr4_core_ktraj_localk		calculate the local k-space
%
%
%	[recon,b,delta]=itdr4_core_ktraj_localk('Y',Y,'S',S,'G',G,'K',K,'flag_display',1);
%
%	INPUT:
%   G_general: spatial encoding magnetic fields for "frequency" and "phase" encoding [n_PE, n_FE, n_G]
%       *must be paired with K_general
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%   K_general: n-D k-space coordinates [n_encode, n_G]
%       *must be paired with G_general
%		n_G: # of spatial encoding magnetic fields
%		n_encode: # of k-space data
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin,
%   Athinoula A. Martinos Center, Mass General Hospital
%   Institute of Biomedical Engineering, National Taiwan University
%
%	fhlin@nmr.mgh.harvard.edu
%   fhlin@ntu.edu.tw
%
%	fhlin@jan 11 2011

S=[];
K_general=[];
G_general=[];


n_freq=[];
n_phase=[];


flag_display=0;
flag_debug=0;

flag_local_k=0;
local_k_size=7;
Local_kspace=[];

K_local_x=[];
K_local_y=[];

n_calc=32;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'k_general'
            K_general=option_value;
        case 'g_general'
            G_general=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
        case 'n_calc'
            n_calc=option_value;
        case 'flag_local_k'
            flag_local_k=option_value; %local k-space;
        case 'k_local_x'
            K_local_x=option_value;
        case 'k_local_y'
            K_local_y=option_value;
        case 'local_k_size'
            local_k_size=option_value; %local k-space;
        case 'flag_cg_gfactor'
            flag_cg_gfactor=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%loca k-space setup
if(isempty(K_local_x)&isempty(K_local_y))
    dist_freq=floor(n_freq/local_k_size);
    dist_phase=floor(n_phase/local_k_size);
    K_local_x=([1:local_k_size]-(local_k_size+1)/2)*dist_freq+(n_freq)/2+1;
    K_local_y=([1:local_k_size]-(local_k_size+1)/2)*dist_phase+(n_phase)/2+1;
end;
[K_local_xx,K_local_yy]=meshgrid(K_local_x,K_local_y);
K_local_idx=sub2ind([n_phase,n_freq],K_local_yy(:),K_local_xx(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare gradient information

if(isempty(n_freq))
    n_freq=size(Y{1},2);
end;
if(isempty(n_phase))
    n_phase=size(Y{1},1);
end;

if(~isempty(G_general))
    for g_idx=1:size(G_general,3)
        G_tmp(:,g_idx)=reshape(G_general(:,:,g_idx),[n_phase*n_freq,1]);
    end;
end;
n_chan=size(S,3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         E          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

k_prep=sqrt(-1).*(-1).*2.*pi.*G_tmp./2;
k_idx=[1:size(K_general,1)];
for calc_idx=1:ceil(size(K_general,1)/n_calc)
    if(calc_idx~=ceil(length(k_idx)/n_calc))
        k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
    else
        k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
    end;

    k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));

    phi=imag(k_prep*transpose(K_general(k_idx_now,:)));
    phi=reshape(phi,[n_phase,n_freq,length(k_idx_now)]);
    for ii=1:length(k_idx_now)
        [dx,dy]=gradient(phi(:,:,ii));
        Kx_local(k_idx_now(ii),:)=dx(K_local_idx)';
        Ky_local(k_idx_now(ii),:)=dy(K_local_idx)';
    end;

end;

%local k-space
Local_kspace.kx=Kx_local;
Local_kspace.ky=Ky_local;
Local_kspace.pos_x=K_local_xx;
Local_kspace.pos_y=K_local_yy;

return;
