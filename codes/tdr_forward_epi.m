function tdr_forward_epi(varargin)

global tdr_obj;

flag_display=1;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('no [%s] available...\n',option);
            return;
    end;
end;

if(flag_display)
    fprintf('TDR foward (EPI)...');
end;


grid_freq=tdr_obj.grid_freq;
grid_phase=tdr_obj.grid_phase;
G_freq=repmat(grid_freq,[1 1 tdr_obj.n_freq]);
G_phase=repmat(grid_phase,[1 1 tdr_obj.n_freq]);

D_freq=repmat(([1:tdr_obj.n_freq]-floor(tdr_obj.n_freq./2)-1)',[1 tdr_obj.n_phase tdr_obj.n_freq]);
D_freq=permute(D_freq,[2 3 1]);
K_freq=exp(sqrt(-1).*(-1).*tdr_obj.gamma.*tdr_obj.sequence.grad_max_freq.*tdr_obj.sequence.delta_time_freq.*D_freq.*tdr_obj.FOV_freq./tdr_obj.n_freq.*G_freq);

tdr_obj.kspace=zeros(tdr_obj.n_phase,tdr_obj.n_freq);

for y_idx=1:tdr_obj.n_phase
    if(sum(tdr_obj.K(y_idx,:))>eps)
        fprintf('#');
        k_phase=exp(sqrt(-1).*(-1).*tdr_obj.gamma.*tdr_obj.sequence.grad_delta_phase.*(y_idx-floor(tdr_obj.n_phase./2)-1).*tdr_obj.sequence.time_phase.*tdr_obj.FOV_phase./tdr_obj.n_phase.*grid_phase);
        k_fieldmap=exp(sqrt(-1).*(-1).*2.*pi.*tdr_obj.fieldmap.*(y_idx-floor(tdr_obj.n_phase./2)-1).*tdr_obj.sequence.echospacing);
        
       
        k_phase=k_phase.*k_fieldmap;
        
        K_phase=repmat(k_phase,[1 1 tdr_obj.n_freq]);

        X=repmat(tdr_obj.X,[1 1 tdr_obj.n_freq]);
        tdr_obj.kspace(y_idx,:)=squeeze(sum(sum(X.*K_freq.*K_phase,1),2)).*tdr_obj.K(y_idx,:)';
    end;
end;
fprintf('\n');

return;




