function hdr=fmri_hdr_template(t,varargin)
% fmri_hdr_template	hemodynamic response from Glover, 1999 (NeuroImage, 9,:416-429)
% 
% hdr=fmri_hdr_template(t)
% 
% t: 1-d vector of time indices (in second)
% hdr: output hemodynamic response waveform
%
% fhlin@Nov. 1, 2001


order=1;

if(nargin==2)
	order=varargin{1};
end;

a1=6;
a2=12;

b1=0.9;
b2=0.9;
c=0.35;
d1=a1*b1;
d2=a2*b2;

hdr0=(t./d1).^a1.*exp(-(t-d1)./b1);
hdr1=c*(t./d2).^a2.*exp(-(t-d2)./b2);
hdr=(hdr0-hdr1)';


%derivative
hdr0_d=a1/d1*(t./d1).^(a1-1).*exp(-(t-d1)./b1)-1/b1.*(t./d1).^a1.*exp(-(t-d1)./b1);
hdr1_d=c*a2/d2*(t./d2).^(a2-1).*exp(-(t-d2)./b2)-c*1/b2.*(t./d2).^a2.*exp(-(t-d2)./b2);
hdr_d=(hdr0_d-hdr1_d)';

if(order==1)
	return;
end;
if(order==2)
	hdr=[hdr,hdr_d];
end;
if(order>2)
    hdr=[hdr,hdr_d];
    for order_idx=3:order
        tmp=diff(hdr_d);
        tmp(end+1)=0;
        hdr=cat(2,hdr,tmp);
        hdr_d=tmp;
    end;
end;