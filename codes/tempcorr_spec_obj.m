function [f]=tempcorr_spec_obj(phi_free,phi_fix,flag_free_real,flag_free_imag,S_p,varargin)
% tempcorr_spec_obj   Objective function to be minimized in temporally
% correlated spectroscopy reconstruction
%
% f=tempcorr_spec_obj(phi_free,phi_fix,flag_free_real,flag_free_imag,S_p)
%
% phi_free: free coefficients; the real part deontes 1./T2 and the imag. part denots w0;
% phi_fix: fixed coefficients; the real part deontes 1./T2 and the imag. part denots w0;
% flag_free_real: a flag enables/disables T2 fitting
% flag_free_imag: a flag enables/disables w0 fitting
% S_p: sample covariance
%
% fhlin@oct. 11, 2006

dT=894.*1e-6; %894 us for 32x32 pepsi


if(nargin>3)
	for i=1:ceil(length(varargin)/2)
		option=varargin{i*2-1};
		option_value=varargin{i*2};

		switch lower(option)
		case 'dT'
			dT=option_value;
		end;
	end;
end;

if(flag_free_real)
    T2=phi_free(1);
else
    T2=phi_fix(1);
end;

if(flag_free_real)
    w0=phi_free(2);
else
    w0=phi_fix(2);
end;


phi_p=exp(-dT/T2+sqrt(-1).*w0.*dT);

theta_p=[1; -2.*phi_p; phi_p.^2];

f=abs((theta_p'*S_p*theta_p)./(theta_p'*theta_p));

return;


