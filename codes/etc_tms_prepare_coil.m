function [status, strcoil, P, t, tind]=etc_tms_prepare_coil(tms_coil_name, varargin)
%
% etc_tms_prepare_coil: prepare an TMS coil for TMS
% e-field modeling
%
% tms_coil_name: the name of TMS coil. The following options are available:
%   MagVenture_MRiB91
%   MagVenture_Cool_B35
%   MagVenture_D_B80
%   MagVenture_C_B60
%   FigureEight
%   SingleRung
%   SingleRing
%
% fhlin@June 11 2024

%coil object to be modeled...
strcoil=[];

%coil object to be visualized...
P=[];
t=[];
tind=[];

status=0;

flag_display=1;
flag_save=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'flag_save'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


switch tms_coil_name

    case 'MagVenture_MRiB91'
        %   The figure-eight coil includes elliptical turns/loops. The coil axis is
        %   the z-axis. We construct one part of the coil first.
        %   When crossing the xz-plane, the i   ntersection points for the loop
        %   centerlines are
        x0  = 1e-3*[20.2500   25.7500   31.2500   36.7500   ...
            20.2500   25.7500   31.2500   36.7500];
        %   When crossing the yz-plane, the intersection points for the loop
        %   centerlines are
        y0  = 1e-3*[28.7500   34.2500   39.7500   45.2500  ...
            28.7500   34.2500   39.7500   45.2500];
        %   When crossing the xz- or yz-planes, the intersection points for the
        %   loop centerlines are (this is a z-offset)
        z0  = 1e-3*[-4.6000   -4.6000   -4.6000   -4.6000  ...
            4.6000    4.6000    4.6000    4.6000];

        %   Other parameters
        a    = 3.50e-3;     %   z-side, m  (for a rectangle cross-section)
        b    = 2.20e-3;     %   x-side, m  (for a rectangle cross-section)
        M    = 32;          %   number of cross-section subdivisions
        N    = 128;          %   number of perimeter subdivisions
        flag = 2;           %   rectangular cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Construct the coil mesh for one part
        [Pwire, Ewire, Swire, P, t, tind] = meshcoil(x0, y0, z0, M, N, a, b, flag, sk);

        %   Construct the entire coil as a combination of two parts
        %   Separate two coils along the x-axis
        offset = -39.5e-3;
        Pwire1 = Pwire; Pwire1(:, 1) = Pwire1(:, 1) - offset;
        Pwire2 = Pwire; Pwire2(:, 1) = Pwire2(:, 1) + offset;
        Ewire1 = Ewire;
        Ewire2 = Ewire+size(Pwire, 1);

        strcoil.Pwire = [Pwire1; Pwire2];
        strcoil.Pwire(:, 3) = strcoil.Pwire(:, 3) - min(strcoil.Pwire(:, 3));
        strcoil.Ewire = [Ewire1; Ewire2];
        strcoil.Swire = [+Swire; -Swire]; %  swap current direction for the second part

        P1 = P; P1(:, 1) = P(:, 1) - offset;
        P2 = P; P2(:, 1) = P(:, 1) + offset;
        t1 = t;
        t2 = t+size(P, 1);
        P = [P1; P2];
        P(:, 3) = P(:, 3) - min(P(:, 3));
        t    = [t1; t2];
        tind = [tind; tind+max(tind)];

    case 'MagVenture_Cool_B35'

        %   The coil is in the form of two non-interconnected spiral arms. The
        %   conductor centerline model is given first
        turns = 32;
        theta = [0:pi/20:turns*2*pi-pi/2];
        a0 = 0.0115; b0 = (23e-3 - a0)/(turns*2*pi-pi/2);
        r = a0 + b0*theta;                 %   Archimedean spiral
        x = r.*cos(theta);                 %   first half
        y = r.*sin(theta);                 %   first half

        % plot(x, y, '*-'); axis equal; grid on; title('Conductor centerline');
        % return

        %   Other parameters
        a    = 15e-3;       %   z-side, m  (for a rectangle cross-section)
        b    = 0.2e-3;      %   x-side, m  (for a rectangle cross-section)
        M    = 20;          %   number of cross-section subdivisions
        flag = 2;           %   rect. cross-section
        sk   = 0;           %   Litz wire

        %   Create CAD and wire models for the single conductor
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = y';
        Pcenter(:, 3) = a/2;
        strcoil       = meshwire(Pcenter, a, b, M, flag, sk);
        [P, t]        = meshsurface(Pcenter, a, b, M, flag);  %   CAD mesh (optional, slow)
        tind          = 1*ones(size(t, 1), 1);

        Ewire       = [];
        Pwire       = [];
        Swire       = [];
        Pa          = [];
        ta          = [];

        %   Construct two CAD and wire models
        strcoil.Swire       = [strcoil.Swire; strcoil.Swire];
        strcoil.Ewire       = [strcoil.Ewire; strcoil.Ewire+size(strcoil.Pwire, 1)];
        Pwire1              = strcoil.Pwire;
        Pwire2              = strcoil.Pwire;
        Pwire1(:, 1)        = -Pwire1(:, 1);
        Pwire1(:, 1)        = Pwire1(:, 1) - 23e-3;
        Pwire2(:, 1)        = Pwire2(:, 1) + 23e-3;
        strcoil.Pwire       = [Pwire1; Pwire2];
        strcoil.Pwire(:, 3) = strcoil.Pwire(:, 3) - min(strcoil.Pwire(:, 3));

        t          = [t; t+size(P, 1)];
        tind       = [tind; 2*tind];
        P1         = P;
        P2         = P;
        P1(:, 1)   = -P1(:, 1);
        P1(:, 1)   = P1(:, 1) - 23e-3;
        P2(:, 1)   = P2(:, 1) + 23e-3;
        P          = [P1; P2];
        P(:, 3)    = P(:, 3) - min(P(:, 3));

    case 'MagVenture_D_B80'
        %   The coil is in the form of two interconnected spiral arms. The
        %   conductor centerline model is given first

        %%   First arm
        theta = [8*pi/2:pi/50:12*pi];
        a0 = 0.024; b0 = 0.00061;
        r = a0 + b0*theta;                  %   Archimedean spiral
        x1 = r.*cos(theta);                 %   first half
        y1 = r.*sin(theta);                 %   first half
        x2 = 2*x1(end) - x1(end-1:-1:1);    %   second half
        y2 = 2*y1(end) - y1(end-1:-1:1);    %   second half
        x = [x1 x2];  y = [y1 y2];          %   join both halves
        x = x - mean(x);                    %   center the curve

        % plot(x, y, '*-'); axis equal; grid on; title('Conductor centerline')

        %   Other parameters
        a    = 6.0e-3;     %   z-side, m  (for a rectangle cross-section)
        b    = 2.0e-3;     %   x-side, m  (for a rectangle cross-section)
        M    = 20;          %   number of cross-section subdivisions
        flag = 2;           %   rect. cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Create CAD and wire models for the single conductor
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = y';
        Pcenter(:, 3) = -a/2;
        strcoil1       = meshwire(Pcenter, a, b, M, flag, sk);
        [P1, t1]        = meshsurface(Pcenter, a, b, M, flag);  %   CAD mesh (optional, slow)
        tind1          = 1*ones(size(t1, 1), 1);

        %%   Second arm
        theta = [8*pi/2:pi/50:10*pi];
        a0 = 0.027; b0 = 0.00061;
        r = a0 + b0*theta;                  %   Archimedean spiral
        x1 = r.*cos(theta);                 %   first half
        y1 = r.*sin(theta);                 %   first half
        x2 = 2*x1(end) - x1(end-1:-1:1);    %   second half
        y2 = 2*y1(end) - y1(end-1:-1:1);    %   second half
        x = [x1 x2];  y = [y1 y2];          %   join both halves
        x = x - mean(x);                    %   center the curve

        % plot(x, y, '*-'); axis equal; grid on; title('Conductor centerline')

        %   Other parameters
        a    = 6.0e-3;     %   z-side, m  (for a rectangle cross-section)
        b    = 2.0e-3;     %   x-side, m  (for a rectangle cross-section)
        M    = 20;          %   number of cross-section subdivisions
        flag = 2;           %   rect. cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Create CAD and wire models for the single conductor
        clear Pcenter;
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = -y';
        Pcenter(:, 3) = +a/2;
        strcoil2       = meshwire(Pcenter, a, b, M, flag, sk);
        [P2, t2]      = meshsurface(Pcenter, a, b, M, flag);  %   CAD mesh (optional, slow)
        tind2         = 2*ones(size(t2, 1), 1);

        %%  Create the complete model
        Ewire       = [];
        Pwire       = [];
        Swire       = [];
        Pa          = [];
        ta          = [];

        %   Construct two CAD and wire models
        strcoil.Swire       = [strcoil1.Swire; -strcoil2.Swire];
        strcoil.Ewire       = [strcoil1.Ewire; strcoil2.Ewire+size(strcoil1.Pwire, 1)];
        strcoil.Pwire       = [strcoil1.Pwire; strcoil2.Pwire];
        strcoil.Pwire(:, 3) = strcoil.Pwire(:, 3) - min(strcoil.Pwire(:, 3));

        t          = [t1; t2+size(P1, 1)];
        tind       = [tind1; tind2];
        P          = [P1; P2];
        P(:, 3)    = P(:, 3) - min(P(:, 3));

        %   Deform the entire structure
        alpha = pi/6;
        strcoil.Pwire(:, 3) = strcoil.Pwire(:, 3) - sin(alpha)*abs(strcoil.Pwire(:, 1));
        strcoil.Pwire(:, 1) =                       cos(alpha)*strcoil.Pwire(:, 1);
        P(:, 3)             = P(:, 3) - sin(alpha)*abs(P(:, 1));
        P(:, 1)             =           cos(alpha)*P(:, 1);

    case 'MagVenture_C_B60'
        %   The coil is in the form of two interconnected spiral arms. The
        %   conductor centerline model is given first
        theta = [3*pi/2:pi/25:12*pi];
        a0 = 0.017; b0 = 0.0006;
        r = a0 + b0*theta;                  %   Archimedean spiral
        x1 = r.*cos(theta);                 %   first half
        y1 = r.*sin(theta);                 %   first half
        x2 = 2*x1(end) - x1(end-1:-1:1);    %   second half
        y2 = 2*y1(end) - y1(end-1:-1:1);    %   second half
        x = [x1 x2];  y = [y1 y2];          %   join both halves
        x = x - mean(x);                    %   center the curve
        P(:, 1) = x; P(:, 2) = y; P(:, 3) = 0;
        P = meshrotate2(P, [0 0 1], +0.04);
        x = P(:, 1); y = P(:, 2);

        %plot(x, y, '*-'); axis equal; grid on; title('Conductor centerline')

        %   Other parameters
        a    = 3.60e-3;     %   z-side, m  (for a rectangle cross-section)
        b    = 2.61e-3;     %   x-side, m  (for a rectangle cross-section)
        M    = 20;          %   number of cross-section subdivisions
        flag = 2;           %   rect. cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Create CAD and wire models for the single conductor
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = y';
        Pcenter(:, 3) = a/2;
        strcoil       = meshwire(Pcenter, a, b, M, flag, sk);
        [P, t]        = meshsurface(Pcenter, a, b, M, flag);  %   CAD mesh (optional, slow)
        tind          = 1*ones(size(t, 1), 1);

        Ewire       = [];
        Pwire       = [];
        Swire       = [];
        Pa          = [];
        ta          = [];

        %   Construct two CAD and wire models
        strcoil.Swire       = [strcoil.Swire; strcoil.Swire];
        strcoil.Ewire       = [strcoil.Ewire; strcoil.Ewire+size(strcoil.Pwire, 1)];
        Pwire               = strcoil.Pwire;
        Pwire(:, 3)         = Pwire(:, 3) + 9.2e-3;
        strcoil.Pwire       = [strcoil.Pwire; Pwire];
        strcoil.Pwire(:, 3) = strcoil.Pwire(:, 3) - min(strcoil.Pwire(:, 3));

        t          = [t; t+size(P, 1)];
        tind       = [tind; 2*tind];
        Pup        = P;
        Pup(:, 3)  = Pup(:, 3) + 9.2e-3;
        P          = [P; Pup];
        P(:, 3)    = P(:, 3) - min(P(:, 3));
    case 'FigureEight'
        %   The coil includes one single conductor in the form of two
        %   interconnected spiral arms. The conductor centerline model is given
        %   first
        theta = [0:pi/25:10*pi];
        a0 = 0.03; b0 = 0.0006;
        r = a0 + b0*theta;                  %   Archimedean spiral
        x1 = r.*cos(theta);                 %   first half
        y1 = r.*sin(theta);                 %   first half
        x2 = 2*x1(end) - x1(end-1:-1:1);    %   second half
        y2 = 2*y1(end) - y1(end-1:-1:1);    %   second half
        x = [x1 x2];  y = [y1 y2];          %   join both halves
        x = x - mean(x);                    %   center the curve

        %   Other parameters
        a    = 0.002;       %   conductor diameter
        M    = 16;          %   number of cross-section subdivisions
        flag = 1;           %   circular cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Create CAD and wire models for the single conductor
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = y';
        Pcenter(:, 3) = a/2;
        strcoil       = meshwire(Pcenter, a, a, M, flag, sk); % Wire model
        [P, t]        = meshsurface(Pcenter, a, a, M, flag);  % CAD mesh (optional, slow)
        tind          = ones(size(t, 1), 1);

    case 'SingleRung'
        %   The coil includes one single conductor in the form of a straight segment.
        %   The conductor centerline model is given first
        par = linspace(0, 1, 100);
        L   = 0.02;                         %   conductor length in m
        x = L*par;                          %   segment
        y = 0*par;                          %   segment

        %   Other parameters
        a    = 0.002;       %   conductor diameter in m
        M    = 16;          %   number of cross-section subdivisions
        flag = 1;           %   circular cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Create CAD and wire models for the single conductor
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = y';
        Pcenter(:, 3) = a/2;
        strcoil       = meshwire(Pcenter, a, a, M, flag, sk); % Wire model
        [P, t]        = meshsurface(Pcenter, a, a, M, flag);  % CAD mesh (optional, slow)
        tind          = ones(size(t, 1), 1);

    case 'SingleRing'
        %   The coil includes one single conductor in the form of a ring.
        %   The conductor centerline model is given first
        theta = [0:pi/50:2*pi];
        r = 0.02;                          %   ring radius in m
        x = r.*cos(theta);                 %   ring
        y = r.*sin(theta);                 %   ring

        %   Other parameters
        a    = 0.002;       %   conductor diameter in m
        M    = 16;          %   number of cross-section subdivisions
        flag = 1;           %   circular cross-section
        sk   = 1;           %   surface current distribution (skin layer)

        %   Create CAD and wire models for the single conductor
        Pcenter(:, 1) = x';
        Pcenter(:, 2) = y';
        Pcenter(:, 3) = a/2;
        strcoil       = meshwire(Pcenter, a, a, M, flag, sk); % Wire model
        [P, t]        = meshsurface(Pcenter, a, a, M, flag);  % CAD mesh (optional, slow)
        tind          = ones(size(t, 1), 1);
    otherwise
        fprintf('unknown TMS coil [%s]. Error!\n',tms_coil_name);
        return;


end;

%fprintf('TMS coil model [%s] created. Saving [coil.mat] and [coilCAD.mat]...\n',app.TMSCoilDropDown.Value);
%app.TextArea.Value{end+1}=sprintf('TMS coil model [%s] created. Saving [coil.mat] and [coilCAD.mat]...\n',app.TMSCoilDropDown.Value);

if(flag_save)
    if(flag_display)
        fprintf('saving [coil.mat] (strcoil object for e-field modeling) and [coilCAD.mat] (for visualization).\n');
    end;
    save('coil', 'strcoil');
    save('coilCAD', 'P', 't', 'tind');  %   optional, slow
end;

status=1;