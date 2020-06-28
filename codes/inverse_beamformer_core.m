function [inverse_out]=inverse_beamformer_core(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults
regularize_constant=0.01;  			% for noise matrix regularization i
flag_iop_stnorm=0;				% no spatial_temporal norm
iop_snorm=1;
iop_tnorm=2;
lambda=100;					% prior dependency


flag_noise_normalized_iop=0;	% no noise sensitivity normalization

nperdip=3;					% estimate all directional components

stnorm_error_total=[];
stnorm_error_likelihood=[];
stnorm_error_prior=[];
A=[];
R=[];
C=[];
D=[];
C_noise_norm=[];
Y=[];
X_init=[];
R_stnorm=[];
SSP=[];
%R_stnorm_weight=5;
R_stnorm_weight=1;

SNR_all=[];
SNR=inf;

SNR_lcurve=[];
SNR_all_lcurve=[];
SNR_gcv=[];
SNR_all_gcv=[];
SNR_white_estimate=[];
SNR_all_white_estimate=[];

eta=[];
rho=[];
gcv=[];
reg_param=[];
flag_snr_gcv=1;
flag_snr_lcurve=1;

flag_depth_correct=0;
depth_correct_order=1.0;

flag_estimate=0;

flag_focus=0;
focus_limit_convergence=0.01;
focus_limit_iteration=20;
X_focus={};
flag_focus_R_threshold=1;
focus_R_threshold_max=0.9;
focus_R_threshold_min=0.1;
flag_whiten=1;

process_id=1;


flag_display=0;

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
        case 'd'	%data covariance matrix
            D=option_value;
        case 'c_noise_norm'
            C_noise_norm=option_value;    %noise normalization covariance matrix; baseline covariance.
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
        case 'n_proj'
            n_proj=option_value;
        case 'ssp'
            SSP=option_value;
        case 'snr'	%SNR
            SNR=option_value;
            SNR_RMS=sqrt(SNR);
        case 'snr_rms'	%RMS SNR
            SNR_RMS=option_value;
            SNR=SNR_RMS*SNR_RMS;
        case 'process_id'
            process_id=option_value;
        case 'flag_depth_correct'
            flag_depth_correct=option_value;
        case 'depth_correct_order'
            depth_correct_order=option_value;
        case 'flag_iop_stnorm'
            flag_iop_stnorm=option_value;
        case 'flag_noise_normalized_iop'
            flag_noise_normalized_iop=option_value;
        case 'iop_snorm'
            iop_snorm=option_value;
        case 'iop_tnorm'
            iop_tnorm=option_value;
        case 'prior_dependency'
            lambda=option_value;
        case 'flag_focus'
            flag_focus=option_value;
        case 'flag_whiten'
            flag_whiten=option_value;
        case 'focus_limit_convergence'
            focus_limit_convergence=option_value;
        case 'focus_limit_iteration'
            focus_limit_iteration=option_value;
        case 'flag_focus_r_threshold'
            flag_focus_R_threshold=option_value;
        case 'focus_r_threshold_max'
            focus_R_threshold_max=option_value;
        case 'focus_r_threshold_min'
            focus_R_threshold_min=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option);
            return;
    end;
end;

if(flag_focus)
    flag_estimate=1;    %enforce diopole estimate

    focus_iteration=1;
    focus_convergence=Inf;
else
    focus_iteration=0;
    focus_convergence=0;
end;


W=zeros(size(A,2),size(A,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Depth correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if there is NO prior dipole information
if(isempty(R))
    R=ones(1,size(A,2));
end;

if(flag_depth_correct)
    fprintf('\n\n%d. DEPTH CORRECTION...\n',process_id);
    process_id=process_id+1;

    fprintf('automatic depth correction with order [%2.2f]...\n',depth_correct_order	);

    if(nperdip==1)
        ss=(1./sqrt(sum(A.^2,1))).^(depth_correct_order);
    elseif(nperdip==3)
        fprintf('nperdip=%d...\n',nperdip);
        ss=reshape(repmat((1./sqrt(sum(reshape(sum(A.^2,1),[nperdip,size(A,2)/nperdip]),1))).^(depth_correct_order),[nperdip,1]),[1,length(R)]);
    end;


    %%%%%%%%ss(find(ss>min(ss).*50))=min(ss).*50;

    %sss=sort(ss);
    %ss(find(ss>sss(round(length(sss)*0.95))))=sss(round(length(sss)*0.95));

    R=R.*ss;

end;

%Matrix_ARAt=(A.*repmat(R,[size(A,1),1]))*A';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Whitening
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_whiten)
    fprintf('\n\n%d. WHITENING...\n',process_id);
    process_id=process_id+1;

    C0=C;
    [uu_C,ss_C,vv_C]=svd(C);

    rank_C=rank(C);

    if(size(C,1)-n_proj>rank_C)
        fprintf('warning!! noise variance covariance is rank deficient even including [%d] projection component!\n',n_proj);
        fprintf('automatic fixing the projection components from [%d] to [%d]!\n',n_proj,size(C,1)-rank_C);
        n_proj=size(C,1)-rank_C;
    end;

    %fixing the noise covariance preparation for whitening
    if(n_proj>0)
        tmp=diag(ss_C);
        tmp(end-n_proj:end)=inf;
        ss_C=tmp;
    end;
    A=sqrt(diag(1./(ss_C)))*vv_C'*A;
    D=sqrt(diag(1./(ss_C)))*vv_C'*D*vv_C*sqrt(diag(1./(ss_C)));
    C=eye(size(C));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Get regularization adjustment
%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n%d. GET REGULARIZATION ADJ...\n',process_id);
process_id=process_id+1;

noise_power=trace(C)./size(C,1); % get the power of noise
signal_power=trace(D)./size(D,1); % get the power of noise


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Estimation of SNR using regularization
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(isempty(SNR))
    if(flag_display) fprintf('\n\n%d. ESTIMATION OF SNR USING REGULARIZATION...\n',process_id);
    end;
    process_id=process_id+1;

    if(isempty(C)|isempty(A)|isempty(R)|isempty(Y))
        if(flag_display) fprintf('matrices [A], [R], [C], [Y] must not be empty for SNR estimation!');
        end;
        SNR=nan;
    else
        [SNR_lcurve, SNR_all_lcurve, SNR_gcv, SNR_all_gcv, SNR_white_estimate, SNR_all_white_estimate,eta,rho,gcv,reg_param]=inverse_snr_estimate(A,C,R,Y,'flag_lcurve',flag_snr_lcurve,'flag_gcv',flag_snr_gcv);

        if(~isempty(SNR_lcurve))
            if(flag_display) fprintf('\nEstimated SNR (L-curve)=[%3.3f]\n\n',SNR_lcurve);
            end;
            SNR=SNR_lcurve;
        end;
        if(~isempty(SNR_gcv))
            if(flag_display) fprintf('\nEstimated SNR (GCV)=[%3.3f]\n\n',SNR_gcv); end;
            SNR=SNR_gcv;
        end;
        if(~isempty(SNR_white_estimate))
            if(flag_display) fprintf('\nEstimated SNR (whitened Y)=[%3.3f]\n\n',SNR_white_estimate); end;
            SNR=SNR_white_estimate;
        end;

    end;
else
    if(flag_display) fprintf('\nSNR is predifined as [%3.3f]...\n\n',SNR);
    end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	SNR ADJUSTMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n\n%d. SNR ADJUSTMENT...\n',process_id);
process_id=process_id+1;

if(SNR>0)
    if(~isinf(SNR))
        fprintf('Adjusting noise covariance matrix based on given SNR...\n');

        lambda=signal_power/(noise_power.*SNR);

        %C=C.*lambda;	%scale the noise matrix of specified SNR
        %Matrix_ARAt=Matrix_ARAt./lambda;

    else
        C=zeros(size(C));
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Inverse the sum of signal matrix (ARA') and noise matrix (C)
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(flag_display) fprintf('\n\n%d. INVERSION FOR INVERSE OPERATOR...\n',process_id);
end;
process_id=process_id+1;

if(isempty(D))

else
	Matrix_SN=(D+lambda.*C);
	Matrix_SN_inv=inv(Matrix_SN);
end;


for ii=1:round(size(A,2)/nperdip)

    %fprintf('[%d|%d]...',ii,round(size(A,2)/nperdip));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Get the beamformer inverse operator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    if(flag_display) fprintf('\n\n%d. FINALIZE BEAMFORMER INVERSE OPERATOR...\n',process_id);
    end;
    process_id=process_id+1;

    W((ii-1)*nperdip+1:ii*nperdip,:)=inv(A(:,(ii-1)*nperdip+1:ii*nperdip)'*Matrix_SN_inv*A(:,(ii-1)*nperdip+1:ii*nperdip))*A(:,(ii-1)*nperdip+1:ii*nperdip)'*Matrix_SN_inv;
    %W((ii-1)*nperdip+1:ii*nperdip,:)=A(:,(ii-1)*nperdip+1:ii*nperdip)'*Matrix_SN_inv;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Noise sensitivy normalized IOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(flag_display) fprintf('\n\n%d. NOISE SENSITIVITY NORMALIZED IOP...\n',process_id); end;
process_id=process_id+1;

if(flag_noise_normalized_iop)
    if(isempty(C_noise_norm))
        if(flag_display) fprintf('using [C] as noise normalization factor...\n'); end;
        C_noise_norm=C;
    else
        if(flag_display) fprintf('user-defined [C_noise_norm] as noise normalization factor...\n'); end;
    end;
    mm=C_noise_norm*W';

    for i=1:size(W,1)
        nd(i)=W(i,:)*mm(:,i);
    end;
    ndt=sqrt(nd)';
    ND=repmat(ndt,[1,size(W,2)]);
    idx1=find(ND~=0);
    idx0=find(ND==0);
    W(idx1)=W(idx1)./ND(idx1);
    W(idx0)=0.0;

else
    if(flag_display) fprintf('SKIP NOISE SENSITIVITY NORMALIZATION!\n'); end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Dipole estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display) fprintf('\n\n%d. DIPOLE ESTIMATE ...\n',process_id);
end;
process_id=process_id+1;

if(flag_estimate)
    if(~isempty(Y))
        if(flag_display) fprintf('estimating...\n');
        end;
        X=W*Y;
    else
        X=[];
        if(flag_display) fprintf('No measurement data!\n');
        end;
        if(flag_display) fprintf('skip dipole estimation!\n');
        end;
    end;
else
    X=[];
    if(flag_display) fprintf('SKIP DIPOLE ESTIMATION!\n');
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inverse_out{1}=W;
output_count=1;
fprintf('output[%d]--> inverse operator\n',output_count);

