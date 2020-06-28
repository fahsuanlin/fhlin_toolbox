function [recon,delta]=pmri_core_cg_spec(varargin);
%
%	pmri_core_cg		perform SENSE reconstruction using conjugated gradient method
%
%
%	[recon,delta]=pmri_core_cg_spec('Y',Y,'S',S,'C',C,'K',K,'flag_display',1);
%
%	INPUT:
%	Y: input data of [n_PE, n_FE, n_time, n_chan]. 
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_time: # of spectral samples
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
%	B0: BO maps of [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	recon: 3D un-regularized SENSE reconstruction [n_PE, n_PE, n_time].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%		n_time: # of spectral samples
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

B0=[];

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
    case 'x0'
        X0=option_value;
    case 'bo'
        B0=option_value;
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

n_time=size(Y,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intensity correction

I=zeros(size(S,1),size(S,2));
for i=1:size(S,3)
    I=I+abs(S(:,:,i)).^2;
end;
I=1./sqrt(I);

I=repmat(I,[1 1 n_time]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:size(Y,4)
    
    %Density correction here
    % .... do nothing
    
    % FT1
    temp(:,:,:,i)=fftshift(fft(fftshift(fftshift(fft(fftshift(Y(:,:,:,i),1),[],1),1),2),[],2),2);
    
    % S' (complex-conjugated sensitivity)
    temp(:,:,:,i)=temp(:,:,:,i).*repmat(conj(S(:,:,i)),[1 1 n_time]);
end;
%intensity correction here
a=sum(temp,4);

a=a.*I;

if(~isempty(B0))
    tt=repmat(permute([0:1./bandwidth:(n_time-1)./bandwidth],[3 4 2]),[size(B0,1),size(B0,2),1]);
    a=a.*exp(sqrt(-1).*2.*pi.*B0.*tt);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convergence=0;
iteration_idx=2;

if(isempty(X0))
	
	%b(:,:,:,1)=zeros(size(Y,1),size(Y,2),size(Y,3));
    b_now=zeros(size(Y,1),size(Y,2),size(Y,3));
else
	
	%b(:,:,:,1)=X0;
    b_now=X0;
end;


%p(:,:,:,1)=a;
p_now=a;

%r(:,:,:,1)=a;
r_now=a;
r_pre=a;

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
    
	dd=abs(r_pre).^2;
	delta(iteration_idx)=sum(dd(:));

    
    
	if(delta(iteration_idx)<epsilon)
		convergence=1;
    	else
	
		if(iteration_idx==2)
			%p(:,:,:,iteration_idx)=r(:,:,:,1);
            p_pre=p_now;
            p_now=r_pre;
		else
			%ww=sum(sum(sum(abs(r(:,:,:,iteration_idx-1)).^2)))/sum(sum(sum(abs(r(:,:,:,iteration_idx-2)).^2)));
            ww=sum(sum(sum(abs(r_now).^2)))/sum(sum(sum(abs(r_pre).^2)));

            %p(:,:,:,iteration_idx)=r(:,:,:,iteration_idx-1)+ww.*p(:,:,:,iteration_idx-1);
            p_pre=p_now;
            p_now=r_now+ww.*p_pre;
		end;
        
		%intensity correction here
		%ss=p(:,:,:,iteration_idx);
		ss=p_now;
        
        ss=ss.*I;
        
        if(~isempty(B0))
            tt=repmat(permute([0:1./bandwidth:(n_time-1)./bandwidth],[3 4 2]),[size(B0,1),size(B0,2),1]);
            ss=ss.*exp(-1.*sqrt(-1).*2.*pi.*B0.*tt);
        end;

        
		for i=1:size(Y,4)
			%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%         E          %%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%

			% S (sensitivity)
			temp(:,:,:,i)=ss.*repmat(S(:,:,i),[1 1 n_time]);
            
			% FT2
            temp(:,:,:,i)=fftshift(ifft(fftshift(fftshift(ifft(fftshift(temp(:,:,:,i),1),[],1),1),2),[],2),2);
            
			%K-space acceleration
			idx=find(repmat(K,[1 1 n_time]));

			buffer1=temp(:,:,:,i);
            K_comp=repmat(ones(size(K))-K,[1,1,n_time]);
			buffer1(find(K_comp))=0;

			temp(:,:,:,i)=buffer1;
            
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%         E'          %%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
			%Density correction here

			% FT1
            temp(:,:,:,i)=fftshift(fft(fftshift(fftshift(fft(fftshift(temp(:,:,:,i),1),[],1),1),2),[],2),2);
            
			% S' (complex-conjugated sensitivity)
			temp(:,:,:,i)=temp(:,:,:,i).*repmat(conj(S(:,:,i)),[1 1 n_time]);
		end;

		%intensity correction here
		xx=sum(temp,4);
        
        if(~isempty(B0))
            tt=repmat(permute([0:1./bandwidth:(n_time-1)./bandwidth],[3 4 2]),[size(B0,1),size(B0,2),1]);
            xx=xx.*exp(-1.*sqrt(-1).*2.*pi.*B0.*tt);
        end;

        xx=xx.*I;

        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%% CG starts
        
		q=xx;
		
        %w=sum(sum(sum(abs(r(:,:,:,iteration_idx-1)).^2)))/sum(sum(sum(conj(p(:,:,:,iteration_idx)).*q)));
        w=sum(sum(sum(abs(r_now).^2)))/sum(sum(sum(conj(p_now).*q)));

		%b(:,:,:,iteration_idx)=b(:,:,:,iteration_idx-1)+p(:,:,:,iteration_idx).*w;
        b_pre=b_now;
        b_now=b_pre+p_now.*w;
        
		%r(:,:,:,iteration_idx)=r(:,:,:,iteration_idx-1)-q.*w;
        r_prepre=r_pre;
        r_pre=r_now;
        r_now=r_pre-q.*w;
		%%% CG ends        
	
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		if(flag_debug)
			subplot(131);
			imagesc(abs(b_now.*I)); colormap(gray); axis off image; colorbar;

			subplot(132);
			imagesc(abs(r_now)); colormap(gray); axis off image; colorbar;

			subplot(133);
			imagesc(abs(p_now)); colormap(gray); axis off image; colorbar;

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



%b(:,:,:,1)=[];

delta(1)=[];



%intensity correction for all;

b_now=b_now.*I;


recon=b_now;