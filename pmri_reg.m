function [lambda, reg_param,s_prime,s_least,reg_time,snr,snr_spectrum]=pmri_reg(varargin);
%
%	pmri_reg		estimate regularization parameter for SENSE reconstruction
%
%				one regularization parameter will be estimated for each frequency-encoded line.
%
%	[lambda, reg_param,s_prime,s_least,reg_time]=pmri_reg('A',A,'Y',Y,'S',S,'C',C,'P',P,'flag_reg_lcurve',1);
%
%	INPUT:
%	Y: input data of [n_PE, n_FE, n_chan]. 
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	A: 2D fourier aliasing matrix of [n_PE_acc, n_PE].
%		n_PE_acc: # of accelerated phase encoding steps
%		n_PE: # of phase encoding steps before acceleration
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	C: noise covariance matrix of [n_chan, n_chan].
%		n_chan: # of channel
%	P: prior of [n_PE, n_FE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	'flag_reg_lcurve': value of either 0 or 1
%		using L-curve to estimate regularization parameter
%	'flag_reg_gcv': value of either 0 or 1
%		using generalized cross-validation (GCV) to estimate regularization parameter
%	'flag_reg_snr': value of either 0 or 1
%		using estimated SNR to estimate regularization parameter
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%	
%
%	OUTPUT:
%	lambda: regularization parameters
%	reg_param: the searching range for the regularization parameter.
%	s_prime: the first singular value of the encoding matrix
%	s_least: the last singular value of the encoding matrix
%	reg_time: total time (in seconds) for regularization parameter estimation
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

sig2=[];

reg_param=[];

s_prime=[];

s_least=[];

reg_time=[];

sample_vector=[];

flag_display=0;

flag_reg_lcurve=1;
flag_reg_snr=0;
flag_reg_gcv=0;
flag_reg_psv=0;

snr=[];
snr_spectrum=[];

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
    case 'obs'
        obs=option_value;
    case 'ref'
        ref=option_value;
    case 'a'
        A=option_value;
    case 's'
        S=option_value;
    case 'c'
        C=option_value;
    case 'p'
        P=option_value;
    case 'y'
        Y=option_value;
    case 'sig2'
    	sig2=option_value;
    case 'flag_display'
	flag_display=option_value;
    case 'reg_lambda'
        reg_lambda=option_value;
    case 'flag_reg_lcurve'
	flag_reg_lcurve=option_value;
    case 'flag_reg_snr'
	flag_reg_snr=option_value;
    case 'flag_reg_gcv'
	flag_reg_gcv=option_value;
    case 'flag_reg_psv'
	flag_reg_psv=option_value;
    case 'recon_channel_weight'
	recon_channel_weight=option_value;
    otherwise
        fprintf('unknown option [%s]!\n',option);
        fprintf('error!\n');
        return;
    end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	preparation of noise covariance and whitening matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isempty(C))
	if(isempty(Y))	%no data
		fprintf('no data to build noise covariance matrix model!\nerror!\n');
		return;
	else
		%C=eye(size(Y,3));
		tmp=zeros(size(Y,1),size(Y,2));
		for i=1:size(Y,3)
			tmp=tmp+abs(Y(:,:,i).^2);
			tmp2=Y(:,:,i);
			yy(:,i)=tmp2(:);
		end;
		tmp=sqrt(tmp./size(Y,3));
		
		noise_idx=find(tmp<mean(tmp(:))/10);
		C=diag(diag(cov(yy(noise_idx,:))));
	end;
end;
%prepare whitening data
C=C./size(A,2).*size(A,1);
[u,s,v]=svd(C);
W_y=pinv(sqrt(s))*u';	%whitening matrix


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	preparation of noise covariance for SNR regularization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ss=repmat(transpose(diag(C)),[size(Y,1),1]);
%N=diag(ss(:));
%[u_n,s_n,v_n]=svd(N);		
%power_noise=trace(N);
%W_n=sqrt(pinv(s_n))*u_n';
	
if(flag_display) 
	fprintf('estimated noise power level = %2.2e [%d samples]\n',sig2,(length(sig2_all))); 
end;		

n_coil=size(Y,3);
Y=permute(Y,[1 3 2]);
S=permute(S,[1 3 2]);

tic;
for fe_idx=1:size(Y,3)
	if(flag_display)
		fprintf('.');
	end;
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	preparation of observation data
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Y_w=Y(:,:,fe_idx)*W_y';
	
	Z=[];	
	for i=1:n_coil
		Z=cat(1,Z,Y_w(:,i));
	end;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	preparation of encoding matrix
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	S_w=S(:,:,fe_idx)*W_y';
	
	E=[];
	for i=1:n_coil
		E=cat(1,E,A.*(ones(size(A,1),1)*transpose(S_w(:,i))));	
	end;
	
	if(flag_reg_lcurve)
        %SVD on encoding matrix
	    [u,s,v]=svd(E,0);
				
	    s=diag(s);
	    s_prime(fe_idx)=max(s);
	    s_least(fe_idx)=min(s);

		fprintf('L-curve regularization [%d|%d]\r',fe_idx,size(Y,3));
		if(isempty(find(s)))
			lambda(fe_idx)=0.0;
		else
			xx=max(find((s)));
			u=u(:,1:xx);
			s=s(1:xx);
			v=v(:,1:xx);

			if(isempty(find(Z)))
				lambda(fe_idx)=0.0;
			else
				[lambda(fe_idx),reg_lcurve_rho(:,fe_idx),reg_lcurve_eta(:,fe_idx),reg_param(:,fe_idx)]=inverse_lcurve(u,s,Z,'prior',P(:,fe_idx),'V',v);
			end;
		end;
 	end;
 	
	
	if(flag_reg_gcv)
		fprintf('GCV regularization [%d|%d]\r',fe_idx,size(Y,3));
        %SVD on encoding matrix
	    [u,s,v]=svd(E,0);

        s=diag(s);
	    s_prime(fe_idx)=max(s);
	    s_least(fe_idx)=min(s);

		if(isempty(find(s)))
			lambda(fe_idx)=0.0;
		else
			if(isempty(find(Z)))
				lambda(fe_idx)=0.0;
			else
				[lambda(fe_idx),reg_param(:,fe_idx)]=gcv(u,s,Z,'tikh');
			end;
		end;
	end;
    
	if(flag_reg_snr)
		fprintf('SNR regularization [%d|%d]\r',fe_idx,size(Y,3));
		
		%SVD on encoding matrix
		[v1,s2,v2]=svd(E'*E);
				
		s=sqrt(diag(s2));
        %s=s-min(s);
        
		power_signal=sum(s.^2);
		mm=Z;

        %this is using peak SNR for regularization parameter estimation
		snr(fe_idx)=max(abs(mm).^2);		
        %this is using average SNR for regularization parameter estimation
        %snr(fe_idx)=mean2(abs(Y_w).^2);

		if(isempty(find(s)))
			lambda(fe_idx)=0.0;
		else
			cs2=cumsum(s.^2);
			tidx=max(find((cs2(end)-cs2(1:end-1))>0));
			snr_spectrum(1:tidx,fe_idx)=cs2(1:tidx)./(cs2(end)-cs2(1:tidx));
            if(tidx<size(Y,3))
    			snr_spectrum(tidx+1:size(Y,3)-1,fe_idx)=inf;
            end;

			idx=min(find(snr_spectrum(:,fe_idx)>snr(fe_idx)));
			idx=idx;
			if(isempty(idx))
				idx=length(s);
			end;
			if(idx>length(s))
				idx=length(s);
			elseif(idx<1)
				idx=1;
			end;
            %if(fe_idx==25) keyboard; end;
            %plot(s); input('');
            
			lambda(fe_idx)=s(idx);
		end;
		
	end;
	
	if(flag_reg_psv)
		fprintf('Principal singular value [%d|%d]\r',fe_idx,size(Y,3));
        %SVD on encoding matrix
	    [u,s,v]=svd(E,0);
				
	    s=diag(s);
	    s_prime(fe_idx)=max(s);
	    s_least(fe_idx)=min(s);

        
		if(isempty(find(s)))
			lambda(fe_idx)=0.0;
		else
			lambda(fe_idx)=s(1);
		end;
	end;
end;
fprintf('\n');
reg_time=toc;


if(flag_display)
	fprintf('SENSE regularization parameter estimation : %2.2f (s)\n',reg_time);
	fprintf('DONE!\n');
end;


