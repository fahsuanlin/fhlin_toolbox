function patloc_obj=patloc_init(varargin)

patloc_obj=[];

flag_cart=1; %cartesian sampling

flag_vec4=1;
flag_vec2=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default values
gamma=267.52e6;     %gyromagnetic ratio; rad/Tesla/s
FOV_freq=256e-3;        %m
FOV_phase=256e-3;        %m
delta_time_freq=40e-6;      %sampling time (read-out): s
time_phase=4e-3;            %duration of phase encoding gradient: s
%grad_max_freq=2.*pi./gamma./FOV_freq./delta_time_freq;     %gradient (read-out): T/m
%grad_delta_phase=2.*pi./gamma./FOV_phase./time_phase;;     %gradient (phase): T/m

image_size=[64 64];

flag_display=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(varargin)/2
    option=varargin{2*i-1};
    option_value=varargin{2*i};
    switch lower(option)
        case 'gamma'
            gamma=option_value;
        case 'FOV_read'
            FOV_read=option_value;
        case 'FOV_phase'
            FOV_phase=option_value;
        case 'delta_time_freq'
            delta_time_freq=option_value;
        case 'time_phase'
            time_phase=option_value;
	case 'image_size'
	    image_size=option_value;
	case 'g'
	    G=option_value;
	case 'k'
	    K=option_value;
	case 'flag_cart'
	    flag_cart=option_value;
	case 'flag_vec4'
	    flag_vec4=option_value;
	case 'flag_vec2'
	    flag_vec2=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n');
            return;
    end;
end;


patloc_obj.gamma=gamma;
patloc_obj.FOV_freq=FOV_freq;
patloc_obj.FOV_phase=FOV_phase;
patloc_obj.delta_time_freq=delta_time_freq;
patloc_obj.time_phase=time_phase;
patloc_obj.n_phase=image_size(1);
patloc_obj.n_freq=image_size(2);
patloc_obj.G=G;
patloc_obj.K=K;
patloc_obj.flag_cart=flag_cart;
patloc_obj.flag_vec4=flag_vec4;
patloc_obj.flag_vec2=flag_vec2;

%calculate gradient parameters for conventional 2D spin-echo sequence
patloc_obj.grad_max_freq=2.*pi./(patloc_obj.gamma)./(patloc_obj.FOV_freq)./(patloc_obj.delta_time_freq);
patloc_obj.grad_delta_phase=2.*pi./(patloc_obj.gamma)./(patloc_obj.FOV_phase)./(patloc_obj.time_phase);


%general parameters
patloc_obj.flag_display=flag_display;


fprintf('patloc gradient preparation...');
for g_idx=1:length(patloc_obj.G)
    fprintf('*');
    grid_freq=patloc_obj.G(g_idx).freq;
    grid_phase=patloc_obj.G(g_idx).phase;

    if(flag_vec4)
	    G_freq=repmat(patloc_obj.G(g_idx).freq,[1 1 patloc_obj.n_phase patloc_obj.n_freq]);
	    D_freq=repmat(([1:patloc_obj.n_freq]-floor(patloc_obj.n_freq./2)-1)',[1 patloc_obj.n_phase patloc_obj.n_freq patloc_obj.n_phase]);
	    D_freq=permute(D_freq,[2 3 4 1]);
	    patloc_obj.K_freq{g_idx}=exp(sqrt(-1).*(-1).*patloc_obj.gamma.*patloc_obj.grad_max_freq.*patloc_obj.delta_time_freq.*D_freq.*patloc_obj.FOV_freq./patloc_obj.n_freq.*G_freq);

	    G_phase=repmat(patloc_obj.G(g_idx).phase,[1 1 patloc_obj.n_phase patloc_obj.n_freq]);
	    D_phase=repmat(([1:patloc_obj.n_phase]-floor(patloc_obj.n_phase./2)-1)',[1 patloc_obj.n_phase patloc_obj.n_freq patloc_obj.n_freq]);
	    D_phase=permute(D_phase,[2 3 1 4]);
	    patloc_obj.K_phase{g_idx}=exp(sqrt(-1).*(-1).*patloc_obj.gamma.*patloc_obj.grad_delta_phase.*D_phase.*patloc_obj.time_phase.*patloc_obj.FOV_phase./patloc_obj.n_phase.*G_phase);
    elseif(flag_vec2)
	    G_freq=patloc_obj.G(g_idx).freq;
	    patloc_obj.K_freq{g_idx}=(-1).*patloc_obj.gamma.*patloc_obj.grad_max_freq.*patloc_obj.delta_time_freq.*patloc_obj.FOV_freq./patloc_obj.n_freq.*G_freq;
	    
	    G_phase=patloc_obj.G(g_idx).phase;
	    patloc_obj.K_phase{g_idx}=(-1).*patloc_obj.gamma.*patloc_obj.grad_delta_phase.*patloc_obj.time_phase.*patloc_obj.FOV_phase./patloc_obj.n_phase.*G_phase;

    end;
end;
fprintf('\n');

return;
