function [M, Z_mn]=etc_mom_zmn(l1_start, l1_end, l2_start, l2_end,varargin)

M=[];
Z_mn=[];

%f=128e6; %Hz; pronton precession at 3T
f=[];
mu=1.256e-6; %permeability of vaccum

for i=1:length(varargin)./2
    option=varargin{i.*2-1};
    option_value=varargin{i.*2};
    switch lower(option)
        case 'mu'
            mu=option_value;
        case 'f'
            f=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

%frequency
w=2.*pi.*f;

%wave number
k=2*pi*f./3e8; %free spaec wave number

%current path lengths
cm=norm(l1_end-l1_start);
cn=norm(l2_end-l2_start);

%directiobal unit vectors
em=(l1_end-l1_start)./cm;
en=(l2_end-l2_start)./cm;

syms t

int_I1=etc_mom_i1(t,l1_start, l1_end, l2_start, l2_end);
%int_I1=integral(F1,0,1, 'ArrayValued',1); 

F2=etc_mom_i2(t,l1_start, l1_end, l2_start, l2_end);
int_I2=integral(F2,0,1, 'ArrayValued',1); 

int_I3=etc_mom_i3(t,l1_start, l1_end, l2_start, l2_end);
%int_I3=integral(F3,0,1, 'ArrayValued',1)

int_I4=etc_mom_i4(t,l1_start, l1_end, l2_start, l2_end);
%int_I4=integral(F4,0,1, 'ArrayValued',1) 

Z_mn=(em(:)'*en(:)).*sqrt(-1).*w.*mu./4./pi.*(cn.*cm).*(int_I1-sqrt(-1).*k.*int_I2-k.^2./2.*int_I3+sqrt(-1).*k.^3./6.*int_I4); %mutual inductance; current path widths are neglected.


if(~isempty(k))
    M=(em(:)'*en(:)).*mu./4./pi.*(cn.*cm).*(int_I1-sqrt(-1).*k.*int_I2-k.^2./2.*int_I3+sqrt(-1).*k.^3./6.*int_I4); %mutual inductance; current path widths are neglected.

else
    M=(em(:)'*en(:)).*mu./4./pi.*(cn.*cm).*(int_I1);
end;

if(~isempty(f))
    Z_mn=sqrt(-1).*w.*M;
end;

return;