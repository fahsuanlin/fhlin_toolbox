function output=sem_core(varargin)

A=[];
S=[];
val=[];
sem=[];

obj_type='ml';			%objective function type. 'ml' for maximal likelihood; 'ols' for ordinary least square; 'gls' for generalized least square

output=[];

flag_display=1;

for i=1:ceil(nargin/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
    case 'a'
        A=option_value;
        if(size(A,1)~=size(A,2))
            fprintf('[A] is not square!\n error!\n');
            return;
        end;
    case 's'
        S=option_value;
        if(size(S,1)~=size(S,2))
            fprintf('[S] is not square!\n error!\n');
            return;
        end;
    case 'sem'
        sem=option_value;
    case 'val'
        val=option_value;
    case 'node'
        node=option_value;
	case 'obj_tye'
		obj_type=option_value;
	case 'flag_display'
		flag_display=option_value;
    otherwise 
        fprintf('unknown option [%s]\n',option);
        fprintf('error!\n');
        return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
	fprintf('<<SEM Core>>\n');
end;



%optimization procedure
options = optimset('MaxFunEvals',100000,'MaxIter',100000);

path_val_free_opt = fminsearch('sem_obj', sem.path_val(find(~sem.path_fix)), options, sem.path_val(find(sem.path_fix)), find(~sem.path_fix), find(sem.path_fix), sem.A, sem.S, sem.F, sem.covv, 'obj_type', obj_type);

path_val_opt(find(~sem.path_fix))=path_val_free_opt;
path_val_opt(find(sem.path_fix))=sem.path_val(find(sem.path_fix));

[sem_diff,sem_C]=sem_obj(path_val_free_opt, sem.path_val(find(sem.path_fix)), find(~sem.path_fix), find(sem.path_fix), sem.A, sem.S, sem.F, sem.covv, 'obj_type', obj_type);

%determine the chi-square fit


output.path_val_opt=path_val_opt;
output.C_diff=sem_diff;
output.C=sem_C;



%chi-square calculation
if(flag_display)
	fprintf('calculating chi-squares...\n');
end;

%degree of freedom
output.df=(size(sem.covv,1)+1)*(size(sem.covv,1))/2-length(find(~sem.path_fix));


if(isfield(sem,'n_obs')&(~isempty(sem.n_obs))&(sem.n_obs>0))
	output.chi_square=output.C_diff*(sem.n_obs-1);
	
	%p-value calculation; larger p-value (>0.05) represents "GOOD" fit to the data!!
	output.chi_square_pvalue=1-cdf('chi2',output.chi_square,output.df);


else
	if(flag_display)
		fprintf('No number of observation existed in "sem" structure!\n');
		fprintf('skipping chi-square calculation!\n');
	end;
	output.chi_square=[];
	output.chi_square_pvalue=[];
end;

if(flag_display)
	fprintf('<<SEM Core ends!>>\n');
end;
return;
    

