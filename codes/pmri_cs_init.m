function pmri_cs_obj=pmri_cs_init(image_size,varargin)

pmri_cs_obj=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default values
n_chan=1;
sensitivity_profile={};

R=[];
k_space_sampling=[];

n_dwt=4; %number of levels of DWT
wavename='db4'; % the name of the DWT filter
mu=1e-4;

A_func='pmri_cs_forward_func_default';
A_h_func='pmri_cs_forward_h_func_default';

l1_reg = -1E-3;
TV_reg = -1E-3;

cg_alpha=1e-6;
cg_beta=0.6;
cg_t0=1;
cg_max_iterations=20;

flag_display=1;
flag_archive_history=1;
file_archive_history=sprintf('pmri_cs_%s.mat',datestr(now,'mmddyy_HHMMSS'));

flag_pct=[];
flag_gpu=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(varargin)/2
    option=varargin{2*i-1};
    option_value=varargin{2*i};
    switch lower(option)
        case 'n_chan'
            n_chan=option_value;
        case 'sensitivity_profile'
            sensitivity_profile=option_value;
        case 'r'
            R=option_value;
        case 'k_space_sampling'
            k_space_sampling=option_value;
        case 'a_func'
            A_func=option_value;
        case 'a_h_func'
            A_h_func=option_value;
        case 'n_dwt'
            n_dwt=option_value;
        case 'wavename'
            wavename=option_value;
        case 'l1_reg'
            l1_reg=option_value;
        case 'tv_reg'
            TV_reg=option_value;
        case 'cg_alpha'
            cg_alpha=option_value;
        case 'cg_beta'
            cg_beta=option_value;
        case 'cg_t0'
            cg_t0=option_value;
        case 'cg_max_iterations'
            cg_max_iterations=option_value;
	case 'flag_pct'
	    flag_pct=option_value;
	case 'flag_gpu'
	    flag_gpu=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_archive_history'
            flag_archive_history=option_value;
        case 'file_archive_history'
            file_archive_history=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

if(isempty(sensitivity_profile))
    sensitivity_profile={ones(image_size)};
end;
pmri_cs_obj.sensitivity_profile=sensitivity_profile;
pmri_cs_obj.n_chan=length(pmri_cs_obj.sensitivity_profile);

pmri_cs_obj.I=zeros(size(pmri_cs_obj.sensitivity_profile{1},1),size(pmri_cs_obj.sensitivity_profile{1},2));
for i=1:pmri_cs_obj.n_chan
    pmri_cs_obj.I=pmri_cs_obj.I+abs(pmri_cs_obj.sensitivity_profile{i}).^2;
end;
pmri_cs_obj.I=1./sqrt(pmri_cs_obj.I);


pmri_cs_obj.image_size=image_size;

pmri_cs_obj.mu=mu;

%k-space sampling
if(isempty(k_space_sampling))
    if(isempty(R))
        fprintf('acceleration rate [R] must be specified!\n');
        fprintf('error!\n');
        return;
    end;
    k=randperm(prod(pmri_cs_obj.image_size));
    k=k(1:round(length(k)./R));
    pmri_cs_obj.k_space_sampling=zeros(pmri_cs_obj.image_size);
    pmri_cs_obj.k_space_sampling(k)=1;
else
    pmri_cs_obj.k_space_sampling=k_space_sampling;
end;

%forward model
pmri_cs_obj.A_func=A_func;
pmri_cs_obj.A_h_func=A_h_func;

%sparse transformation
pmri_cs_obj.n_dwt=n_dwt;
pmri_cs_obj.wavename=wavename;
%using Wavelab850
pmri_cs_obj.wavelab850_filter=MakeONFilter('Daubechies',4);
pmri_cs_obj.wavelab850_filter_name='Daubechies';
pmri_cs_obj.wavelab850_filter_par=4;


%regularization parameters
pmri_cs_obj.l1_reg=l1_reg;
pmri_cs_obj.TV_reg=TV_reg;

%CG parameters
pmri_cs_obj.alpha=cg_alpha;
pmri_cs_obj.beta=cg_beta;
pmri_cs_obj.t0=cg_t0;
pmri_cs_obj.cg_max_iterations=cg_max_iterations;

%general parameters
pmri_cs_obj.flag_display=flag_display;
pmri_cs_obj.flag_archive_history=flag_archive_history;
pmri_cs_obj.file_archive_history=file_archive_history;

%using parallel computing?
if(isempty(flag_pct))
	if(isempty(which('parfor')))
	    pmri_cs_obj.flag_pct=0;
	else
	    pmri_cs_obj.flag_pct=1;
	end;
else
	pmri_cs_obj.flag_pct=flag_pct;
end;

if(isempty(flag_gpu))
	if(isempty(which('gfor')))
	    pmri_cs_obj.flag_gpu=0;
	else
	    pmri_cs_obj.flag_gpu=1;
	end;
else
	pmri_cs_obj.flag_gpu=flag_gpu;
end;

return;
