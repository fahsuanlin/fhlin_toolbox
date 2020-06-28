function [inverse_out]=inverse_core(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults
regularize_constant=0.01;  			% for noise matrix regularization i
flag_iop_stnorm=0;				% no spatial_temporal norm
iop_snorm=1;
iop_tnorm=2;
lambda=100;					% prior dependency


flag_noise_normalized_iop=0;	% no noise sensitivity normalization
flag_noise_normalized_sloreta=0;	%use sLORETA for noise noromalization

nperdip=3;					% estimate all directional components

stnorm_error_total=[];
stnorm_error_likelihood=[];
stnorm_error_prior=[];
A=[];
R=[];
R0=[];
SSP=[];
C=[];
C_noise_norm=[];
Y=[];
X_init=[];
R_stnorm=[];
R_stnorm_weight=1;

n_time=[];

SNR_all=[];
SNR0=inf;
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
depth_correct_order=1.5;

flag_estimate=0;

flag_whiten=1;

flag_focus=0;
focus_limit_convergence=0.01;
focus_limit_iteration=20;
X_focus={};
flag_focus_R_threshold=1;
focus_R_threshold_max=0.9;
focus_R_threshold_min=0.1;

flag_regularization_percentage=0;

n_proj=0; 	%the number of projection used in SSP. This will be used to fix the whitening matrix

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
        case 'r0'	%baseline source covariance matrix
            R0=option_value;
        case 'n_time'
            n_time=option_value;
        case 'c'	%noise covariance matrix
            C=option_value;
        case 'c_noise_norm'
            C_noise_norm=option_value;    %noise normalization covariance matrix; baseline covariance.
        case 'y'	%measurement data
            Y=option_value;
        case 'ssp'
            SSP=option_value;
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
        case 'snr'	%SNR
            SNR=option_value;
            SNR_RMS=sqrt(SNR);
        case 'snr_rms'	%RMS SNR
            SNR_RMS=option_value;
            SNR=SNR_RMS*SNR_RMS;
        case 'snr0'	%SNR
            SNR0=option_value;
            SNR0_RMS=sqrt(SNR);
        case 'snr0_rms'	%RMS SNR
            SNR0_RMS=option_value;
            SNR0=SNR0_RMS*SNR0_RMS;
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
        case 'flag_noise_normalized_sloreta'
            flag_noise_normalized_sloreta=option_value;
        case 'iop_snorm'
            iop_snorm=option_value;
        case 'iop_tnorm'
            iop_tnorm=option_value;
        case 'prior_dependency'
            lambda=option_value;
        case 'flag_focus'
            flag_focus=option_value;
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
        case 'flag_whiten'
            flag_whiten=option_value;
        case 'flag_regularization_percentage'
            flag_regularization_percentage=option_value;
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


while(((focus_convergence>focus_limit_convergence)&(focus_iteration<=focus_limit_iteration)&flag_focus)|(~flag_focus))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Depth correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if there is NO prior dipole information
    if(isempty(R))
        R=ones(n_time,size(A,2));
    end;
    if(isempty(R0))
        R0=ones(1,size(A,2));
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

        for t=1:n_time
            R(t,:)=R(t,:).*ss;
        end;
        R0=R0.*ss;

    end;


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
        C=eye(size(C));
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Get partial product : A*R*A'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\n\n%d. GET PARTIAL INVERSE OPERATOR (A*R*At)...\n',process_id);
    process_id=process_id+1;
    for t=1:n_time
        fprintf('.');
        Matrix_ARAt(:,:,t)=(A.*repmat(R(t,:),[size(A,1),1]))*A';
    end;
    Matrix_ARAt0=(A.*repmat(R0,[size(A,1),1]))*A';

    if(flag_regularization_percentage)
        [reg_uu,reg_ss,reg_vv]=svd(A',0);
        reg_ss=diag(reg_ss).^2;
        reg_css=sum(reg_ss);
        reg_ff=reg_ss./(reg_ss+1./SNR.*reg_css./size(C,1));
        regularization_percentage=reg_ff'*reg_ss./reg_css;
        fprintf('percentage regularization = %2.2f%%\n',regularization_percentage.*100.0);
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Get regularization adjustment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\n\n%d. GET REGULARIZATION ADJ...\n',process_id);
    process_id=process_id+1;

    noise_power=trace(C)./size(C,1); % get the power of noise
    for t=1:n_time
        signal_power(t)=trace(Matrix_ARAt(:,:,t))./size(Matrix_ARAt(:,:,t),1); % get the power of noise
    end;
    signal_power0=trace(Matrix_ARAt0)./size(Matrix_ARAt0,1); % get the power of noise

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Estimation of SNR using regularization
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

%     if(isempty(SNR))
%         fprintf('\n\n%d. ESTIMATION OF SNR USING REGULARIZATION...\n',process_id);
%         process_id=process_id+1;
% 
%         if(isempty(C)|isempty(A)|isempty(R)|isempty(Y))
%             fprintf('matrices [A], [R], [C], [Y] must not be empty for SNR estimation!');
%             SNR=nan;
%         else
%             [SNR_lcurve, SNR_all_lcurve, SNR_gcv, SNR_all_gcv, SNR_white_estimate, SNR_all_white_estimate,eta,rho,gcv,reg_param]=inverse_snr_estimate(A,C,R,Y,'flag_lcurve',flag_snr_lcurve,'flag_gcv',flag_snr_gcv);
% 
%             if(~isempty(SNR_lcurve))
%                 fprintf('\nEstimated SNR (L-curve)=[%3.3f]\n\n',SNR_lcurve);
%                 SNR=SNR_lcurve;
%             end;
%             if(~isempty(SNR_gcv))
%                 fprintf('\nEstimated SNR (GCV)=[%3.3f]\n\n',SNR_gcv);
%                 SNR=SNR_gcv;
%             end;
%             if(~isempty(SNR_white_estimate))
%                 fprintf('\nEstimated SNR (whitened Y)=[%3.3f]\n\n',SNR_white_estimate);
%                 SNR=SNR_white_estimate;
%             end;
% 
%         end;
%     else
%         fprintf('\nSNR is predifined as [%3.3f]...\n\n',SNR);
%     end;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	SNR ADJUSTMENT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n\n%d. SNR ADJUSTMENT...\n',process_id);
    process_id=process_id+1;

    if(SNR>0)
        if(~isinf(SNR))
            fprintf('Adjusting noise covariance matrix based on given SNR...\n');
            for t=1:n_time
                lambda(t)=signal_power(t)/(noise_power.*SNR(t));
            end;
            lambda0=signal_power0/(noise_power.*SNR0);
        else
            C=zeros(size(C));
        end;
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Inverse the sum of signal matrix (ARA') and noise matrix (C)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\n\n%d. INVERSION FOR INVERSE OPERATOR...\n',process_id);
    process_id=process_id+1;


    for t=1:n_time
        Matrix_SN=(Matrix_ARAt(:,:,t)+lambda(t).*C);
        Matrix_SN_inv(:,:,t)=inv(Matrix_SN);
    end;
    Matrix_SN_inv0=inv((Matrix_ARAt0+lambda0.*C));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Get the minimum L-2 norm inverse operator
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\n\n%d. FINALIZE MIN-NORM INVERSE OPERATOR...\n',process_id);
    process_id=process_id+1;

    for t=1:n_time
        W(:,:,t)=A'*Matrix_SN_inv(:,:,t);

        W_mn(:,:,t)=W(:,:,t).*repmat(R(t,:)',[1,size(W,2)]);
    end;
    W0=A'*Matrix_SN_inv0;
    W_mn0=W0.*repmat(R0',[1,size(W0,2)]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Noise sensitivy normalized IOP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n\n%d. NOISE NORMALIZED IOP...\n',process_id);
    process_id=process_id+1;

    if(flag_noise_normalized_iop)
        if(nperdip==3)
            for idx=1:size(W,1)./nperdip
                WW0=W_mn0((idx-1)*nperdip+1:idx*nperdip,:);

                if(flag_noise_normalized_sloreta)
                    mm=(Matrix_ARAt0+C)*WW0';
                else
                    mm=C*WW0';
                end;

                nd=0;
                for i=1:size(WW0,1)
                    nd=nd+WW0(i,:)*mm(:,i);
                end;
                ndt=sqrt(nd./nperdip)';

                ND=ones(size(WW0)).*ndt;
                for t=1:n_time
                    WW=(W_mn((idx-1)*nperdip+1:idx*nperdip,:,t));
                    W((idx-1)*nperdip+1:idx*nperdip,:,t)=WW./ND;
                end;
            end;
        elseif(nperdip==1)
            for idx=1:size(W,1)
                WW0=W_mn0(idx,:);
                if(flag_noise_normalized_sloreta)
                    mm=(Matrix_ARAt0+C)*WW0';
                else
                    mm=C*WW0';
                end;

                nd=WW0(1,:)*mm(:,1);
                ndt=sqrt(nd)';

                ND=ones(size(WW0)).*ndt;
                for t=1:n_time
                    WW=(W_mn(idx,:,t));
                    W(idx,:,t)=WW./ND;
                end;
            end;
        end;
    else
        fprintf('SKIP NOISE SENSITIVITY NORMALIZATION!\n');
    end;



    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Final whitening
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n\n%d. IOP FINAL WHITENING ...\n',process_id);
    process_id=process_id+1;
    if(flag_whiten)
        for t=1:n_time
            W(:,:,t)=W(:,:,t)*sqrt(diag(1./(ss_C)))*vv_C';
            W_mn(:,:,t)=W_mn(:,:,t)*sqrt(diag(1./(ss_C)))*vv_C';
        end;
    end;

    flag_focus=1;
    focus_iteration=inf;
    focus_convergence=0;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inverse_out{1}=W;
output_count=1;
fprintf('output[%d]--> inverse operator\n',output_count);

if(~isempty(W_mn))
    output_count=output_count+1;
    inverse_out{output_count}=W_mn;
    fprintf('output[%d]--> min. L2 norm inverse operator\n',output_count);
end;

if(~isempty(R))
    output_count=output_count+1;
    inverse_out{output_count}=R;
    fprintf('output[%d]--> diagonal of source covariance \n',output_count);
end;

if(~isempty(Matrix_SN))
    output_count=output_count+1;
    inverse_out{output_count}=Matrix_SN;
    fprintf('output[%d]--> ARA_t+C\n',output_count);
end;

if(~isempty(stnorm_error_total))
    output_count=output_count+1;
    inverse_out{output_count}=stnorm_error_total;
    fprintf('output[%d]--> parsimonious spatiotemporal norm constraint total cost\n',output_count);
end;

if(~isempty(stnorm_error_likelihood))
    output_count=output_count+1;
    inverse_out{output_count}=stnorm_error_likelihood;
    fprintf('output[%d]--> parsimonious spatiotemporal norm constraint likelihood cost\n',output_count);
end;

if(~isempty(stnorm_error_prior))
    output_count=output_count+1;
    inverse_out{output_count}=stnorm_error_prior;
    fprintf('output[%d]--> parsimonious spatiotemporal norm constraint prior cost\n',output_count);
end;

if(~isempty(SNR_all_lcurve))
    output_count=output_count+1;
    inverse_out{output_count}=SNR_lcurve;
    fprintf('output[%d]--> estimated (averaged) SNR (L-curve) from regularization tool\n',output_count);
    output_count=output_count+1;
    inverse_out{output_count}=SNR_all_lcurve;
    fprintf('output[%d]--> estimated (all) SNR (L_curve) from regularization tool\n',output_count);
end;

if(~isempty(SNR_all_gcv))
    output_count=output_count+1;
    inverse_out{output_count}=SNR_gcv;
    fprintf('output[%d]--> estimated (averaged) SNR (GCV) from regularization tool\n',output_count);
    output_count=output_count+1;
    inverse_out{output_count}=SNR_all_gcv;
    fprintf('output[%d]--> estimated (all) SNR (GCV) from regularization tool\n',output_count);
end;

if(~isempty(SNR_all_white_estimate))
    output_count=output_count+1;
    inverse_out{output_count}=SNR_white_estimate;
    fprintf('output[%d]--> estimated (averaged) SNR (whitened Y) from regularization tool\n',output_count);
    output_count=output_count+1;
    inverse_out{output_count}=SNR_all_white_estimate;
    fprintf('output[%d]--> estimated (all) SNR (whitened Y) from regularization tool\n',output_count);
end;

if(~isempty(eta))
    output_count=output_count+1;
    inverse_out{output_count}=eta;
    fprintf('output[%d]--> eta (||X||) \n',output_count);
end;

if(~isempty(rho))
    output_count=output_count+1;
    inverse_out{output_count}=rho;
    fprintf('output[%d]--> rho (||Y-AX||) \n',output_count);
end;

if(~isempty(gcv))
    output_count=output_count+1;
    inverse_out{output_count}=gcv;
    fprintf('output[%d]--> GCV cost \n',output_count);
end;

if(~isempty(reg_param))
    output_count=output_count+1;
    inverse_out{output_count}=reg_param;
    fprintf('output[%d]--> reg_param \n',output_count);
end;


