function	[x,y,z] = mkplane_snr(fovf,fovp,nf,np,phasedir,...
				  patientposition,patientorientation,...
				  sliceorientation,...
				  apoff,lroff,fhoff,...
				  apang,lrang,fhang)

% Generates coordinates of plane of interest for field calculations,
% image reconstruction, etc. 
% Geometric conventions modelled after Philips Gyroscan parameters.
% Default coordinate system (Philips convention, patient head-first supine):
%
%       A  H(+z)
%       | /
%       |/
% R-----------L(+x)
%      /|
%     / |
%    F  P(+y)
%
%		[x,y,z] = mkplane_sar(fovf,fovp,nf,np,phasedir,...
%				  patientposition,patientorientation,...
%				  sliceorientation,...
%				  apoff,lroff,fhoff,...
%				  apang,lrang,fhang)
%
% input:
%	fovf: fov in the frequency-encoding direction
%	fovp: fov in the phase-encoding direction
%	nf: number of points in the frequency-encoding direction
%	np: number of points in the phase-encoding direction
%	phasedir: phase encoding / foldover direction flag.  
%		'FH' or 'LR'
%	patientposition: 'headfirst' or 'feetfirst'
%	patientorientation: 'supine','prone','ldecub', or 'rdecub'
%	sliceorientation: reference slice orientation
%		'transverse','sagittal', or 'coronal'
% 	apoff: linear offset in the AP direction (original x)
%	lroff: linear offset in the LR direction (original y)
%	fhoff: linear offset in the FH direction (original z)
%	apang: angular offset about the AP axis
%	lrang: angular offset about the LR axis
%	fhang: angular offset abou the FH axis
%
% output: 
%	x,y,z: nf x np (or np x nf) arrays of coordinates describing the 
%		plane of interest
%
% Daniel Sodickson
% Version History:
% Modified from mkplane.m to generate voxel positions -fov/2:fov/n:(fov/2-fov/n)
% 1.2: 10/22/98
% 1.1: 10/30/96

% angles to radians
drfac = pi/180;
apang = -drfac*apang;
lrang = -drfac*lrang;
fhang = -drfac*fhang;

% transform angles and offsets according to patient position
% and orientation
offs = [lroff; apoff; fhoff];
angs = [lrang; apang; fhang];
if strcmp(lower(patientposition),lower('headfirst')),
	pmat = eye(3);
elseif strcmp(lower(patientposition),lower('feetfirst')),
	pmat = [-1	 0	 0
		 0	 1 	 0
		 0 	 0 	-1];
end
if strcmp(lower(patientorientation),lower('supine')),
	omat = eye(3);
elseif strcmp(lower(patientorientation),lower('prone')),
	omat = [-1	 0	 0
		 0	-1 	 0
		 0 	 0 	 1];
elseif strcmp(lower(patientorientation),lower('ldecub')), 	
	omat = [ 0	-1	 0
		 1	 0 	 0
		 0 	 0 	 1];
elseif strcmp(lower(patientorientation),lower('rdecub')),
	omat = [ 0	 1	 0
		-1	 0 	 0
		 0 	 0 	 1];
end
pomat = pmat*omat;
offs = pomat*offs;
angs = pomat*angs;
lroff = offs(1); apoff = offs(2); fhoff = offs(3);
lrang = angs(1); apang = angs(2); fhang = angs(3);

% define image plane limits and create coordinate grids
% np,nf == 1 conditions added 9/8/00 DKS
if np == 1,
   plim = 0;
else
   plim = -fovp/2:fovp/np:(fovp/2 - fovp/np);
%    plim = -fovp/2:fovp/(np-1):fovp/2;
end
if nf == 1,
   flim = 0;
else
   flim = -fovf/2:fovf/nf:(fovf/2 - fovf/nf);
%    flim = -fovf/2:fovf/(nf-1):fovf/2;
end

if strcmp(lower(sliceorientation),lower('coronal')),
	% make initial coordinate grid for y=0 plane
	if strcmp(lower(phasedir),lower('LR')),
		if pomat(1,1) == -1,
			plim = fliplr(plim);
		end
		if pomat(3,3) == -1,
			flim = fliplr(flim);
		end
		[x,z] = meshgrid(plim,fliplr(flim));
	elseif strcmp(lower(phasedir),lower('FH')),
		if pomat(1,1) == -1,
			flim = fliplr(flim);
		end
		if pomat(3,3) == -1,
			plim = fliplr(plim);
		end
		[z,x] = meshgrid(fliplr(plim),flim);
	end
	y = zeros(size(x));
elseif strcmp(lower(sliceorientation),lower('transverse')),
	% make initial coordinate grid for z=0 plane
	if strcmp(lower(phasedir),lower('LR')),
		if pomat(1,1) == -1,
			plim = fliplr(plim);
		end
		if pomat(2,2) == -1,
			flim = fliplr(flim);
		end
		[x,y] = meshgrid(plim,flim);
	elseif strcmp(lower(phasedir),lower('FH')),
		if pomat(1,1) == -1,
			flim = fliplr(flim);
		end
		if pomat(2,2) == -1,
			plim = fliplr(plim);
		end
		[y,x] = meshgrid(plim,flim);
	end
	z = zeros(size(x));
elseif strcmp(lower(sliceorientation),lower('sagittal')),
	% make initial coordinate grid for x=0 plane
	if strcmp(lower(phasedir),lower('LR')),
		if pomat(2,2) == -1,
			plim = fliplr(plim);
		end
		if pomat(3,3) == -1,
			flim = fliplr(flim);
		end
		[y,z] = meshgrid(plim,fliplr(flim));
	elseif strcmp(lower(phasedir),lower('FH')),
		if pomat(2,2) == -1,
			flim = fliplr(flim);
		end
		if pomat(3,3) == -1,
			plim = fliplr(plim);
		end
		[z,y] = meshgrid(fliplr(plim),flim);
	end
	x = zeros(size(y));
end

if 0,
% perform rotations
% AP <--> y rotation
zr =  cos(apang)*z + sin(apang)*x;
xr = -sin(apang)*z + cos(apang)*x;
% LR <--> x rotation
yr =  cos(lrang)*y + sin(lrang)*zr;
z  = -sin(lrang)*y + cos(lrang)*zr;
% FH <--> z rotation
x =   cos(fhang)*xr + sin(fhang)*yr;
y =  -sin(fhang)*xr + cos(fhang)*yr;
end


% perform rotations
% FH <--> z rotation
xr =   cos(fhang)*x + sin(fhang)*y;
yr =  -sin(fhang)*x + cos(fhang)*y;
% AP <--> y rotation
zr =  cos(apang)*z + sin(apang)*xr;
x  = -sin(apang)*z + cos(apang)*xr;
% LR <--> x rotation
y  =  cos(lrang)*yr + sin(lrang)*zr;
z  = -sin(lrang)*yr + cos(lrang)*zr;



% perform translations
% AP <--> y translation
y = y+apoff;
% LR <--> x translation
x = x+lroff;
% FH <--> z translation
z = z+fhoff;
