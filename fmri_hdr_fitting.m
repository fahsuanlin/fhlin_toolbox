function [error,fitted]=fmri_hdr_fitting(param,data,t, t_oversample)

%defaults
a1=6;
a2=12;
b1=0.9;
b2=0.9;
c=0.35;

error=[];

a1=param(1);
a2=param(2);
b1=param(3);
b2=param(4);
c=param(5);

data=data(:);
d1=a1*b1;
d2=a2*b2;

if(~isempty(t_oversample))
    t1=min(t);
    t_diff=mean(diff(t))./t_oversample;
    t2=max(t);
    t=[t1:t_diff:t2];
end;

hdr0=(t./d1).^a1.*exp(-(t-d1)./b1);
hdr1=real(c*(t./d2).^a2.*exp(-(t-d2)./b2));
hdr=(hdr0-hdr1)';
idx=find(t<0);
hdr(idx)=0;
hdr1(idx)=0;
hdr0(idx)=0;

hdr=hdr(:);
hdr(find(isinf(hdr)))=0;
hdr(find(isnan(hdr)))=0;

% if(norm(hdr)>norm(data)./1e3);
%     error=inf;
%     fitted=zeros(size(data));
% else
%%    if(~isempty(find(isnan(hdr'*hdr)))) keyboard; end;
%%    if(~isempty(find(isinf(hdr'*hdr)))) keyboard; end;
%%    if(rank(hdr'*hdr)<min(size(hdr))) keyboard; end;
    if(~isempty(t_oversample))
        hh=hdr(1:t_oversample:end,:);
        tt=t(1:t_oversample:end);
    else
        hh=hdr;
        tt=t;
    end;
    
    %scale=inv(hh'*hh)*hh'*data(:);
    scale=pinv(hh)*data(:);
    fitted=hdr*scale;
    fitted_dec=hh*scale;

%    idx=find(tt<10);
%     idx=find(tt<10&tt>0);
     idx=find(tt<24&tt>0);

     error=(fitted_dec(idx)-data(idx))'*(fitted_dec(idx)-data(idx));
% end;

return;
