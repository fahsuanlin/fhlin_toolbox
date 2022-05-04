function [recon,b,delta,g2_gfactor]=itdr4_core_cart_cg(varargin);
%
%	itdr4_core_cart_cg		perform generalized PatLoc reconstruction using
%	time-domain signals and the conjugated gradient method in Cartesian
%	sampling trajectory
%
%
%	[recon,b,delta]=itdr4_core_cart_cg('Y',Y,'S',S,'G',G,'K',K,'flag_display',1);
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
%	G: spatial encoding magnetic fields for "frequency" and "phase" encoding: {n_G}.freq: [n_PE, n_FE], {n_G}.phase: [n_PE, n_FE]
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
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

S=[];
Y=[];
K=[];
G=[];
gfactor=[];

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

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'y'
            Y=option_value;
        case 'k'
            K=option_value;
        case 'g'
            G=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
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
% prepare gradient information

if(isempty(n_freq))
    n_freq=size(Y{1},2);
end;
if(isempty(n_phase))
    n_phase=size(Y{1},1);
end;

%setup 2D gradient
if(isempty(G))
    [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase/2) :1:ceil(n_phase/2)-1]);
    G{1}.freq=grid_freq;
    G{1}.phase=grid_phase;
end;

n_chan=size(S,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TDR preparation
gamma=267.52e6;     %gyromagnetic ratio; rad/Tesla/s
FOV_freq=256e-3;        %m
FOV_phase=256e-3;        %m
delta_time_freq=40e-6;      %sampling time (read-out): s
time_phase=4e-3;            %duration of phase encoding gradient: s
grad_max_freq=2.*pi./gamma./FOV_freq./delta_time_freq;     %gradient (read-out): T/m
grad_delta_phase=2.*pi./gamma./FOV_phase./time_phase;;     %gradient (phase): T/m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  vvvvvvvvvvvvvvv  begin reconstruction now  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intensity correction

I=zeros(size(S,1),size(S,2));
for i=1:size(S,3)
    I=I+abs(S(:,:,i)).^2;
end;
I=1./sqrt(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~flag_cg_gfactor)
    % FT1
    %implemeting IFT part by time-domin reconstruction (TDR)
    %get the sampling time k-space coordinate.
    recon=zeros(n_phase,n_freq,n_chan);
    recon2=zeros(n_phase,n_freq,n_chan);
    for g_idx=1:length(G)
        grid_freq=G(g_idx).freq;
        grid_phase=G(g_idx).phase;
        G_freq=repmat(grid_freq,[1 1 n_freq]);
        G_phase=repmat(grid_phase,[1 1 n_freq]);

        D_freq=repmat(([1:n_freq]-floor(n_freq./2)-1)',[1 n_phase n_freq]);
        D_freq=permute(D_freq,[2 3 1]);
        K_freq=exp(sqrt(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);
        K_freq2=repmat(transpose(reshape(K_freq,[n_freq*n_phase n_freq])),[1 1 n_chan]);

        for y_idx=1:n_phase
            if(sum(K{g_idx}(y_idx,:))>eps)
                if(flag_display) fprintf('*'); end;
                k_phase=exp(sqrt(-1).*gamma.*grad_delta_phase.*(y_idx-floor(n_phase./2)-1).*time_phase.*FOV_phase./n_phase.*grid_phase);
                K_phase=repmat(k_phase,[1 1 n_freq]);
                K_phase2=repmat(transpose(reshape(K_phase,[n_freq*n_phase n_freq])),[1 1 n_chan]);

                %for i=1:n_chan
                %    X=repmat(transpose(Y{g_idx}(y_idx,:,i)),[1 n_phase n_freq]);
                %    X=permute(X,[2 3 1]);
                %    recon(:,:,i)=recon(:,:,i)+sum(X.*K_freq.*K_phase,3);
                %end;

                tmp=(squeeze(Y{g_idx}(y_idx,:,:)));
                buffer=permute(repmat(tmp,[1 1 n_freq*n_phase]),[1,3,2]);
                recon2=recon2+reshape(squeeze(sum(buffer.*K_phase2.*K_freq2,1)),[n_phase n_freq n_chan]);

            end;
        end;
    end;
    if(flag_display) fprintf('\n'); end;

    for i=1:n_chan
        % S' (complex-conjugated sensitivity)
        %temp(:,:,i)=recon(:,:,i).*conj(S(:,:,i));
        temp(:,:,i)=recon2(:,:,i).*conj(S(:,:,i));
    end;
    %intensity correction here
    a=sum(temp,3).*I;
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

        if(flag_cg_gfactor&iteration_idx==2)
            ss_gfactor=Y{1}(:,:,1);
        else
            ss_gfactor=[];
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         E          %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

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
            G_freq=repmat(grid_freq,[1 1 n_freq]);
            G_phase=repmat(grid_phase,[1 1 n_freq]);

            D_freq=repmat(([1:n_freq]-floor(n_freq./2)-1)',[1 n_phase n_freq]);
            D_freq=permute(D_freq,[2 3 1]);
            K_freq=exp(sqrt(-1).*(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);

            Temp{g_idx}=zeros(n_phase,n_freq,n_chan);
            Temp_gfactor{g_idx}=zeros(n_phase,n_freq,n_chan);
            for y_idx=1:n_phase
                if(sum(K{g_idx}(y_idx,:))>eps)
                    if(flag_display) fprintf('#'); end;
                    k_phase=exp(sqrt(-1).*(-1).*gamma.*grad_delta_phase.*(y_idx-floor(n_phase./2)-1).*time_phase.*FOV_phase./n_phase.*grid_phase);
                    K_phase=repmat(k_phase,[1 1 n_freq]);


                    for i=1:n_chan
                        X=repmat(temp(:,:,i),[1 1 n_freq]);
                        Temp{g_idx}(y_idx,:,i)=squeeze(sum(sum(X.*K_freq.*K_phase,1),2));

                        if(~isempty(ss_gfactor))
                            X=repmat(temp_gfactor(:,:,i),[1 1 n_freq]);
                            Temp_gfactor{g_idx}(y_idx,:,i)=squeeze(sum(sum(X.*K_freq.*K_phase,1),2));
                        end;
                    end;
                end;
            end;
        end;

        buffer=Temp;

        if(~isempty(ss_gfactor))
            buffer_gfactor=Temp_gfactor;
        end;

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
        end;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         E'          %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % FT1
        %implemeting IFT part by time-domin reconstruction (TDR)
        %get the sampling time k-space coordinate.
        recon=zeros(n_phase,n_freq,n_chan);
        recon2=zeros(n_phase,n_freq,n_chan);
        recon2_gfactor=zeros(n_phase,n_freq,n_chan);

        tmp=[];
        for g_idx=1:length(G)
            grid_freq=G(g_idx).freq;
            grid_phase=G(g_idx).phase;
            G_freq=repmat(grid_freq,[1 1 n_freq]);
            G_phase=repmat(grid_phase,[1 1 n_freq]);

            D_freq=repmat(([1:n_freq]-floor(n_freq./2)-1)',[1 n_phase n_freq]);
            D_freq=permute(D_freq,[2 3 1]);
            K_freq=exp(sqrt(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);
            K_freq2=repmat(transpose(reshape(K_freq,[n_freq*n_phase n_freq])),[1 1 n_chan]);

            for y_idx=1:n_phase
                if(sum(K{g_idx}(y_idx,:))>eps)
                    if(flag_display) fprintf('*'); end;
                    k_phase=exp(sqrt(-1).*gamma.*grad_delta_phase.*(y_idx-floor(n_phase./2)-1).*time_phase.*FOV_phase./n_phase.*grid_phase);
                    K_phase=repmat(k_phase,[1 1 n_freq]);
                    K_phase2=repmat(transpose(reshape(K_phase,[n_freq*n_phase n_freq])),[1 1 n_chan]);

                    tmp=(squeeze(buffer{g_idx}(y_idx,:,:)));
                    tmp=permute(repmat(tmp,[1 1 n_freq*n_phase]),[1,3,2]);
                    recon2=recon2+reshape(squeeze(sum(tmp.*K_phase2.*K_freq2,1)),[n_phase n_freq n_chan]);

                    if(~isempty(ss_gfactor))
                        tmp=(squeeze(buffer_gfactor{g_idx}(y_idx,:,:)));
                        tmp=permute(repmat(tmp,[1 1 n_freq*n_phase]),[1,3,2]);
                        recon2_gfactor=recon2_gfactor+reshape(squeeze(sum(tmp.*K_phase2.*K_freq2,1)),[n_phase n_freq n_chan]);
                    end;
                end;
            end;
        end;


        % S' (complex-conjugated sensitivity)
        for i=1:n_chan
            temp(:,:,i)=recon2(:,:,i).*conj(S(:,:,i));
        end;

        if(~isempty(ss_gfactor))
            for i=1:n_chan
                temp_gfactor(:,:,i)=recon2_gfactor(:,:,i).*conj(S(:,:,i));
            end;
        end;

        %intensity correction here
        xx=sum(temp,3).*I;

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
