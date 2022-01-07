function Z_mm=etc_mom_zmm(l_start, l_end, width, varargin)

Z_mm=[];

f=128e6; %Hz; pronton precession at 3T
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
k=w./3e8; %free spaec wave number

width=width./2; %half of current path width
l = norm(l_end-l_start)./2; %half of current path length
%%%%%%%%%%%% self inductance integral definition and calculation %%%%%%
syms z 
int_J1 = @(z, l, width)(l+z)./width.*log((sqrt(width.^2+(l+z).^2)+width)./(l+z))+log(sqrt(1+(l+z).^2./width./width)+(l+z)./width)+(l-z)./width.*log((sqrt(width.^2+(l-z).^2)+width)./(l-z))+log(sqrt(1+(l-z).^2./width./width)+(l-z)./width);
int_J32 = @(z, l, width)width.^3.*(1./3.*(l+z).^3./width.^3.*log((sqrt((l+z).^2+width.^2)+width)./(l+z))+(l+z)./width./12.*sqrt(1+(l+z).^2./width.^2)-1./12.*log((l+z)./width+sqrt(1+(l+z).^2./width.^2)));
int_J33 = @(z, l, width)width.^3.*(1./3.*(l-z).^3./width.^3.*log((sqrt((l-z).^2+width.^2)+width)./(l-z))+(l-z)./width./12.*sqrt(1+(l-z).^2./width.^2)-1./12.*log((l-z)./width+sqrt(1+(l-z).^2./width.^2)));

J1=2.*width.* integral(@(z)int_J1(z,l,width),-l,l, 'ArrayValued',1); %width: current path width; l: current path length (linear)
J2=8.*width.*l.*l; %width: current path width; l: current path length (linear)
J3=width.^4.*(1./3.*sqrt((1+(2.*l./width).^2).^3)+2.*l*l./width.*log(2.*l./width+sqrt(1+(2.*l./width).^2))-sqrt(1+(2.*l./width).^2))+ integral(@(z)int_J32(z,l,width),-l,l, 'ArrayValued',1)+ integral(@(z)int_J33(z,l,width),-l,l, 'ArrayValued',1);  %width: current path width; l: current path length (linear)
J4=8./3.*(width.^3.*l^2+width.*width.*l.^4); %width: current path width; l: current path length (linear)

%Z_mn=sqrt(-1).*w.*mu./4./pi.*(cn.*cm).*(int_I1-sqrt(-1).*k.*int_I2-k.^2./2.*int_I3+sqrt(-1).*k.^3./6.*int_I4); %mutual inductance; current path widths are neglected.

Z_mm=sqrt(-1).*w.*mu./4./pi.*(J1-sqrt(-1).*k.*J2-k.^2./2.*J3+sqrt(-1).*k.^3./6.*J4); %self inductance; current path width must be provided.

%Z_mm=sqrt(-1).*w.*mu./4./pi.*(J1);

return;