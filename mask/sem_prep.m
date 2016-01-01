function sem=sem_prep(varargin)
% sem_prep  Preparation for SEM
%
% sem=sem_prep([option, option_value,.....]);
%
% options:
%   'path': 
%   'node':
% sem: SEM structure 
%
% see sem_fhlin_test.m for details.
%
% fhlin@aug. 26, 2002

sem=[];
path={};
node=[];
covv=[];
cov_format='power';

flag_display=1;

for i=1:ceil(nargin/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
    case 'path'
        path=option_value;
    case 'node'
        node=option_value;
    case 'covv'
        covv=option_value;
	case 'flag_display'
		flag_display=option_value;
	case 'cov_format'
		cov_format=option_value;
    otherwise 
        fprintf('unknown option [%s]\n',option);
        fprintf('error!\n');
        return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
	fprintf('<<SEM Preparation>>\n');
end;

%determine the number of nodes
node_name={};
path_val=[];
for i=1:length(path)
    for j=1:length(path(i).node_from)
        if(~isempty(path(i).node_from{j}))
            if(sum(ismember(node_name,path(i).node_from{j}))==0) %new node
                node_name{length(node_name)+1}=path(i).node_from{j};
            end;
        end;
    end;
    
    
    for j=1:length(path(i).node_to)
        if(~isempty(path(i).node_to{j}))
            if(sum(ismember(node_name,path(i).node_to{j}))==0) %new node
                node_name{length(node_name)+1}=path(i).node_to{j};
            end;
        end;
    end;
    
    %initialize the path coefficients
    path_val=[path_val, path(i).val];
end;

if(flag_display)
	fprintf('Total [%d] nodes\n',length(node_name));
	for i=1:length(node_name)
 	   fprintf('node [%d]=%s\n',i,node_name{i});
	end;
	fprintf('\n');
end;


%initializing matrices A and S

A=zeros(length(node_name));

S=zeros(length(node_name));

% setup matrix A and matrix S (connection matrix)
for i=1:length(path)

	if(flag_display)
	    fprintf('path [%d]...\n',i);
	end;

    for j=1:length(path(i).node_from)
        if(~isempty(path(i).node_from{j}))
            col=find(ismember(node_name,path(i).node_from{j}));
            row=find(ismember(node_name,path(i).node_to{j}));
            if(path(i).flag_uni{j})
				if(flag_display)
					fprintf('\tuni-directional path...');
					fprintf('from [%s] ',path(i).node_from{j});
					fprintf('to [%s]\n',path(i).node_to{j});
				end;
                
                A(row,col)=i;
                
            else
				if(flag_display)
					fprintf('\tbi-directional path...');
					fprintf('between [%s] ',path(i).node_from{j});
					fprintf('and [%s]\n',path(i).node_to{j});
				end;
                
                S(row,col)=i;
                S(col,row)=i;
            end;
        else
            if(flag_display)
        		fprintf('\tsource path to [%s]\n',path(i).node_to{j});
            end;
            row=find(ismember(node_name,path(i).node_to{j}));
            S(row,row)=i;
        end;
    end;
end;


% setup time series for different nodes
for i=1:length(node)
    if(isfield(node(i),'timeseries'))
        if(~isempty(node(i).timeseries))
            col=find(ismember(node_name,node(i).name));
			if(flag_display)
	            fprintf('found node [%s] timeseries...\n',node(i).name);
			end;
            node_timeseries(:,col)=reshape(node(i).timeseries,[prod(size(node(i).timeseries)),1]);
        else
			if(flag_display)
	            fprintf('found node [%s] with empty timeseries...\n',node(i).name);
			end;
            node_timeseries=[];
        end;
    else
		if(flag_display)
	        fprintf('found node [%s] with empty timeseries...\n',node(i).name);
		end;
        node_timeseries=[];
    end;
end;


% setup initial path coefficients
for i=1:length(path)
    if(isinf(path(i).val)) %free path coefficients
        path_fix(i)=0;
        cc=[];
        if(isfield(path(i),'path_val_init'))
            if(flag_display)
                fprintf('initializing path [%d] with pre-defined value [%3.3f]...\n',i,path(i).path_val_init);
            end;
            path_val(i)=path(i).path_val_init;
        else
            for j=1:length(path(i).node_from)
                %providing time series of nodes to estimate the covariance
                if(~isempty(node_timeseries))
                    from=path(i).node_from{j};
                    to=path(i).node_to{j};
                    from_idx=find(ismember(node_name,from));
                    to_idx=find(ismember(node_name,to));
                    
                    if(~isempty(from))	%cross-covariance
%                        covv=cov([node_timeseries(:,from_idx),node_timeseries(:,to_idx)]);
                        covv=corrcoef([node_timeseries(:,from_idx),node_timeseries(:,to_idx)]);
                        if(j==1)
                            cc=covv(1,2);
                        else
                            cc=(cc.*(j-1)+covv(1,2))./j;
                        end;
                        path_val(i)=cc;
                    else				%auto-covariance
                        path_val(i)=cov(node_timeseries(:,to_idx));
                    end;
                elseif(~isempty(covv))
                    %providing the covariance among nodes directly
                    from=path(i).node_from{j};
                    to=path(i).node_to{j};
                    row_idx=find(ismember(covv.name,from));
                    col_idx=find(ismember(covv.name,to));
                    if(~isempty(row_idx)&~isempty(col_idx))
                        path_val(i)=covv(row_idx, col_idx);
                    else
                        path_val(i)=1.0; %involving latent variables; setting the initial path coefficient to be 1.0;
                    end;
                else
                    if(flag_display)
                        fprintf('Neither timeseries nor explicit covariance matrix among nodes is found!\n');
                        fprintf('errror!\n');
                        return;
                    end;
                end;
            end;
        end;
    else	%fixed value path coefficient
        path_val(i)=path(i).val; 
        path_fix(i)=1;
    end;
end;

if(flag_display)
	fprintf('initialized path coefficients: %s\n',mat2str(path_val,2));
end;



%setup filter matrix and source matrix
non_latent={};
for i=1:length(node)
    if(~node(i).flag_latent)
        non_latent{length(non_latent)+1}=node(i).name;
    end;
end;
F=zeros(length(non_latent),length(node));

for i=1:length(node)
    col_idx=find(ismember(node_name,node(i).name));
    row_idx=find(ismember(non_latent,node(i).name));
    
    F(row_idx,col_idx)=1;
end;

sem.A=A;
sem.S=S;
sem.F=F;
sem.path_val=path_val;
sem.path_fix=path_fix;
sem.node_name=node_name;

if(exist('node_timeseries')&(~isempty(node_timeseries)))
	if(flag_display)
	    fprintf('Time series for nodes found! Calculating covariance matrix...\n');
	end;
    sem.node_timeseries=node_timeseries;
	switch lower(cov_format)
	case 'cov'
	    sem.covv=cov(sem.node_timeseries);
	case 'power'
		sem.covv=(sem.node_timeseries)'*(sem.node_timeseries)./size(sem.node_timeseries,1);
	case 'corrcoef'
	    sem.covv=corrcoef(sem.node_timeseries);
	end

    idx_not_latent=find(sum(F,1));
    sem.covv=sem.covv(idx_not_latent,:);
    sem.covv=sem.covv(:,idx_not_latent);
    sem.n_obs=size(sem.node_timeseries,1);

elseif(~isempty(covv))
	if(flag_display)
		fprintf('No time series for nodes found!\n');
		fprintf('Explicit covariance matrix found! Calculating covariance matrix...\n');
	end;
	sem.node_timeseries=[];
    for i=1:length(node_name)
		for j=1:length(node_name)
	        for k=1:length(covv.name)
				for l=1:length(covv.name)
		            if(strcmp(node_name{i},covv.name{k})&strcmp(node_name{j},covv.name{l}))
						sem.covv(i,j)=covv.covv(k,l);
					end;
				end;
            end;
        end;
    end;
    idx_not_latent=find(sum(F,1));
    sem.covv=sem.covv(idx_not_latent,:);
    sem.covv=sem.covv(:,idx_not_latent);
	sem.n_obs=covv.n_obs;
    
else
	if(flag_display)
		fprintf('Neither timeseries for nodes nor covariance matrix among nodes!\n');
		fprintf('error!');
	end;
    sem.node_timeseries=[];
    sem.covv=[];
    return;
end;

if(flag_display)
	fprintf('<<SEM Preparation ends!>>\n');
end;
