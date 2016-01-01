function [encoded_data]=mri_tdr_forward(varargin)

encoded_data=[];


%TDR preparation
gamma=267.52e6;     %gyromagnetic ratio; rad/Tesla/s
FOV_freq=256e-3;        %m
FOV_phase=256e-3;        %m
delta_time_freq=40e-6;      %sampling time (read-out): s
time_phase=4e-3;            %duration of phase encoding gradient: s
grad_max_freq=2.*pi./gamma./FOV_freq./delta_time_freq;     %gradient (read-out): T/m
grad_delta_phase=2.*pi./gamma./FOV_phase./time_phase;;     %gradient (phase): T/m

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    optino_value=varargin{i*2};
    switch lower(option)
        case k
            K=option_value;
        case g
            G=option_value;
        otherwise
            fprintf('unknown option [%s]!\nError!\n',option); 
            return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Temp=[];
for g_idx=1:length(G)
    grid_freq=G(g_idx).freq;
    grid_phase=G(g_idx).phase;
    G_freq=repmat(G(g_idx).freq,[1 1 n_freq]);
    G_phase=repmat(G(g_idx).phase,[1 1 n_freq]);

    D_freq=repmat(([1:n_freq]-floor(n_freq./2)-1)',[1 n_phase n_freq]);
    D_freq=permute(D_freq,[2 3 1]);
    K_freq=exp(sqrt(-1).*(-1).*gamma.*grad_max_freq.*delta_time_freq.*D_freq.*FOV_freq./n_freq.*G_freq);

    Temp{g_idx}=zeros(size(ORIG));

    for y_idx=1:n_phase
        if(sum(K{g_idx}(y_idx,:))>eps)
            fprintf('#');
            k_phase=exp(sqrt(-1).*(-1).*gamma.*grad_delta_phase.*(y_idx-floor(n_phase./2)-1).*time_phase.*FOV_phase./n_phase.*grid_phase);
            K_phase=repmat(k_phase,[1 1 n_freq]);

            for i=1:size(ORIG,3)
                X=repmat(orig(:,:,i),[1 1 n_freq]);
                Temp{g_idx}(y_idx,:,i)=squeeze(sum(sum(X.*K_freq.*K_phase,1),2));
            end;
        end;
    end;
end;
temp=Temp;

%k-space sampling matrix
for g_idx=1:length(G)
    idx=find(K{g_idx}<eps);

    for i=1:size(temp{g_idx},3)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%         E          %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %K-space acceleration

        buffer0=temp{g_idx}(:,:,i);
        buffer0(idx)=0;
        temp{g_idx}(:,:,i)=buffer0;
    end;
end;

encoded_data=temp;