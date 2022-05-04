function [recon,b,delta]=pmri_core_cgp(varargin);
%
%	pmri_core_cgp		perform SENSE reconstruction using conjugated gradient method with prior
%
%
%	[recon,b,delta]=pmri_core_cgp('Y',Y,'S',S,'C',C,'K',K,'P',P,'flag_display',1);
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
%	P: 2D prior image [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
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
P=[];
X0=[];


flag_display=0;

flag_reg=0;
flag_reg_g=0;

flag_unreg=1;
flag_unreg_g=0;

flag_debug=0;
flag_display=0;

iteration_max=[];
epsilon=[];

lambda=[];
SNR=[];

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
    case 'x0'
        X0=option_value;
    case 'lambda'
    	lambda=option_value;
    case 'snr'
    	SNR=option_value;
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
    case 'iteration_max'
    	iteration_max=option_value;
    case 'epsilon'
    	epsilon=option_value;
    case 'flag_debug'
	    flag_debug=option_value;
    case 'flag_display'
        flag_display=option_value;
    otherwise
        fprintf('unknown option [%s]!\n',option);
        fprintf('error!\n');
        return;
    end;
end;

if(isempty(lambda))
    if(~isempty(SNR))
        lambda=1/SNR;
    else
        lambda=0;
    end;
end;

if(isempty(P))
    P=zeros(size(S,1),size(S,2));
end;
    
idx=find(abs(S)<eps);
S(idx)=eps;

if(sum(Y)==0)
    recon=zeros(size(P));
    b=zeros(size(recon));
    delta=0;
    return;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intensity correction

I=zeros(size(S,1),size(S,2));
for i=1:size(S,3)
    I=I+abs(S(:,:,i)).^2;
end;

if(sum(I)==0)
    recon=zeros(size(I));
    b=zeros(size(recon));
    delta=0;
    return;
end;

I=1./sqrt(I);
I=ones(size(I));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% adjust  measurement (Y) for prior %%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         E          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
P_tmp=P.*I./sqrt(size(S,1).*size(S,2));
for i=1:size(Y,3)
	% S (sensitivity)
	temp(:,:,i)=P_tmp.*S(:,:,i);

	% FT2
       	temp(:,:,i)=fftshift(ifft2(fftshift(temp(:,:,i)))).*sqrt(size(S,1).*size(S,2));

	%K-space acceleration
	idx=find(K);

	buffer0=zeros(size(temp(:,:,i)));
	buffer1=zeros(size(temp(:,:,i)));
	buffer0=temp(:,:,i);
	buffer1(idx)=buffer0(idx);

	temp(:,:,i)=buffer1;
end;
a=Y-temp; %Y-A*X0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convergence=0;
iteration_idx=1;

if(isempty(X0))
	b(:,:,1)=zeros(size(Y,1),size(Y,2));
else
	b(:,:,1)=X0;
end;

dd=inf;

if(isempty(epsilon))
	epsilon=sum(abs(a(:)).^2)./50./size(Y,3);
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
	    fprintf('PMRI recon. CG iteration=[%d]...\r',iteration_idx);
    end;
    
	if(dd<epsilon)
		convergence=1;
	else

		if(iteration_idx==1)
	
			z=a;
                
			%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%         E'          %%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%
			for i=1:size(Y,3)
				%Density correction here
				% .... do nothing
    
				% FT1
				temp(:,:,i)=fftshift(fft2(fftshift(z(:,:,i,1))))./sqrt(size(S,1).*size(S,2));
    
				% S' (complex-conjugated sensitivity)
				temp(:,:,i)=temp(:,:,i).*conj(S(:,:,i));
			end;
			
			%intensity correction here
			r(:,:,1)=sum(temp,3).*I;    %r=A'*z;
                
			p(:,:,1)=r(:,:,1);
			b(:,:,1)=zeros(size(Y,1),size(Y,2));
			phi(1)=sum(abs(r(:).^2));

		end;

		%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%         E          %%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%

		P_tmp=p(:,:,iteration_idx).*I;
		for i=1:size(Y,3)
			% S (sensitivity)
			temp(:,:,i)=P_tmp.*S(:,:,i);

			% FT2
			temp(:,:,i)=fftshift(ifft2(fftshift(temp(:,:,i)))).*sqrt(size(S,1).*size(S,2));

			%K-space acceleration
			idx=find(K);

			buffer0=zeros(size(temp(:,:,i)));
			buffer1=zeros(size(temp(:,:,i)));
			buffer0=temp(:,:,i);
			buffer1(idx)=buffer0(idx);

			temp(:,:,i)=buffer1;
		end;
		c=temp;  %c(:,j)=A*p(:,j);

        c_power=sum(abs(c(:)).^2);
		p_tmp=p(:,:,iteration_idx);
		p_power=sum(abs(p_tmp(:)).^2);

		alpha(iteration_idx)=phi(iteration_idx)/(c_power+lambda*p_power);

		b(:,:,iteration_idx+1)=b(:,:,iteration_idx)+alpha(iteration_idx).*p(:,:,iteration_idx);
		z=z-alpha(iteration_idx).*c;

		%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%         E'          %%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%
		for i=1:size(Y,3)
			%Density correction here
			% .... do nothing

			% FT1
			temp(:,:,i)=fftshift(fft2(fftshift(z(:,:,i))))./sqrt(size(S,1).*size(S,2));
	
			% S' (complex-conjugated sensitivity)
			temp(:,:,i)=temp(:,:,i).*conj(S(:,:,i));
		end;
		%intensity correction here
		r(:,:,iteration_idx+1)=sum(temp,3).*I-lambda.*b(:,:,iteration_idx+1);    % r(:,iteration_idx+1)=A'*z-lambda.*x(:,iteration_idx+1);
		%r(:,:,iteration_idx+1)=sum(temp,3).*I;    % r(:,iteration_idx+1)=A'*z-lambda.*x(:,iteration_idx+1);
  
		dd=abs(r(:,:,iteration_idx)).^2;
		delta(iteration_idx)=sum(dd(:));

		r_tmp=r(:,:,iteration_idx+1);
		phi(iteration_idx+1)=sum(abs(r_tmp(:)).^2);
		beta(iteration_idx)=phi(iteration_idx+1)./phi(iteration_idx);
		p(:,:,iteration_idx+1)=r(:,:,iteration_idx+1)+beta(iteration_idx).*p(:,:,iteration_idx);        

		if(flag_debug)
			subplot(131);
			imagesc(abs(b(:,:,iteration_idx).*I)); colormap(gray); axis off image; colorbar;

			subplot(132);
			imagesc(abs(r(:,:,iteration_idx))); colormap(gray); axis off image; colorbar;

			subplot(133);
			imagesc(abs(p(:,:,iteration_idx))); colormap(gray); axis off image; colorbar;

			pause(0.3);
		end;
		
		iteration_idx=iteration_idx+1;
		
		if(iteration_idx > iteration_max)
			convergence=1;
		end;
	end;
end;

if(flag_display)
    fprintf('\n');
end;



%finalize output
b(:,:,1)=[];

delta(1)=[];

%intensity correction for all;

for i=1:size(b,3)
	b(:,:,i)=b(:,:,i).*I.*sqrt(size(S,1).*size(S,2))+P;
end;

recon=b(:,:,end);

