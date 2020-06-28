function [y,res]=pmri_cs_forward(x,pmri_cs_obj,varargin);
%   pmri_cs_forward      calculate the forward solution y of the CS pMRI
%   using explicit or implicit forward matrix A and source x.
%
%   y=A*x
%
% [y,res]=pmri_cs_forward(x, pmri_cs_obj, [option, option_value]...);
%
% x: the source vector
% pmri_cs_obj: the object of CS pMRI including all parameters
%
% y: the theoretical measurement vector
% res: the residual error betweeen the actual measurement vector m and the
% theoretical measurement vector y.
%
% fhlin@sep 11 2009
%

A=[];
A_func='pmri_cs_forward_func_default';

y=[];
res=[];
m=[];

for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};    
        
        switch lower(option)
            case 'a' %explicit forward solution/matrix
                A=option_value;
            case 'a_func' %implicit forward solution/matrix
                A_func=option_value;
            case 'm' %actual measurement vector
                m=option_value;
            otherwise
                fprintf('unkown option [%s]\n',option);
                fprintf('error!\n');
                return;
        end;
end;

if(~isempty(A)) %explicitly given A
    y=A*x;
else %implicitly given A by functions
    eval(sprintf('y=%s(x,pmri_cs_obj);',A_func));
end;

if(~isempty(m))
    if(~iscell(m))
        res=y-m;
    else
        for m_idx=1:length(m)
            res{m_idx}=y{m_idx}-m{m_idx};
        end;
    end;
end;

return;
    
