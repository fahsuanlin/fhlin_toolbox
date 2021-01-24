function [recon,b,delta,g2_gfactor,Local_kspace]=itdr4_core_ktraj_cg(varargin);
%
%	itdr4_core_ktraj_cg		perform generalized PatLoc reconstruction using
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
%	G: spatial encoding magnetic fields for "frequency" and "phase" encoding: {n_G}.freq: [n_PE, n_FE], {n_G}.phase: [n_PE, n_FE]
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
%	K_arbitrary: 2D k-space coordinates {n_G}[FE, PE].
%		n_G: # of spatial encoding magnetic fields
%		PE: # k-space frequency encoding grid
%		FE: # k-space phase encoding grid
%       PE and FE must be within [-1, 1), where 1 corresponds to the
%       maximal k-space coordinate for the spatial resolution required to
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

S=[];
Y=[];
K=[];
K_general=[];
K_arbitrary=[];
G=[];
G_general=[];
gfactor=[];
X0=[];
lambda=0;

%off-resonance
dF_general=[];
dFt_general=[];


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
        case 'k_arbitrary'
            K_arbitrary=option_value;
        case 'k_general'
            K_general=option_value;
        case 'g'
            G=option_value;
        case 'g_general'
            G_general=option_value;
        case 'lambda'
            lambda=option_value;
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
if(isempty(G)&isempty(G_general))
    [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase/2) :1:ceil(n_phase/2)-1]);
    G{1}.freq=grid_freq;
    G{1}.phase=grid_phase;
end;
if(~isempty(G_general))
    for g_idx=1:size(G_general,3)
        G_tmp(:,g_idx)=reshape(G_general(:,:,g_idx),[n_phase*n_freq,1]);
    end;
end;
n_chan=size(S,3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  vvvvvvvvvvvvvvv  begin reconstruction now  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intensity correction

I=zeros(size(S,1),size(S,2));
for i=1:size(S,3)
    I=I+abs(S(:,:,i)).^2;
end;

I=I+lambda.*lambda.*ones(size(I));

I=1./sqrt(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~flag_cg_gfactor)
    % FT1
    %implemeting IFT part by time-domin reconstruction (TDR)
    %get the sampling time k-space coordinate.
    recon2=zeros(n_phase*n_freq,n_chan);
    if((~isempty(K)|~isempty(K_arbitrary)))

        for g_idx=1:length(G)
            if(~isempty(K))
                Y{g_idx}=reshape(Y{g_idx},[n_phase*n_freq, n_chan]);
            end;

            grid_freq=G(g_idx).freq;
            grid_phase=G(g_idx).phase;

            k_freq_prep=sqrt(-1).*(1).*2.*pi./n_freq.*grid_freq;
            k_phase_prep=sqrt(-1).*(1).*2.*pi./n_phase.*grid_phase;

            if(~isempty(K))
                k_idx=find(K{g_idx}(:)>eps);
                [k_idx_phase,k_idx_freq]=ind2sub([n_phase,n_freq],k_idx);
            elseif(~isempty(K_arbitrary))
                k_idx=[1:size(K_arbitrary{g_idx},1)];
                k_idx_phase=K_arbitrary{g_idx}(:,2).*(n_phase/2)+n_phase/2+1;
                k_idx_freq=K_arbitrary{g_idx}(:,1).*(n_freq/2)+n_freq/2+1;
            end;

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
                k_phase=(exp(k_phase_prep(:)*[k_idx_phase_now-floor(n_phase./2)-1]'));
                k_freq=(exp(k_freq_prep(:)*[k_idx_freq_now-floor(n_freq./2)-1]'));

                k_encode=repmat(k_freq.*k_phase,[1 1 n_chan]);
                x=permute(repmat(Y{g_idx}(k_idx_now,:),[1 1 size(k_encode,1)]),[3 1 2]);

                recon2=recon2+squeeze(sum(x.*k_encode,2));
            end;
        end;

    elseif(~isempty(K_general))
        k_prep=sqrt(-1).*(1).*2.*pi.*G_tmp./2;
        k_idx=[1:size(K_general,1)];
        for calc_idx=1:ceil(size(K_general,1)/n_calc)
            if(calc_idx~=ceil(length(k_idx)/n_calc))
                k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
            else
                k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
            end;
            k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));
            
            if(~isempty(dF_general)&&~isempty(dFt_general))
                k_encode=k_encode.*exp(sqrt(-1).*(1).*2.*pi.*(dF_general(:)*dFt_general(k_idx_now)));
            end;
            
            recon2=recon2+(k_encode)*Y(k_idx_now,:);
        end;
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
    % In the case with a regularization term, the formulation is equivalent to augmenting the forward operator A with an identity matrix weighted by a regularization parameter.
    % The identity matrix may be replaced by other linear operators to implement, for example, total variation or wavelet transform.
    
    a=a+lambda.*lambda.*X0.*I;
    %a=a+lambda.*lambda.*del2(X0).*I;
else
    a=Y{1}(:,:,1).*I;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convergence=0;
iteration_idx=2;

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
        if((~isempty(K)|~isempty(K_arbitrary)))

            for i=1:size(S,3)
                % S (sensitivity)
                temp(:,:,i)=ss.*S(:,:,i);

                if(~isempty(ss_gfactor))
                    temp_gfactor(:,:,i)=ss_gfactor.*S(:,:,i);
                end;
            end;


            % FT2
            %implemeting FT part by time-domin reconstruction (TDR)
            %get the sampling time k-space coordinate.
            Temp=[];
            Temp_gfactor=[];
            for g_idx=1:length(G)
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
                if(~isempty(ss_gfactor))
                    tmp_gfactor{g_idx}=zeros(n_phase*n_freq,n_chan);
                end;

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

                    k_encode=repmat(k_freq.*k_phase,[1 1 n_chan]);
                    x=permute(repmat(reshape(temp,[n_phase*n_freq,size(temp,3)]),[1 1 size(k_encode,2)]),[1 3 2]);
                    tmp{g_idx}(k_idx_now,:)=squeeze(sum(x.*k_encode,1));

                    if(~isempty(ss_gfactor))
                        x=permute(repmat(reshape(temp_gfactor,[n_phase*n_freq,size(temp_gfactor,3)]),[1 1 size(k_encode,2)]),[1 3 2]);
                        tmp_gfactor{g_idx}(k_idx_now,:)=squeeze(sum(x.*k_encode,1));
                    end;
                end;

                if(~isempty(K))
                    Temp{g_idx}=reshape(tmp{g_idx},[n_phase, n_freq, n_chan]);
                    if(~isempty(ss_gfactor))
                        Temp_gfactor{g_idx}=reshape(tmp_gfactor{g_idx},[n_phase, n_freq, n_chan]);
                    end;
                elseif(~isempty(K_arbitrary))
                    Temp{g_idx}=tmp{g_idx};
                    if(~isempty(ss_gfactor))
                        Temp_gfactor{g_idx}=tmp_gfactor{g_idx};
                    end;
                end;
            end;
        elseif(~isempty(K_general))
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
                
                if(~isempty(dF_general)&&~isempty(dFt_general))
                    k_encode=k_encode.*exp(sqrt(-1).*(-1).*2.*pi.*(dF_general(:)*dFt_general(k_idx_now)));
                end;
                
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

        if(~isempty(K))
            for g_idx=1:length(K)
                k_idx=find(K{g_idx}<eps);

                for i=1:n_chan
                    %K-space acceleration
                    buffer0=buffer{g_idx}(:,:,i);
                    buffer0(k_idx)=0;
                    buffer{g_idx}(:,:,i)=buffer0;

                    if(~isempty(ss_gfactor))
                        buffer0_gfactor=buffer_gfactor{g_idx}(:,:,i);
                        buffer0_gfactor(k_idx)=0;
                        buffer_gfactor{g_idx}(:,:,i)=buffer0_gfactor;
                    end;

                end;
                buffer{g_idx}=reshape(buffer{g_idx},[n_phase*n_freq,size(buffer{g_idx},3)]);

                if(~isempty(ss_gfactor))
                    buffer_gfactor{g_idx}=reshape(buffer_gfactor{g_idx},[n_phase*n_freq,size(buffer_gfactor{g_idx},3)]);
                end;
            end;
        end;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         E'          %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % FT1
        %implemeting IFT part by time-domin reconstruction (TDR)
        %get the sampling time k-space coordinate.
        recon2=zeros(n_phase*n_freq,n_chan);
        recon2_gfactor=zeros(n_phase*n_freq,n_chan);
        if((~isempty(K)|~isempty(K_arbitrary)))
            for g_idx=1:length(G)
                grid_freq=G(g_idx).freq;
                grid_phase=G(g_idx).phase;

                k_freq_prep=sqrt(-1).*(1).*2.*pi./n_freq.*grid_freq;
                k_phase_prep=sqrt(-1).*(1).*2.*pi./n_phase.*grid_phase;

                if(~isempty(K))
                    k_idx=find(K{g_idx}(:)>eps);
                    [k_idx_phase,k_idx_freq]=ind2sub([n_phase,n_freq],k_idx);
                elseif(~isempty(K_arbitrary))
                    k_idx=[1:size(K_arbitrary{g_idx},1)];
                    k_idx_phase=K_arbitrary{g_idx}(:,2).*(n_phase/2)+n_phase/2+1;
                    k_idx_freq=K_arbitrary{g_idx}(:,1).*(n_freq/2)+n_freq/2+1;
                end;

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
                    k_phase=(exp(k_phase_prep(:)*[k_idx_phase_now-floor(n_phase./2)-1]'));
                    k_freq=(exp(k_freq_prep(:)*[k_idx_freq_now-floor(n_freq./2)-1]'));

                    k_encode=repmat(k_freq.*k_phase,[1 1 n_chan]);
                   
                    x=permute(repmat(buffer{g_idx}(k_idx_now,:),[1 1 size(k_encode,1)]),[3 1 2]);
                    recon2=recon2+squeeze(sum(x.*k_encode,2));

                    if(~isempty(ss_gfactor))
                        x=permute(repmat(buffer_gfactor{g_idx}(k_idx_now,:),[1 1 size(k_encode,1)]),[3 1 2]);
                        recon2_gfactor=recon2_gfactor+squeeze(sum(x.*k_encode,2));
                    end;
                end;
            end;
        elseif(~isempty(K_general))
            k_prep=sqrt(-1).*(1).*2.*pi.*G_tmp./2;
            k_idx=[1:size(K_general,1)];
            for calc_idx=1:ceil(size(K_general,1)/n_calc)
                if(calc_idx~=ceil(length(k_idx)/n_calc))
                    k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
                else
                    k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
                end;
               
                k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));

                if(~isempty(dF_general)&&~isempty(dFt_general))
                    k_encode=k_encode.*exp(sqrt(-1).*(1).*2.*pi.*(dF_general(:)*dFt_general(k_idx_now)));
                end;
                
                recon2=recon2+(k_encode)*buffer(k_idx_now,:);
                
                if(~isempty(ss_gfactor))
                    recon2_gfactor=recon2_gfactor+(k_encode)*buffer_gfactor(k_idx_now,:);
                end;
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

        %add regularization term
        % In the case with a regularization term, the formulation is equivalent to augmenting the forward operator A with an identity matrix weighted by a regularization parameter.
        % The identity matrix may be replaced by other linear operators to implement, for example, total variation or wavelet transform.
        
        xx=xx+lambda.*lambda.*ss0.*I;
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
