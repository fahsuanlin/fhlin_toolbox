function [S]=etc_phasescramble(x, varargin)
% etc_phasescramble scramble the phase of a 1-D or 2-D signal
%
% [scrambled]=etc_phasescramble(x)
%
% x: input 1-D/2-D signal
% scrambled: output 1-D/2-D signal after phase scrambling
%
% To specifiy the dimension for scrambling, use "dim" option. For example
% etc_phasecramble(x,'dim',2) scrambles the data across "columns"
%
% The default value for "dim" is 1 (scrambling along the column dimension).
%
% fhlin@Mar 21 2018
%

dim=[];
S=[];
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'dim'
            dim=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

[nr,nc]=size(x);
if(isempty(dim))
    if(nr==1)
        dim=2;
    elseif(nc==1)
        dim=1;
    else
        dim=1;
    end;
end;

if(dim==2)
    x=x.';
end;

for idx=1:size(x,2)
    
    fx=fft(x(:,idx));
    fscrambled=fx;
    
    if(mod(length(x),2)==1)
        a=angle(fscrambled(2:(size(x,1)+1)/2));
        tmp=randperm(length(a));
        a=a(tmp); %randmized phase
        b=-flipud(a);
        fscrambled(2:end)=abs(fscrambled(2:end)).*exp(sqrt(-1).*[a(:); b(:)]);
    else
        a=angle(fscrambled(2:size(x,1)/2));
        tmp=randperm(length(a));
        a=a(tmp); %randmized phase
        c=angle(fscrambled(size(x,1)/2+1));
        b=-flipud(a);
        fscrambled(2:end)=abs(fscrambled(2:end)).*exp(sqrt(-1).*[a(:); c; b(:)]);
        
    end;
    
    scrambled=real(ifft(fscrambled)); %enforce real-valued output
    %scrambled=reshape(scrambled,[nr,nc]);
    
    S(:,idx)=scrambled;
end;

if(dim==2)
    S=S.';
end;
return;
