function out=etc_shift(im,sh,varargin)
% etc_shift     shift n-dimensional data
%
%   out=etc_shift(im,sh,[dim])
%
%   im: input n-dimensional data
%   sh: number of shifting
%   dim: shifting dimension; default is 1;
%
% fhlin@nov. 28, 2001
%

if(nargin==3)
    dim=varargin{1};
else
    dim=1;
end;


ee=size(im,dim);
idx=mod((1:ee)-sh-1,ee)+1;

cmd=sprintf('out=im(');
for i=1:ndims(im)
    if(dim==i)
        cmd=sprintf('%s[%s]',cmd,num2str(idx));
    else
        cmd=sprintf('%s:',cmd);
    end;
    if(i~=ndims(im))
        cmd=sprintf('%s,',cmd);
    else
        cmd=sprintf('%s);',cmd);
    end;
end;

eval(cmd);

return;


