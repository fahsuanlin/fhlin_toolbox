function [x]=etc_cg(A,y,varargin)

flag_display=0;
x0=[];
max_iteration=[];
ratio_iteration=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
    case 'flag_display'
        flag_display=option_value;
    case 'x0'
        x0=option_value;
    case 'max_iteration'
        max_iteration=option_value;
    case 'ratio_iteration'
        ratio_iteration=option_value;
    end;
end;

iteration_idx=1;
cont=1;

%%%%%%%% initialize CG  %%%%%%%%%%%%
if(flag_display) fprintf('CG initializing...\n'); end;

[n,n]=size(A);      %A should be symmetric

if(isempty(x0))
    x = zeros(n,1); x(1) = 1;
else
    x=x0;
end;

g = A*x - y;
d = -g;

%%%%%%%%  CG  %%%%%%%%%%%%
if(flag_display) fprintf('CG start...\n'); end;
while(cont)
    
    if(flag_display) fprintf('CG iteration [%d] ', iteration_idx); end;
    
    alpha = -g'*d/(d'*A*d);
    x = x + alpha*d;
    
    g = A*x - y;
    beta = g'*A*d/(d'*A*d);
    d = -g + beta*d;
    
    x_power(iteration_idx)=norm(x);
    
    %if(flag_display) plot(x_power); end;
    
    
    %calculate the relative change of the power of the solution
    if(iteration_idx > 1)
        x_power_ratio(iteration_idx)=norm(x_power(iteration_idx)-x_power(iteration_idx-1))/norm(x_power(iteration_idx));
    else
        x_power_ratio(iteration_idx)=1;
    end;
    
    if(flag_display) fprintf('power change [%2.2f%%]', x_power_ratio(iteration_idx)*100.0); end;
    
    %stop the iteration if the change of the power of the solutio is stable
    if(~isempty(ratio_iteration))
        if(x_power_ratio(iteration)<=ratio_iteration)
            cont=0;
        end;
    end;
    
    %stop the iteration if the iteration exceeds the specified iteration
    if(~isempty(max_iteration))
        
        if(iteration_idx>=max_iteration)
            cont=0;
        end;
    end;
    
    %stop the iteration if the iteration exceeds the maximal iteration
    if(iteration_idx>=n)
        cont=0;
    end;
    
    
    if(cont)
        iteration_idx=iteration_idx+1;
    end;
    
    if(flag_display) fprintf('..\n'); end;
    
end
if(flag_display) fprintf('CG end.\n'); end;
