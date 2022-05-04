function [Y,E,E_k]=mri_patloc_tdr_forward(varargin);
%
%	mri_patloc_tdr_forward		calculate the forward encoding matrix of
%	patloc imaging
%
%
%	[Y,E,E_k]=mri_patloc_tdr_forward('S',S,'G',G,'K',K,'flag_display',1);
%
%	INPUT:
%	X: object to be encoded [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%   G_general: spatial encoding magnetic fields for "frequency" and "phase" encoding [n_PE, n_FE, n_G]
%       *must be paired with K_general
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	G: spatial encoding magnetic fields for "frequency" and "phase" encoding: {n_G}.freq: [n_PE, n_FE], {n_G}.phase: [n_PE, n_FE]
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%   K_general: n-D k-space coordinates [n_encode, n_G]
%       *must be paired with G_general
%		n_G: # of spatial encoding magnetic fields
%		n_encode: # of k-space data
%	K_arbitrary: 2D k-space coordinates {n_G}[FE, PE].
%		n_G: # of spatial encoding magnetic fields
%		PE: # k-space frequency encoding grid
%		FE: # k-space phase encoding grid
%       PE and FE must be within [-1, 1), where 1 corresponds to the
%       maximal k-space coordinate for the spatial resolution requited to
%       distinguish two neighboring pixel in the image domain.
%	K: 2D k-space sampling matrix with entries of 0 or 1 {n_G}[n_PE, n_FE].
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		"0" indicates the correponding entries are not sampled in accelerated scan.
%		"1" indicates the correponding entries are sampled in accelerated scan.
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	Y: multiple sets of encoded data {n_G}[n_PE, n_PE].
%		n_G: # of of spatial encoding magnetic fields
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%	E: 2D encoding matrix [n_chan*n_encode, n_PE*n_PE].
%		n_chan: # of RF channels
%       n_encode: # of total encoded data points across of spatial encoding magnetic fields
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%	E_k: 2D encoding matrix [n_encode, n_PE*n_PE] due to spatial encoding magnetic fields.
%       n_encode: # of total encoded data points across of spatial encoding magnetic fields
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps%
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

S=[];
Y=[];
X=[];
K=[];
K_arbitrary=[];
K_general=[];
G=[];
G_general=[];
E=[];

n_freq=[];
n_phase=[];

flag_cg_gfactor=0;

flag_display=0;
flag_debug=0;

iteration_max=[];
epsilon=[];

recon=[];
b=[];
delta=[];
g2_gfactor=[];

n_calc=32;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'x'
            X=option_value;
        case 'k'
            K=option_value;
        case 'k_arbitrary'
            K_arbitrary=option_value;
        case 'k_general'
            K_general=option_value;
        case 'g'
            G=option_value;
        case 'g_general'
            G_general=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
        case 'n_calc'
            n_calc=option_value;
        case 'flag_display'
            flag_display=option_value;
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

%setup 2D gradient
if(isempty(G))
    [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase/2) :1:ceil(n_phase/2)-1]);
    G{1}.freq=grid_freq;
    G{1}.phase=grid_phase;
end;

n_chan=size(S,3);



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         E          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init
n_encode=0;
if(~isempty(K))
    for k_idx=1:length(K)
        n_encode=n_encode+length(find(K{k_idx}(:)));
        n_encode_k(k_idx)=length(find(K{k_idx}(:)));
    end;
elseif(~isempty(K_arbitrary))
    for k_idx=1:length(K_arbitrary)
        n_encode=n_encode+size(K_arbitrary{k_idx},1);
        n_encode_k(k_idx)=size(K_arbitrary{k_idx},1);
    end;
elseif(~isempty(K_general))
    n_encode=size(K_general,1);
end;



% FT2
%implemeting FT part by time-domin reconstruction (TDR)
%get the sampling time k-space coordinate.
E_k=[];
if((~isempty(K)|~isempty(K_arbitrary)))
    for g_idx=1:length(G)
        e{g_idx}=[];
        grid_freq=G(g_idx).freq;
        grid_phase=G(g_idx).phase;

        k_freq_prep=sqrt(-1).*(-1).*2.*pi./n_freq.*grid_freq;
        k_phase_prep=sqrt(-1).*(-1).*2.*pi./n_phase.*grid_phase;

        if(~isempty(K))
            k_idx=find(K{g_idx}(:)>eps);
            [k_idx_phase,k_idx_freq]=ind2sub([n_phase,n_freq],k_idx);
        elseif(~isempty(K_arbitrary))
            k_idx=[1:size(K_arbitrary{g_idx},1)];
            k_idx_phase=K_arbitrary{g_idx}(:,2).*(n_phase/2)+n_phase/2+1;
            k_idx_freq=K_arbitrary{g_idx}(:,1).*(n_freq/2)+n_freq/2+1;
        end;

        clear tmp;
        tmp{g_idx}=zeros(n_phase*n_freq,n_chan);

        for calc_idx=1:ceil(length(k_idx)/n_calc)
            if(calc_idx~=ceil(length(k_idx)/n_calc))
                k_idx_phase_now=k_idx_phase((calc_idx-1)*n_calc+1:calc_idx*n_calc);
                k_idx_freq_now=k_idx_freq((calc_idx-1)*n_calc+1:calc_idx*n_calc);
                k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
            else
                k_idx_phase_now=k_idx_phase((calc_idx-1)*n_calc+1:length(k_idx));
                k_idx_freq_now=k_idx_freq((calc_idx-1)*n_calc+1:length(k_idx));
                k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
            end;
            k_phase=exp(k_phase_prep(:)*[k_idx_phase_now-floor(n_phase./2)-1]');
            k_freq=exp(k_freq_prep(:)*[k_idx_freq_now-floor(n_freq./2)-1]');

            k_encode=k_freq.*k_phase;
            
            e{g_idx}=cat(1,e{g_idx},transpose(k_encode));
        end;

        E_k=cat(1,E_k,e{g_idx});
    end;
elseif(~isempty(K_general))
    for g_idx=1:size(G_general,3)
        G_tmp(:,g_idx)=reshape(G_general(:,:,g_idx),[n_phase*n_freq,1]);
    end;

    k_prep=sqrt(-1).*(-1).*2.*pi.*G_tmp./2;
    k_idx=[1:size(K_general,1)];
    for calc_idx=1:ceil(size(K_general,1)/n_calc)
        if(calc_idx~=ceil(length(k_idx)/n_calc))
            k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
        else
            k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
        end;
        
        k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));
        E_k=cat(1,E_k,transpose(k_encode));
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display) fprintf('making encoding matrix...\n'); end;
E=[];
for i=1:size(S,3)
    % S (sensitivity)
    ss=S(:,:,i);
    ss=ss(:);
    E=cat(1,E,E_k*diag(ss));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(X))
    if(flag_display) fprintf('forward...\n'); end;
    if(isempty(K_general))
        for g_idx=1:length(G)
            if(~isempty(K))
                k_idx=find(K{g_idx});

                Y{g_idx}=zeros(n_phase,n_freq,n_chan);
                for i=1:size(S,3)
                    % S (sensitivity)
                    ss=X.*S(:,:,i);
                    tmp=e{g_idx}*ss(:);
                    temp=zeros(n_phase,n_freq);
                    temp(k_idx)=tmp;
                    Y{g_idx}(:,:,i)=temp;
                end;

            elseif(~isempty(K_arbitrary))
                k_idx=[1:size(K_arbitrary{g_idx},1)];
                Y{g_idx}=zeros(n_encode_k(g_idx),n_chan);
                for i=1:size(S,3)
                    % S (sensitivity)
                    ss=X.*S(:,:,i);
                    tmp=e{g_idx}*ss(:);
                    Y{g_idx}(:,i)=tmp(:);
                end;
            end;
        end;
    else
        for i=1:size(S,3)
            % S (sensitivity)
            ss=X.*S(:,:,i);
            tmp=E_k*ss(:);
            Y(:,i)=tmp(:);
        end;
    end;
end;

return;


