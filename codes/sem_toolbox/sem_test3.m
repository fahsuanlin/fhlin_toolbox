close all; clear all;

%Specify the connection. This matrix is what SEM is going to estimate. For
%simulation, we provide the answer first.
%   (node_A)     (node_B)   (node_C)   (node_D)  
A=[     0           0.2         0           0
    0.3           0           -0.1           0
    0           0.1         0           -0.5
    0           0       0           0];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up SEM connections
path(1).node_from{1}='B';
path(1).node_to{1}='A';
path(1).val=inf;
path(1).flag_uni{1}=1;

path(2).node_from{1}='A';
path(2).node_to{1}='B';
path(2).val=inf;
path(2).flag_uni{1}=1;

path(3).node_from{1}='B';
path(3).node_to{1}='C';
path(3).val=inf;
path(3).flag_uni{1}=1;

path(4).node_from{1}='C';
path(4).node_to{1}='B';
path(4).val=inf;
path(4).flag_uni{1}=1;

path(5).node_from{1}='D';
path(5).node_to{1}='C';
path(5).val=inf;
path(5).flag_uni{1}=1;

path(6).node_from{1}='';
path(6).node_to{1}='A';
path(6).flag_uni{1}=1;

path(7).node_from{1}='';
path(7).node_to{1}='B';
path(7).flag_uni{1}=1;

path(8).node_from{1}='';
path(8).node_to{1}='C';
path(8).flag_uni{1}=1;

path(9).node_from{1}='';
path(9).node_to{1}='D';
path(9).flag_uni{1}=1;

%specify the SEM nodes
sa=1.0;     % endogenous power of node_A
sb=1.0;     % endogenous power of node_B
sc=1.0;     % endogenous power of node_C
sd=1.0;     % endogenous power of node_D

sem_node(1).name='A';
sem_node(1).power=sa;
sem_node(1).flag_latent=0;

sem_node(2).name='B';
sem_node(2).power=sb;
sem_node(2).flag_latent=0;

sem_node(3).name='C';
sem_node(3).power=sc;
sem_node(3).flag_latent=0;

sem_node(4).name='D';
sem_node(4).power=sd;
sem_node(4).flag_latent=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulate SEM data
S=diag([sa sb sc sd]);
D=inv(eye(size(A))-A)*S*inv((eye(size(A))-A)');


%setup data covariance
covv.covv=D;
covv.name={'A','B','C','D'};
covv.n_obs=100;

%determine which paths go to endogenous sources
source_path_idx=[];
for p=1:length(path)
    if(isempty(path(p).node_from{1}))
        source_path_idx=cat(1,source_path_idx,p);
    end;
end;
non_source_path_idx=setdiff([1:length(path)],source_path_idx);

%initialize endogenous source paths here
for i=1:length(sem_node)
    for p=1:length(source_path_idx)
        if(strcmp(path(source_path_idx(p)).node_to,sem_node(i).name))
            path(source_path_idx(p)).val=sqrt(sem_node(i).power);
            sem_node(i).timeseries=[];
        end;
    end;
end;

%initialize other paths here
for i=1:length(non_source_path_idx)
    path(non_source_path_idx(i)).path_val_init=0.0;
end;

%prepare SEM estimation
sem_input=sem_prep('path',path,'node',sem_node,'flag_display',1,'cov_format','power','covv',covv);

%perform SEM estimation
sem_output=sem_core('sem',sem_input,'flag_display',1,'obj_type','ml');

%summarize output
for i=1:length(non_source_path_idx)
    fprintf('path(%d) : [%s] --> [%s] : %2.2f\n',non_source_path_idx(i),path(non_source_path_idx(i)).node_from{1}, path(non_source_path_idx(i)).node_to{1}, sem_output.path_val_opt(non_source_path_idx(i)));
end;