function [recon,b,delta]=pmri_core_cg3(varargin);
%
%	pmri_core_cg3		perform 3D SENSE reconstruction using conjugated gradient method
%
%
%	[recon,b,delta]=pmri_core_cg3('Y',Y,'S',S,'C',C,'K',K,'flag_display',1);
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
K_index=[];

P=[];

X0=[];



flag_display=0;

flag_reg=0;
flag_reg_g=0;

flag_unreg=1;
flag_unreg_g=0;

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
    case 'k_index'
        K_index=option_value;
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
% intensity correction

I=zeros(size(S,1),size(S,2),size(S,3));
for i=1:size(S,4)
    I=I+abs(S(:,:,:,i)).^2;
end;
I=1./sqrt(I);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:size(Y,4)
    
    %Density correction here
    % .... do nothing
    
    % FT1
    temp(:,:,:,i)=fftshift(fftn(fftshift(Y(:,:,:,i))));
    
    % S' (complex-conjugated sensitivity)
    temp(:,:,:,i)=temp(:,:,:,i).*conj(S(:,:,:,i));
end;
%intensity correction here
a=sum(temp,4).*I;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convergence=0;
iteration_idx=2;

if(isempty(X0))
	
	b(:,:,:,1)=zeros(size(Y,1),size(Y,2),size(Y,3));
else
	
	b(:,:,:,1)=X0;

end;


p(:,:,:,1)=a;
r(:,:,:,1)=a;


if(isempty(epsilon))
	
	epsilon=sum(abs(Y(:)).^2)./50./size(Y,3);
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
    
	dd=abs(r(:,:,:,iteration_idx-1)).^2;
	delta(iteration_idx)=sum(dd(:));

    
    
	if(dd<epsilon)
		convergence=1;
    	else
	
		if(iteration_idx==2)
    	    
			p(:,:,:,iteration_idx)=r(:,:,:,1);
		else
			ww=sum(sum(sum(abs(r(:,:,:,iteration_idx-1)).^2)))/sum(sum(sum(abs(r(:,:,:,iteration_idx-2)).^2)));


			p(:,:,:,iteration_idx)=r(:,:,:,iteration_idx-1)+ww.*p(:,:,:,iteration_idx-1);
		end;
		
		%intensity correction here
		ss=p(:,:,:,iteration_idx).*I;
		
		for i=1:size(Y,4)
			%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%         E          %%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%

			% S (sensitivity)
			temp(:,:,:,i)=ss.*S(:,:,:,i);
            
			% FT2
            temp(:,:,:,i)=fftshift(ifftn(fftshift(temp(:,:,:,i))));
            
			%K-space acceleration
			idx=find(abs(K(:,:,:,K_index(i)))<eps);

			%buffer0=zeros(size(temp(:,:,:,i)));

			%buffer1=zeros(size(temp(:,:,:,i)));
			buffer1=temp(:,:,:,i);
			%buffer1(idx)=buffer0(idx);
            buffer1(idx)=0;
            
			temp(:,:,:,i)=buffer1;
            
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%         E'          %%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
			%Density correction here

            
			% FT1
			temp(:,:,:,i)=fftshift(fftn(fftshift(temp(:,:,:,i))));
            
            
			% S' (complex-conjugated sensitivity)
			temp(:,:,:,i)=temp(:,:,:,i).*conj(S(:,:,:,i));
		end;

        
	
		%intensity correction here
		xx=sum(temp,4).*I;


	
        
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
		%%% CG starts
	
        
		q=xx;
		w=sum(sum(sum(abs(r(:,:,:,iteration_idx-1)).^2)))/sum(sum(sum(conj(p(:,:,:,iteration_idx)).*q)));

		b(:,:,:,iteration_idx)=b(:,:,:,iteration_idx-1)+p(:,:,:,iteration_idx).*w;
        
 
		r(:,:,:,iteration_idx)=r(:,:,:,iteration_idx-1)-q.*w;
        
	
		
		%%% CG ends        
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		if(flag_debug)
			subplot(131);
			fmri_mont(abs(b(:,:,:,iteration_idx).*I)); colormap(gray); axis off image; colorbar;

			subplot(132);
			fmri_mont(abs(r(:,:,:,iteration_idx))); colormap(gray); axis off image; colorbar;

			subplot(133);
			fmri_mont(abs(p(:,:,:,iteration_idx))); colormap(gray); axis off image; colorbar;

			keyboard;

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



b(:,:,:,1)=[];

delta(1)=[];



%intensity correction for all;

for i=1:size(b,4)
	
	b(:,:,:,i)=b(:,:,:,i).*I;

end;

recon=b(:,:,:,end);