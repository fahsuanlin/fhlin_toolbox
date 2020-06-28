function [recon,b,delta]=itdr3_core_spiral_cg(varargin);
%
%	itdr3_core_spiral_cg		perform SENSE reconstruction using conjugated gradient method
%
%
%	[recon,b,delta]=itdr3_core_spiral_cg('Y',Y,'S',S,'C',C,'K',K,'flag_display',1);
%
%	INPUT:
%	Y: input data of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	C: noise covariance matrix of [n_chan, n_chan].
%		n_chan: # of channel
%	K: 2D k-space sampling matrix with entries of 0 or 1 [n_PE, n_FE].
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
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@mar. 18, 2005

S=[];
C=[];
Y=[];

K=[];
G=[];
P=[];

X0=[];

tra=[];
xtra=[];

n_freq=[];
n_phase=[];

flag_display=0;

flag_reg=0;
flag_reg_g=0;

flag_unreg=1;
flag_unreg_g=0;

flag_regrid=1;
flag_regrid_direct=0;   %direct regrid by nearest neighbor searching
flag_regrid_kb=1;       %Kaiser Bessel function regridding
flag_nufft=0;

flag_debug=0;



iteration_max=[];

epsilon=[];



for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'c'
            C=option_value;
        case 'p'
            P=option_value;
        case 'y'
            Y=option_value;
        case 'k'
            K=option_value;
        case 'g'
            G=option_value;
        case 'tra'
            tra=option_value;
        case 'xtra'
            xtra=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
        case 'x0'
            X0=option_value;
        case 'lambda'
            lambda=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_reg'
            flag_reg=option_value;
        case 'flag_reg_g'
            flag_reg_g=option_value;
        case 'flag_unreg'
            flag_unreg=option_value;
        case 'flag_unreg_g'
            flag_unreg_g=option_value;
        case 'flag_regrid'
            flag_regrid=option_value;
        case 'flag_regrid_direct'
            flag_regrid_direct=option_value;
        case 'flag_regrid_kb'
            flag_regrid_kb=option_value;
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
    n_freq=size(Y,2);
end;
if(isempty(n_phase))
    n_phase=size(Y,1);
end;

%setup 2D gradient
if(isempty(G))
    [grid_freq,grid_phase]=meshgrid([-floor(n_freq/2):ceil(n_freq/2)-1],[-floor(n_phase/2) :1:ceil(n_phase/2)-1]);
else
    grid_freq=G{1};
    grid_phase=G{2};
    grid_freq=fmri_scale(grid_freq,ceil(n_freq/2)-1,-floor(n_freq/2));
    grid_phase=fmri_scale(grid_phase,ceil(n_phase/2)-1,-floor(n_phase/2));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%preparation for TDR
gamma=267.52e6;     %gyromagnetic ratio; rad/Tesla/s
FOV_freq=256e-3;        %m
FOV_phase=256e-3;        %m
delta_time_freq=40e-6;      %sampling time (read-out): s
delta_time_phase=40e-6;      %sampling time (read-out): s
grad_max_freq=2.*pi./gamma./FOV_freq./delta_time_freq;     %gradient (read-out): T/m
grad_max_phase=2.*pi./gamma./FOV_phase./delta_time_phase;     %gradient (read-out): T/m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% spiral parameters
k_radius=n_freq./2;
alpha=0.5;

n_spiral=k_radius/4;
n_sample=round(4*k_radius*k_radius./n_spiral);
J=sqrt(n_sample/n_spiral)*(pi/4);

sample=[0:n_sample-1];

spiral_r=(sample./max(sample))./sqrt(alpha+(1-alpha)*(sample./max(sample))).*k_radius;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% spiral parameters


G_freq=repmat(grid_freq,[1 1 n_sample]);
G_phase=repmat(grid_phase,[1 1 n_sample]);



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

% FT1
%implemeting IFT part by time-domin reconstruction (TDR)
%get the sampling time k-space coordinate.
recon=zeros(n_phase,n_freq,size(Y,3));
for spiral_idx=1:n_spiral
    fprintf('*');
    theta=2*pi*J*(sample./max(sample))+2*pi./n_spiral.*(spiral_idx-1);

    D_freq=repmat((spiral_r.*cos(theta))',[1 n_phase n_freq]);
    D_freq=permute(D_freq,[2 3 1]);
    K_freq=exp(sqrt(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);

    D_phase=repmat((spiral_r.*sin(theta))',[1 n_phase n_freq]);
    D_phase=permute(D_phase,[2 3 1]);
    K_phase=exp(sqrt(-1).*gamma.*grad_max_phase.*delta_time_phase.*D_phase*FOV_phase./n_phase.*G_phase);

    for i=1:size(Y,3)
        X=repmat(transpose(Y(spiral_idx,:,i)),[1 n_phase n_freq]);
        X=permute(X,[2 3 1]);
        recon(:,:,i)=recon(:,:,i)+sum(X.*K_freq.*K_phase,3);
    end;
end;
fprintf('\n');

for i=1:size(Y,3)
    % S' (complex-conjugated sensitivity)
    temp(:,:,i)=recon(:,:,i).*conj(S(:,:,i));
end;
%intensity correction here
a=sum(temp,3).*I;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convergence=0;
iteration_idx=2;

if(isempty(X0))
    b(:,:,1)=zeros(n_phase,n_freq);
else
    b(:,:,1)=X0;
end;


p(:,:,1)=a;
r(:,:,1)=a;


if(isempty(epsilon))
    epsilon=sum(abs(Y(:)).^2)./50./size(Y,3);
    %epsilon=sum(abs(Y(:)).^2)./1000./size(Y,3);
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

%k-space indices for actual acquired data
k_idx=find(K<eps);

while(~convergence)
    if(flag_display)
        fprintf('PMRI recon. CG iteration=[%d]...',iteration_idx);
    end;

    dd=abs(r(:,:,iteration_idx-1)).^2;
    delta(iteration_idx)=sum(dd(:));


    if(sum(dd(:))<epsilon)
        convergence=1;
    else

        if(iteration_idx==2)
            p(:,:,iteration_idx)=r(:,:,1);
        else
            ww=sum(sum(abs(r(:,:,iteration_idx-1)).^2))/sum(sum(abs(r(:,:,iteration_idx-2)).^2));
            p(:,:,iteration_idx)=r(:,:,iteration_idx-1)+ww.*p(:,:,iteration_idx-1);
        end;

        %intensity correction here
        ss=p(:,:,iteration_idx).*I;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         E          %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        for i=1:size(Y,3)
            % S (sensitivity)
            temp(:,:,i)=ss.*S(:,:,i);
        end;

        % FT2
        %implemeting FT part by time-domin reconstruction (TDR)
        %get the sampling time k-space coordinate.
        Temp=[];
        for spiral_idx=1:n_spiral
            fprintf('#');
            theta=2*pi*J*(sample./max(sample))+2*pi./n_spiral.*(spiral_idx-1);

            D_freq=repmat((spiral_r.*cos(theta))',[1 n_phase n_freq]);
            D_freq=permute(D_freq,[2 3 1]);
            K_freq=exp(sqrt(-1).*(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);

            D_phase=repmat((spiral_r.*sin(theta))',[1 n_phase n_freq]);
            D_phase=permute(D_phase,[2 3 1]);
            K_phase=exp(sqrt(-1).*(-1).*gamma.*grad_max_phase.*delta_time_phase.*D_phase*FOV_phase./n_phase.*G_phase);

            for i=1:size(Y,3)
                X=repmat(temp(:,:,i),[1 1 n_sample]);
                Temp(spiral_idx,:,i)=squeeze(sum(sum(X.*K_freq.*K_phase,1),2));
            end;
        end;

        buffer=Temp;

        for i=1:size(Y,3)

            %K-space acceleration
            buffer0=buffer(:,:,i);
            buffer0(k_idx)=0;

            buffer(:,:,i)=buffer0;
        end;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         E'          %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % FT1
        %implemeting IFT part by time-domin reconstruction (TDR)
        %get the sampling time k-space coordinate.
        recon=zeros(n_phase,n_freq,size(Y,3));
        for spiral_idx=1:n_spiral
            fprintf('*');
            theta=2*pi*J*(sample./max(sample))+2*pi./n_spiral.*(spiral_idx-1);

            D_freq=repmat((spiral_r.*cos(theta))',[1 n_phase n_freq]);
            D_freq=permute(D_freq,[2 3 1]);
            K_freq=exp(sqrt(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);

            D_phase=repmat((spiral_r.*sin(theta))',[1 n_phase n_freq]);
            D_phase=permute(D_phase,[2 3 1]);
            K_phase=exp(sqrt(-1).*gamma.*grad_max_phase.*delta_time_phase.*D_phase*FOV_phase./n_phase.*G_phase);

            for i=1:size(Y,3)
                X=repmat(transpose(buffer(spiral_idx,:,i)),[1 n_phase n_freq]);
                X=permute(X,[2 3 1]);
                recon(:,:,i)=recon(:,:,i)+sum(X.*K_freq.*K_phase,3);
            end;
        end;

        % S' (complex-conjugated sensitivity)
        for i=1:size(Y,3)
            temp(:,:,i)=recon(:,:,i).*conj(S(:,:,i));
        end;

        %intensity correction here
        xx=sum(temp,3).*I;

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
    fprintf('\n');
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
