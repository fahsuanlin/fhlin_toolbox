function [varargout]=inverse_core(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults
regularize_constant=0.01;  			% for noise matrix regularization i
flag_iop_stnorm=0;				% no spatial_temporal norm
iop_snorm=1;
iop_tnorm=2;
lambda=100;					% prior dependency
flag_noise_normalized_iop=0;			% no noise sensitivity normalization
nperdip=3;					% estimate all directional components

stnorm_error_total=[];
stnorm_error_likelihood=[];
stnorm_error_prior=[];
A=[];
R=[];
C=[];
Y=[];
X_init=[];
R_stnorm=[];
R_stnorm_weight=5;
%R_stnorm_weight=10^2;
SNR=inf;

%output arguments
W_mn=[];
W_stnorm=[];
W_noise_sense=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read-in parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'a' 	%forward matrix
		A=option_value;
	case 'r'	%source covariance matrix
		R=option_value;
	case 'c'	%noise covariance matrix
		C=option_value;
	case 'y'	%measurement data
		Y=option_value;
	case 'nperdip'
		nperdip=option_value;
    case 'x_init'
        X_init=option_value;
    case 'r_stnorm'
        R_stnorm=option_value;
    case 'r_stnorm_weight'
        R_stnorm_weight=option_value;
    case 'snr'	%SNR
		SNR=option_value;	
		SNR_RMS=sqrt(SNR);
	case 'snr_rms'	%RMS SNR
		SNR_RMS=option_value;	
		SNR=SNR_RMS*SNR_RMS;
	case 'process_id'
		process_id=option_value;
	case 'flag_iop_stnorm'
		flag_iop_stnorm=option_value;
	case 'iop_snorm'
		iop_snorm=option_value;
	case 'iop_tnorm'
		iop_tnorm=option_value;
	case 'prior_dependency'
		lambda=option_value;
	otherwise
		fprintf('unknown option [%s]\n',option);
		return;
	end;
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Get partial product : A*R*A'
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. GET PARTIAL INVERSE OPERATOR (A*R*At)...\n',process_id);
process_id=process_id+1;

% if there is NO prior dipole information
if(isempty(R))
	R=ones(1,size(A,2));
end;

Matrix_ARAt=(A.*repmat(R,[size(A,1),1]))*A';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Estimation of SNR using regularization
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(isempty(SNR))
    fprintf('\n\n%d. ESTIMATION OF SNR USING REGULARIZATION...\n',process_id);
    process_id=process_id+1;
    
    if(isempty(C)|isempty(A)|isempty(R)|isempty(Y))
        fprintf('matrices [A], [R], [C], [Y] must not be empty for SNR estimation!');
        SNR=nan;
    else
        [SNR, SNR_all]=inverse_snr_estimate(A,C,R,Y);
        fprintf('\nEstimated SNR=[%3.3f]\n\n',SNR);
    end;
else
    fprintf('\nSNR is predifined as [%3.3f]...\n\n',SNR);
end;


%save reg SNR SNR_all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Regularize the noise covariance
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. NOISE COVARIANCE MATRIX REGULARIZATION...\n',process_id);
process_id=process_id+1;

if(~isempty(C))
	%regularize the noise matrix
	fprintf('Regularizing noise covariance matrix...\n');
	C=inverse_regularize_matrix(C,regularize_constant);

else
	C=zeros(size(A,1),size(A,1));
	fprintf('Empty noise covariance matrix!\n');
	
end;



if(SNR>0)
	if(~isinf(SNR))
		fprintf('Adjusting noise covariance matrix based on given SNR...\n');

	
		noise_power=trace(C)./size(C,1); % get the power of noise
	
		signal_power=trace(Matrix_ARAt)./size(Matrix_ARAt,1); % get the power of noise
	
		C=C.*(signal_power/(noise_power*SNR));	%scale the noise matrix of specified SNR
	else
		C=zeros(size(C));
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Inverse the sum of signal matrix (ARA') and noise matrix (C)
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. INVERSION FOR INVERSE OPERATOR...\n',process_id);
process_id=process_id+1;

mm=Matrix_ARAt+C;



Matrix_SN=(Matrix_ARAt+C);
Matrix_SN_inv=inv(Matrix_SN);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Get the minimum L-2 norm inverse operator
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. FINALIZE MIN-NORM INVERSE OPERATOR...\n',process_id);
process_id=process_id+1;

W=A'*Matrix_SN_inv;

for i=1:size(W,2)
	W(:,i)=W(:,i).*R';
end;
W_mn=W;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Spatio-temporal norm IOP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. MODIFY IOP FOR SPATIOTEMPORAL NORM...\n',process_id);
process_id=process_id+1;


if(flag_iop_stnorm)

	if(~isempty(Y))
		%[W]=inverse_stnorm(W,A,Y,'p_s',1,'p_t',2,'iteration',10,'lambda',1/SNR);
		fprintf('spatial norm=[%2.2f]\n',iop_snorm);
		fprintf('temporal norm=[%2.2f]\n',iop_tnorm);
		fprintf('prior dependency=[%2.2f]\n',lambda);
		
		if(~isempty(X_init))
            idx=find(sum(X_init.^2,2)==0);
			W(idx,:)=W(idx,:).*0.5;
		end;
        
        if(~isempty(R_stnorm))
            RR=zeros(size(R_stnorm));
            idx=find(R_stnorm==0);
            RR(idx)=1/R_stnorm_weight;
            idx=find(R_stnorm~=0);
            RR(idx)=R_stnorm_weight;
            R_stnorm=RR;
		end;
        
        
       
		[W,stnorm_error_total,stnorm_error_likelihood,stnorm_error_prior]=inverse_stnorm(W,A,Y,'p_s',iop_snorm,'p_t',iop_tnorm,'iteration',10,'lambda',lambda,'nperdip',nperdip,'F',R_stnorm);
		W_stnorm=W;
	else
		fprintf('Empty measurement matrix Y!!\n');
		fprintf('skip spatiotemporal norm!!\n');
	end;
else

	fprintf('SKIP SPATIOTEMPORAL NORM IOP!\n');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Noise sensitivy normalized IOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. NOISE SENSITIVITY NORMALIZED IOP...\n',process_id);
process_id=process_id+1;

if(flag_noise_normalized_iop)
	mm=C*W';
	
	for i=1:size(W,1)
		nd(i)=W(i,:)*mm(:,i);
	end;
	nd=sqrt(nd)';
	ND=repmat(nd,[1,size(W,2)]);
	W=W./ND;

%	ND=diag(1./diag(sqrt(W*C*W')));
%	W=ND*W;
else
	fprintf('SKIP NOISE SENSITIVITY NORMALIZATION!\n');
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varargout{1}=W;
output_count=1;
fprintf('output[%d]--> inverse operator\n',output_count);
if(~isempty(W_mn))
	output_count=output_count+1;
	varargout{output_count}=W_mn;
	fprintf('output[%d]--> min. L2 norm inverse operator\n',output_count);
end;
if(~isempty(W_stnorm))
	output_count=output_count+1;
	varargout{output_count}=W_stnorm;
	fprintf('output[%d]--> parsimonious spatiotemporal norm inverse operator\n',output_count);
end;
if(~isempty(stnorm_error_total))
	output_count=output_count+1;
	varargout{output_count}=stnorm_error_total;
	fprintf('output[%d]--> parsimonious spatiotemporal norm constraint total cost\n',output_count);
end;
if(~isempty(stnorm_error_likelihood))
	output_count=output_count+1;
	varargout{output_count}=stnorm_error_likelihood;
	fprintf('output[%d]--> parsimonious spatiotemporal norm constraint likelihood cost\n',output_count);
end;
if(~isempty(stnorm_error_prior))
	output_count=output_count+1;
	varargout{output_count}=stnorm_error_prior;
	fprintf('output[%d]--> parsimonious spatiotemporal norm constraint prior cost\n',output_count);
end;


