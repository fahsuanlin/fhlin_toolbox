function [y, pmri_cs_obj]=pmri_cs_sparsify(x,pmri_cs_obj,varargin);
%   pmri_cs_sparsify      calculate the sparsifying transformed y using 
%   explicit or implicit sparsifying matrix S and source x.
%
%   y=S*x
%
% [y]=pmri_cs_S(x, pmri_cs_obj,[option, option_value]...);
%
% x: the source vector
% pmri_cs_obj: the object of CS pMRI including all parameters
%
% y: the theoretical measurement vector
%
% fhlin@sep 11 2009
%

S=[];
S_func='pmri_cs_sparsify_func_default';

y=[];

for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};    
        
        switch lower(option)
            case 's' %explicit sparsifying solution/matrix
                S=option_value;
            case 's_func' %implicit sparsifying solution/matrix
                S_func=option_value;
            otherwise
                fprintf('unkown option [%s]\n',option);
                fprintf('error!\n');
                return;
        end;
end;

if(~isempty(S)) %explicitly given S
    y=S*x;
else %implicitly given S by functions
    eval(sprintf('[y, pmri_cs_obj]=%s(x, pmri_cs_obj);',S_func));
end;
    
return;
    