function hdr=fmri_hdr(t,varargin)
% fmri_hdr_template	hemodynamic responses
%
% hdr=fmri_hdr(t)
%
% t: 1-d vector of time indices (in second)
% hdr: output hemodynamic response waveform
%
% fhlin@Nov. 1, 2001
hdr=[];

%defaults
hdr_type='standard';
hdr_order=2;


if(nargin>1)
    for i=1:length(varargin)/2
        option_name=varargin{(i-1)*2+1};
        option_value=varargin{i*2};
        
        switch lower(option_name)
            case 'hdr_type'
                hdr_type=option_value;
            case 'hdr_order'
                hdr_order=option_value;
            case 'hdr_support'
                hdr_support=option_value;
            otherwise
                fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
                return;
        end;
    end;
end;

switch lower(hdr_type)
    case	'standard'
        hdr=fmri_hdr_template(t,hdr_order);
    case 	'legendre'
        hdr=fmri_pls_legendre(hdr_order,t,[min(t),max(t)]);
    case    'db'
        res_enhance=ceil(log(length(t))/log(2))-ceil(log(hdr_support)/log(2));
        hdr=wavelet_dbbasis(hdr_support,ceil(log(hdr_support)/log(2))-hdr_order+1,res_enhance);
    case 'fir'
        hdr=eye(length(t));
    case 'spm'
        a=6; b=1; c=16; d=1;
        hdr=1./(gamma(a).*b.^a).*t.^(a-1).*exp(-t./b)-1./(gamma(c).*d.^c).*t.^(c-1).*exp(-t./d);
    case 'single_gamma'
        a=6; b=1; 
        hdr=1./(gamma(a).*b.^a).*t.^(a-1).*exp(-t./b);
end;
