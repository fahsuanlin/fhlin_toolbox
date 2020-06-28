function [Trapezoid]=ice_trapezoid_init(lRamp,lFlat,lADC,lNx,lSinusoidal_Ramps)

% % typedef struct
% % {
% %   long NxRegrid;                 // # points to regrid
% %   float *regrid_density;         // local density of points (per point)
% %   short *regrid_numberNeighbors; // # of neighbors inside convolution kernel (per point)
% %   float **regrid_convolve;       // weighting factor for each neighbor (per point, per neighbor)
% %   short **regrid_neighbor;       // list of neighboring points (per point,per neighbor)
% %   FCOMPLEX *regrid_rolloff;      // rolloff correction factor (per point)
% %   FCOMPLEX *regrid_workingSpace; // space for copying each line (per point)
% % } REGRID;
% % 
% % REGRID Trapezoid;

regrid_width = 3.5;
regrid_sigma = 4.91;

Trapezoid.NxRegrid=0;


Trapezoid.NxRegrid = lNx;

if(isempty(lFlat)) lFlat=0; end;

%// Determine the k-space coordinates as defined by the a sampling scheme
%// that starts at time lDelaySampling and continues for time lADCDuration
%// as a trapezoidal waveform plays out using the ramp and flat time as passed.
if ( lSinusoidal_Ramps )
    renormalize = double(lFlat) + 4./pi*double(lRamp)*sin(pi/2.*(double(lADC)/2.-double(lFlat)/2.)/double(lRamp));
else
    renormalize = lADC - double( (lADC-lFlat)*(lADC-lFlat) ) / 4./double(lRamp);
end;

renormalize = renormalize / double(Trapezoid.NxRegrid-1);
delta_time = double(lADC) / double(Trapezoid.NxRegrid-1);

kRaw = zeros(Trapezoid.NxRegrid,1);
%// Assign positive k-space values.  Note that the max value is (Trapezoid.NxRegrid-1)/2.
for j=Trapezoid.NxRegrid/2:Trapezoid.NxRegrid-1
    time = delta_time * ( j-Trapezoid.NxRegrid/2 + 0.5 );
    if ( time < lFlat/2 )
        kRaw(j+1) = time;
    else
        if ( lSinusoidal_Ramps )
            kRaw(j+1) = (lFlat)/2. + 2./pi*(lRamp)*sin(pi/2.*(time-lFlat/2.)/lRamp);
        else
            kRaw(j+1) = time - ( (time-lFlat/2)*(time-lFlat/2) ) /2./lRamp;
        end;
    end;
    kRaw(j+1) = kRaw(j+1)./renormalize;
end;
%// Reflect the line to assign negative k-space values.
for j=1:Trapezoid.NxRegrid/2
    kRaw(j) = - kRaw(Trapezoid.NxRegrid-j+1);
end;

%//
%// Locate the neighbors for each k-space point that fall within a given width.
%//
Trapezoid.regrid_numberNeighbors = zeros(Trapezoid.NxRegrid,1);
Trapezoid.regrid_density         = zeros(Trapezoid.NxRegrid,1);
Trapezoid.regrid_rolloff         = zeros(Trapezoid.NxRegrid,1);
Trapezoid.regrid_workingSpace    = zeros(Trapezoid.NxRegrid,1);
for  j=0:Trapezoid.NxRegrid-1
    %       //
    %       // Define the roll-off function.
    %       //
    x = -0.5 + j/(Trapezoid.NxRegrid-1);      %// Because delta_k = 1, DELTA_x = 1/delta_k = 1
    Trapezoid.regrid_rolloff(j+1) = ice_inverse_kaiser_bessel(x, regrid_width, regrid_sigma);
    %       //
    %       // Locate the neighbors for each k-space point that fall within a given width.
    %       //
    k = kRaw(j+1);
    kNew = j - Trapezoid.NxRegrid/2 + 0.5;   %// e.g., -63.5 to 63.5 for 128 steps, in uniform 1-unit increments
    Trapezoid.regrid_numberNeighbors(j+1) = 0;
    Trapezoid.regrid_density(j+1) = 0.;
    for jn=0:Trapezoid.NxRegrid-1
        
        kn = kRaw(jn+1);
        if ( abs(k-kn) <= regrid_width/2.0 )
            Trapezoid.regrid_density(j+1)= Trapezoid.regrid_density(j+1)+ice_kaiser_bessel( (k-kn), regrid_width, regrid_sigma );
        end;
        if ( abs(kNew-kn) <= regrid_width/2.0 )
            Trapezoid.regrid_numberNeighbors(j+1)=Trapezoid.regrid_numberNeighbors(j+1)+1;
        end;
    end;
end;

%// Find the maximum number of neighbors, in order to allocate memory.
maxNeigh = -1;
for j=0:Trapezoid.NxRegrid-1
    if ( Trapezoid.regrid_numberNeighbors(j+1) > maxNeigh ) maxNeigh = Trapezoid.regrid_numberNeighbors(j+1); end;
end;

%// Allocate 2D matrices.
Trapezoid.regrid_neighbor = zeros(Trapezoid.NxRegrid,maxNeigh);
Trapezoid.regrid_convolve = zeros(Trapezoid.NxRegrid,maxNeigh);

%// Fill the 2D matrices.
for j=0:Trapezoid.NxRegrid-1
    %// Repeat the above block of code, and store matrix data.
    kNew = j - Trapezoid.NxRegrid/2 + 0.5;   %// e.g., -63.5 to 63.5 for 128 steps, in uniform 1-unit increments
    Trapezoid.regrid_numberNeighbors(j+1) = 0;
    
    for jn=0:Trapezoid.NxRegrid-1
        
        kn = kRaw(jn+1);
        if ( abs(kNew-kn) <= regrid_width/2. )
            Trapezoid.regrid_neighbor(j+1,Trapezoid.regrid_numberNeighbors(j+1)+1) = jn;
            Trapezoid.regrid_convolve(j+1,Trapezoid.regrid_numberNeighbors(j+1)+1) = ice_kaiser_bessel( (kNew-kn), regrid_width, regrid_sigma );
            Trapezoid.regrid_numberNeighbors(j+1)=Trapezoid.regrid_numberNeighbors(j+1)+1;
        end;
    end;
end;

return;
