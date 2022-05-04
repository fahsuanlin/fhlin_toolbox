function [y]=pmri_cs_TV(x,pmri_cs_obj,varargin);
%   pmri_cs_TV      calculate the total variation y using 
%   explicit or implicit TV matrix TV and source x.
%
%   y=TV*x
%
% [y]=pmri_cs_TV(x,[option, option_value]...);
%
% x: the source vector
%
% y: the theoretical measurement vector
%
% fhlin@sep 11 2009
%

TV=[];
TV_func='pmri_cs_TV_func_default';

y=[];

for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};    
        
        switch lower(option)
            case 'tv' %explicit sparsifying solution/matrix
                TV=option_value;
            case 'tv_func' %implicit sparsifying solution/matrix
                TV_func=option_value;
            otherwise
                fprintf('unkown option [%s]\n',option);
                fprintf('error!\n');
                return;
        end;
end;

if(~isempty(TV)) %explicitly given TV
    y=TV*x;
else %implicitly given TV by functions
    eval(sprintf('y=%s(x);',TV_func));
end;
    
return;
    