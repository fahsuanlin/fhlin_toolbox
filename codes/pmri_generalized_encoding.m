function [error, res, beta]=pmri_generalized_encoding(varargin);
%
%	pmri_generalized_encoding		perform generalized PatLoc reconstruction using
%	time-domain signals and the conjugated gradient method in Cartesian
%	sampling trajectory
%
%
%	[error, res, beta]=pmri_generalized_encoding('Y',Y,'S',S,'G',G,'K',K,'flag_display',1);
%
%	INPUT:
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%   G_general: spatial encoding magnetic fields for "frequency" and "phase" encoding [n_PE, n_FE, n_G]
%       *must be paired with K_general
%		n_G: # of spatial encoding magnetic fields
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%   K_general: n-D k-space coordinates [n_encode, n_G]
%       *must be paired with G_general
%		n_G: # of spatial encoding magnetic fields
%		n_encode: # of k-space data
%       entries are suggested to be within [-1, 1), where 1 corresponds to the
%       maximal k-space coordinate for the spatial resolution required to
%       distinguish two neighboring pixel in the image domain based on traditional Fourier imaging.
%   X: input image to be encoded [n_PE, n_FE]
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	'flag_sensitivity_modulation': value of either 0 or 1
%		It indicates of if the input variable X has been spatially modulated by multi-channel B1 profiles already or not.
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	error: 1D sum-of-squares errors after using fitting the image by a basis function generated at EACH of the encoded position [1 ,n_encode].
%		n_encode: # of k-space data
%	res: residual images afer using EACH of the encoded position [n_PE*n_PE, n_encode].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%		n_encode: # of k-space data
%	beta: 1D coefficients used for optimally fitting the image and the
%	basis function generated at EACH of the encoded position [1, n_encode]
%		n_encode: # of k-space data
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin,
%   Athinoula A. Martinos Center, Mass General Hospital
%   Institute of Biomedical Engineering, National Taiwan University
%
%       fhlin@nmr.mgh.harvard.edu
%   	fhlin@ntu.edu.tw
%
%       fhlin@Dec. 18, 2008
%   	fhlin@Oct. 12, 2010

S=[];
K_arbitrary=[];
G_general=[];
X=[];


n_chan=[];
n_freq=[];
n_phase=[];


flag_sensitivity_modulation=1;
flag_display=0;
flag_debug=0;
flag_res=0;

n_calc=32;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'k_general'
            K_general=option_value;
        case 'g_general'
            G_general=option_value;
        case 'x'
            X=option_value;
        case 'n_chan';
            n_chan=option_value;
        case 'n_freq';
            n_freq=option_value;
        case 'n_phase'
            n_phase=option_value;
        case 'n_calc'
            n_calc=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_res'
            flag_res=option_value;
        case 'flag_sensitivity_modulation'
            flag_sensitivity_modulation=option_value;
        case 'flag_debug'
            flag_debug=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

if(~isempty(G_general))
    for g_idx=1:size(G_general,3)
        G_tmp(:,g_idx)=reshape(G_general(:,:,g_idx),[n_phase*n_freq,1]);
    end;
end;

if(isempty(n_chan))
    if(~isempty(S))
        n_chan=size(S,3);
    else
        n_chan=1;
    end;
end;

if(flag_sensitivity_modulation)
    temp=[];
    for i=1:size(S,3)
        % S (sensitivity)
        tmp=X.*S(:,:,i);
        ss(:,i)=reshape(S(:,:,i),[size(S,1)*size(S,2),1]);
        temp(:,i)=tmp(:);
    end;
else
    temp=X(:);
end;


Temp=[];
k_prep=sqrt(-1).*(-1).*2.*pi.*G_tmp./2;
k_idx=[1:size(K_general,1)];
for calc_idx=1:ceil(size(K_general,1)/n_calc)
    if(calc_idx~=ceil(length(k_idx)/n_calc))
        k_idx_now=k_idx((calc_idx-1)*n_calc+1:calc_idx*n_calc);
    else
        k_idx_now=k_idx((calc_idx-1)*n_calc+1:length(k_idx));
    end;
    k_encode=exp(k_prep*transpose(K_general(k_idx_now,:)));

    if(flag_sensitivity_modulation)
        E=inv(k_encode'*k_encode)*k_encode'*temp;
        encoded_data(k_idx_now,:)=E;

        kk=[];
        for ch_idx=1:n_chan
            kk=cat(3,kk,(k_encode).*(repmat(ss(:,ch_idx),[1, length(k_idx_now)])));
        end;
        kk=permute(kk,[1 3 2]);
        kk=reshape(kk,[size(kk,1)*size(kk,2),size(kk,3)]);

        beta(k_idx_now)=(1./sum(abs(kk).^2,1))'.*(kk'*temp(:));
        if(flag_res)
            res(:,k_idx_now)=repmat(temp(:),[1,length(k_idx_now)])-kk*diag(beta(k_idx_now));
            error(k_idx_now)=sum(abs(res(:,k_idx_now)).^2,1);
        else
            res=repmat(temp(:),[1,length(k_idx_now)])-kk*diag(beta(k_idx_now));
            error(k_idx_now)=sum(abs(res).^2,1);
        end;
    else
        kk=[];

        for ch_idx=1:n_chan
            kk=cat(2,kk,transpose(k_encode));
        end;

        beta(k_idx_now)=inv(kk*kk')*kk*temp;
        if(flag_res)
            res(:,k_idx_now)=repmat(temp,[1,length(k_idx_now)])-transpose(diag(beta(k_idx_now))*kk);
            error(k_idx_now)=sum(abs(res(:,k_idx_now)).^2,1);
        else
            res=repmat(temp,[1,length(k_idx_now)])-transpose(diag(beta(k_idx_now))*kk);
            error(k_idx_now)=sum(abs(res).^2,1);
        end;
    end;
end;

return;
