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
SSP=[];
C=[];
C_noise_norm=[];
Y=[];
X_init=[];
R_stnorm=[];
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

	%fixing the noise covariance preparation for whitening
	if(n_proj>0)
		tmp=diag(ss_C);
		tmp(end-n_proj:end)=inf;
		ss_C=tmp;
	else 
		ss_C=diag(ss_C);
	end;
        A=sqrt(diag(1./(ss_C)))*vv_C'*A;
        C=eye(size(C));
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Get partial product : A*R*A'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('\n\n%d. GET PARTIAL INVERSE OPERATOR (A*R*At)...\n',process_id);
    process_id=process_id+1;

    Matrix_ARAt=(A.*repmat(R,[size(A,1),1]))*A';

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
    signal_power=trace(Matrix_ARAt)./size(Matrix_ARAt,1); % get the power of noise

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
            [SNR_lcurve, SNR_all_lcurve, SNR_gcv, SNR_all_gcv, SNR_white_estimate, SNR_all_white_estimate,eta,rho,gcv,reg_param]=inverse_snr_estimate(A,C,R,Y,'flag_lcurve',flag_snr_lcurve,'flag_gcv',flag_snr_gcv);
            
            if(~isempty(SNR_lcurve))
                fprintf('\nEstimated SNR (L-curve)=[%3.3f]\n\n',SNR_lcurve);
                SNR=SNR_lcurve;
            end;
            if(~isempty(SNR_gcv))
                fprintf('\nEstimated SNR (GCV)=[%3.3f]\n\n',SNR_gcv);
                SNR=SNR_gcv;
            end;
            if(~isempty(SNR_white_estimate))
                fprintf('\nEstimated SNR (whitened Y)=[%3.3f]\n\n',SNR_white_estimate);
                SNR=SNR_white_estimate;
            end;
            
        end;
    else
        fprintf('\nSNR is predifined as [%3.3f]...\n\n',SNR);
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
            
        else
            C=zeros(size(C));
        end;
    end;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Inverse the sum of signal matrix (ARA') and noise matrix (C)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fprintf('\n\n%d. INVERSION FOR INVERSE OPERATOR...\n',process_id);
    process_id=process_id+1;
    
   
	Matrix_SN=(Matrix_ARAt+lambda.*C);
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
    %	Noise sensitivy normalized IOP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n\n%d. NOISE NORMALIZED IOP...\n',process_id);
    process_id=process_id+1;
    
    if(flag_noise_normalized_iop)
    	if(nperdip==3)
    		for idx=1:size(W,1)./nperdip
	 		WW=W_mn((idx-1)*nperdip+1:idx*nperdip,:);
		        if(flag_noise_normalized_sloreta)
					%fprintf('sLORETA noise normalization ...\n');
					mm=(Matrix_ARAt+C)*WW';
		        else
					mm=C*WW';
			end;

			nd=0;
			for i=1:size(WW,1)
				nd=nd+WW(i,:)*mm(:,i);
			end;
			ndt=sqrt(nd./nperdip)';
		
			ND=ones(size(WW)).*ndt;
			W((idx-1)*nperdip+1:idx*nperdip,:)=WW./ND;
		end;
	elseif(nperdip==1)
		for idx=1:size(W,1)
	 		WW=W_mn(idx,:);
		        if(flag_noise_normalized_sloreta)
					fprintf('sLORETA noise normalization ...\n');
					mm=(Matrix_ARAt+C)*WW';
		        else
					mm=C*WW';
			end;

			nd=WW(1,:)*mm(:,1);
			ndt=sqrt(nd)';
		
			ND=ones(size(WW)).*ndt;
			W(idx,:)=WW./ND;
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
    	fprintf('iop final whitening...\n');
        W=W*sqrt(diag(1./(ss_C)))*vv_C';
	W_mn=W_mn*sqrt(diag(1./(ss_C)))*vv_C';
    end;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	Dipole estimation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\n\n%d. DIPOLE ESTIMATE ...\n',process_id);
    process_id=process_id+1;
    
    if(flag_estimate)
        if(~isempty(Y))
            fprintf('estimating...\n');
            X=W*Y;
        else
	    X=[];
            fprintf('No measurement data!\n');
            fprintf('skip dipole estimation!\n');
        end;
    else
	X=[];
        fprintf('SKIP DIPOLE ESTIMATION!\n');
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	final check
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(flag_focus)
        fprintf('updating prior for focal estimation...\n');

		fprintf('collapsing new prior from the estimated data (L2 norm projection in temporal domain\n')
		R=(mean(X.^(2),2).^(1/2))';
		
		if(flag_focus_R_threshold)
			fprintf('using thresholded prior...\n');

			if(nperdip>1)
				fprintf('collapsing directional components...\n');

				R=reshape(R,[nperdip,length(R)/nperdip]);
						
				R=sqrt(squeeze(sum(abs(R).^2,1)));	%modulus of absolute values
			end;


			R_threshold=sqrt(max(abs(R).^2)./SNR);
			rr=ones(size(R)).*focus_R_threshold_min;
			idx=find(R>=R_threshold);


			fprintf('[%3.3f%%] exceeding threshold (%2.2f)\n',length(idx)./length(R).*100.0, R_threshold);


			rr(idx)=focus_R_threshold_max;
			R=rr;

			if(nperdip>1)
				fprintf('expanding directional components...\n');
				R=repmat(R,[3,1]);
				R=reshape(R,[1,length(R).*nperdip]);
			end;
		end;
	

        X_focus{focus_iteration}=X;
        
       
        if(focus_iteration>1)
            focus_convergence=(sum(sum(abs(X_focus{focus_iteration}-X_focus{focus_iteration-1}).^2))./sum(sum(abs(X_focus{focus_iteration}).^2)));            
        else
            focus_convergence=Inf;
        end;
        
        fprintf('focus [%d]: %e\n',focus_iteration, focus_convergence);
        
        focus_iteration=focus_iteration+1;
        
    else
        flag_focus=1;
        focus_iteration=inf;
        focus_convergence=0;
    end;
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

if(~isempty(Matrix_ARAt))
    output_count=output_count+1;
    inverse_out{output_count}=Matrix_ARAt;
    fprintf('output[%d]--> ARAt\n',output_count);
end;

if(~isempty(C))
    output_count=output_count+1;
    inverse_out{output_count}=C;
    fprintf('output[%d]--> C\n',output_count);
end;

if(~isempty(signal_power))
    output_count=output_count+1;
    inverse_out{output_count}=signal_power;
    fprintf('output[%d]--> signal_power\n',output_count);
end;

if(~isempty(noise_power))
    output_count=output_count+1;
    inverse_out{output_count}=noise_power;
    fprintf('output[%d]--> noise_power\n',output_count);
end;

if(~isempty(vv_C))
    output_count=output_count+1;
    inverse_out{output_count}=sqrt(diag(1./(ss_C)))*vv_C';
    fprintf('output[%d]--> data whitening matrix\n',output_count);
end;


if(~isempty(Matrix_SN))
    output_count=output_count+1;
    inverse_out{output_count}=Matrix_SN;
    fprintf('output[%d]--> ARAt+C\n',output_count);
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


if(~isempty(X))
    output_count=output_count+1;
    inverse_out{output_count}=X;
    fprintf('output[%d]--> dipole estimate \n',output_count);
end;

if(~isempty(X_focus))
    output_count=output_count+1;
    inverse_out{output_count}=X_focus;
    fprintf('output[%d]--> focal dipole estimate history\n',output_count);
end;

if(flag_regularization_percentage)
    output_count=output_count+1;
    inverse_out{output_count}=regularization_percentage;
    fprintf('output[%d]--> regularization percentage\n',output_count);
end;

