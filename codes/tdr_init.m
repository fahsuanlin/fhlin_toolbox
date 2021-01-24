function tdr_init(varargin)

global tdr_obj;

flag_display=1;

%TDR preparation
tdr_obj.gamma=267.52e6;     %gyromagnetic ratio; rad/Tesla/s
tdr_obj.FOV_freq=256e-3;        %m
tdr_obj.FOV_phase=256e-3;        %m
tdr_obj.n_freq=256;
tdr_obj.n_phase=256;

%spin echo sequence;
tdr_obj.sequence.name='SE';
tdr_obj.sequence.delta_time_freq=40e-6;      %sampling time (read-out): s
tdr_obj.sequence.time_phase=4e-3;            %duration of phase encoding gradient: s
tdr_obj.sequence.grad_max_freq=2.*pi./tdr_obj.gamma./tdr_obj.FOV_freq./tdr_obj.sequence.delta_time_freq;     %gradient (read-out): T/m
tdr_obj.sequence.grad_delta_phase=2.*pi./tdr_obj.gamma./tdr_obj.FOV_phase./tdr_obj.sequence.time_phase;;     %gradient (phase): T/m


tdr_obj.K=[];
tdr_obj.X=[];

tdr_obj.fieldmap=[];
tdr_obj.echospacing=0; %second;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'gamma'
            tdr_obj.gamma=option_value;
        case 'FOV_freq'
            tdr_obj.FOV_freq=option_value; %FOV; meter
        case 'FOV_phase'
            tdr_obj.FOV_phase=option_value; %FOV; meter
        case 'sequence'
            tdr_obj.sequence.name=option_value; %pulse sequence;
        case 'n_freq'
            tdr_obj.n_freq=option_value;
        case 'n_phase'
            tdr_obj.n_phase=option_value;
        case 'k'
            tdr_obj.K=option_value;
        case 'x'
            tdr_obj.X=option_value;
        case 'fieldmap'
            tdr_obj.fieldmap=option_value;
        case 'echospacing'
            tdr_obj.sequence.echospacing=option_value;
        otherwise 
            fprintf('no [%s] available...\n',option);
            return;
    end;
end;

if(flag_display)
    fprintf('TDR initialization...\n');
end;


%gradient setup: linear gradient
[grid_freq,grid_phase]=meshgrid([-floor(tdr_obj.n_freq/2):ceil(tdr_obj.n_freq/2)-1],[-floor(tdr_obj.n_phase/2) :1:ceil(tdr_obj.n_phase/2)-1]);
tdr_obj.grid_freq=fmri_scale(grid_freq,ceil(tdr_obj.n_freq/2)-1,-floor(tdr_obj.n_freq/2));
tdr_obj.grid_phase=fmri_scale(grid_phase,ceil(tdr_obj.n_phase/2)-1,-floor(tdr_obj.n_phase/2));
        
%k-space sampling pattern
tdr_obj.K=ones(tdr_obj.n_phase,tdr_obj.n_freq);

%spin density
if(isempty(tdr_obj.X))
    tdr_obj.X=ones(size(tdr_obj.K));
end;

%fieldmap
if(isempty(tdr_obj.fieldmap))
    tdr_obj.fieldmap=zeros(size(tdr_obj.X));
end;

return;


