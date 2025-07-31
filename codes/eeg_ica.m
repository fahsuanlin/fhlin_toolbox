function [data_component, topo_component, data_now]=eeg_ica(data,varargin)
% eeg_ica   perform fast ICA and artifact rejection
%
% [data_component, topo_component, data_filtered]=eeg_ica(data,[option,
% option_value])
%
% data: N x T matrix for N channels and T time points
%
% option:
%   'numofIC': number of independent components to be decomposed; default:
%   1/3 of the rows of data
%
%   'discard_vector_idx': an row index vector specifying the independent 
%   components representing the artifact. 
%
%   'artifact_ref_ch': an row index vector specifying the similarity
%   between independent components and the artifact. Useful for blinking
%   artifact rejection by setting it to frontal lobe channels.
%
%   'artifact_ref_ch_cc': a threshold to idenify the indpenedent component
%   that is most similar to the artifact signals. default: 0.6
%   
%   'flag_display': a flag to enable/disable verbose output. default: 1
%
% data_component: a numbofIC x T matrix for independnet components
%
% topo_component: a N x numberofIC matrix for the topology of indepenent
% components
%
% data_filtered: a N x T data matrix after rejecting artifact components.
%
% fhlin@july 22 2026
%

numOfIC=[];
discard_vector_idx=[];
data_now=[];

%automatic detection of artifact; reference channel indices and correlation
%coefficient threshold
artifact_ref_ch=[];
artifact_ref_ch_cc=.6;

flag_display=1;


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'numofic'
            numOfIC=option_value;
        case 'discard_vector_idx'
            discard_vector_idx=option_value;
        case 'artifact_ref_ch'
            artifact_ref_ch=option_value;         
        case 'artifact_ref_ch_cc'
            artifact_ref_ch_cc=option_value;      
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;


%ICA decomposition
% 1) center
dataMean      = mean(data, 2 );          % channel means
Xc            = data -dataMean;

% 2) eigen-whiten
[E, D]        = eig( cov( Xc.' ) );                     % note transpose
dd=diag(D);
dd_min_idx=find(dd<max(dd)./100);
dd(dd_min_idx)=max(dd)./100;
D=diag(dd);
whiteMat      = inv( sqrt(D) ) * E.';
dewhiteMat    = E * sqrt(D);
Xw            = whiteMat * Xc;                          % whitened data (with regularization)

% 3) FastICA on whitened data

if(isempty(numOfIC))
    numOfIC=round(size(data,1)./3);
    if(flag_display)
        fprintf('automatic setting [%03d] independent components...\n',numOfIC);
    end;
end;

try
    switch flag_display
        case 1
            v_option='on';
        case 0
            v_option='off';
    end;
    [ icasig, A, W ] = fastica( Xw, 'numOfIC', numOfIC, 'g', 'tanh' ,'verbose',v_option);
catch
end;

data_component=icasig;
topo_component=A;

%reconstruct by discarding components
if(~isempty(discard_vector_idx))

    A_recon=topo_component;
    A_recon(:,discard_vector_idx)=0;

    data_now=dewhiteMat*A_recon*data_component+dataMean;
else

    if(~isempty(artifact_ref_ch_cc)&~isempty(artifact_ref_ch))
        if(flag_display)
            fprintf('automatic artifact rejection based on the signal similairty to channel [%s]...\n', num2str(artifact_ref_ch));
        end;
    

        cc=corrcoef([data_component.', mean(data(artifact_ref_ch,:),1).']);
        cc=cc(size(data_component,1)+1:end,1:size(data_component,1));
        [mmax, discard_vector_idx]=max(abs(cc));

        if(mmax>=artifact_ref_ch_cc)
            if(flag_display)
               fprintf('ICA component #[%d] (similar to reference channel(s) with cc=%2.2f) seleccted for this aritfact suppression...\n',discard_vector_idx, mmax);
            end;

            A_recon=topo_component;
            A_recon(:,discard_vector_idx)=0;

            data_now=dewhiteMat*A_recon*data_component+dataMean;
        else
            if(flag_display)
                fprintf('no component is rejected since the largest corr. coef. is [%2.2f](threshold =%2.2f)\n...', mmax, artifact_ref_ch_cc);
            end;

            data_now=data;
        end;
    else

        if(flag_display)
            fprintf('no discarding any components...\n');
        end;
        data_now=data;
    end;
end;
