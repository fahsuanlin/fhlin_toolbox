function [buffer]=fmri_scale(data,varargin)
%fmri_scale	scale the 2D/3D data between max and min
%
%[scaled_data]=fmri_scale(data,max,min)
%
%
%data: the raw 2D/3D data to be linearly scaled
%max: max of the scale
%min: min of the scale
%
%NOTE: default is: max=65535, min=0
%
%written by fhlin@aug. 28, 1999

data_real=1;
if(~isreal(data))
    data=abs(data);
    data_real=0;
end;

if nargin==1
    mmax=65535;
    mmin=0;
    mask=[];
end;

if nargin==2
    mmax=varargin{1};
    mmin=0;
    mask=[];
end;

if nargin==3
    mmax=varargin{1};
    mmin=varargin{2};
    mask=[];
end;

if nargin==4
    mmax=varargin{1};
    mmin=varargin{2};
    mask=varargin{3};
end;


if(isempty(mask))
    maxx=data;
    minn=data;
else
    msk=zeros(size(mask));
    msk(find(mask(:)))=1;
    maxx=data.*msk;
    minn=data.*msk;
end;

for i=1:ndims(data)
    maxx=max(maxx);
    minn=min(minn);
end;

if(data_real)
    if((maxx-minn)>eps.*10)
        buffer=(data-minn).*(mmax-mmin)./(maxx-minn)+mmin;
    else
        buffer=maxx;
    end;
else
    if((maxx-minn)>eps.*10)
        buffer=(data-minn).*(mmax-mmin)./(maxx-minn)+mmin;
    else
        buffer=maxx;
    end;
    %imagesc(buffer);
    %pause;
end;

