function [Regions] = spm_regions(XYZR,Rname) 

% VOI time-series extraction of adjusted data (local eigenimage analysis) 
% FORMAT [Regions] = spm_regions(XYZR,Rname); 
% 
% XYZR  - 4 x n matrix of x,y,z and radius for the VOI
% Rname - n x g matrix of n strings with length g
%
% Regions   - cell struct {1..n} of 
% xY        - structure with: 
% xY.Rname  - name of VOI 
% xY.pc     - first eigenvariate 
% xY.y      - voxel-wise data (filtered and adjusted) 
% xY.XYZ    - centre of VOI (mm)
% xY.mean   - mean of VOI 
% xY.rad    - radius of VOI (mm) 
% xY.q	    - pointlist
% xY.v      - first eigenimage
%
% Regions is also saved in REGIONS.mat in the directory of the SPM.mat 
% REGIONS.mat also stores Xx, SPM and xSDM
%___________________________________________________________________________ 
% spm_regions extracts a representative time course from voxel data in 
% Y.mad in terms of the first eigenvariate of filtered and adjusted [for 
% confounds] data in all suprathreshold voxels saved within a spherical 
% VOI centered on the nearest Y.mad voxel to the selected location. 
%--------------------------------------------------------------------------- 
%
%_______________________________________________________________________
% @(#)spm_regions	1.0b Christian Buchel 99/10/19


% get figure handles 
%--------------------------------------------------------------------------- 
SCCSid  = '1.0b';
SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','fMRI stats model setup',0);

if nargin == 1 | nargin >2
	error('Must provide either 2 or no arguments'), end

[SPM,VOL,xX,xCon,xSDM] = spm_getSPM;

%-Find nearest voxel [Euclidean distance] in point list & update GUI 
%--------------------------------------------------------------------------- 
if ~length(SPM.XYZmm) 
        spm('alert!','No suprathreshold voxels!',mfilename,0); 
        Y = []; xY = []; 
        return 
end 

% get VOI and name 
%--------------------------------------------------------------------------- 
if nargin < 1
 Rname = [];
 n = spm_input('number of regions',2,'e',1);
 XYZR  = zeros(4,n);
 
 for j = 1:n
  name  = spm_input('name of region',1,'s',sprintf('R%1.0f',j)); 
  Rname = strvcat(Rname,name);  
  Loc   = spm_input('X, Y, Z & radius (mm)',2,'e',8);
  XYZR(:,j) = Loc(:);  
 end; 
else
 n = size(XYZR,2);
end 

Q   = find(SPM.QQ);
XYZ = SPM.XYZmm(:,Q); 

eimage  = [];
indices = [];

for j = 1:n

   % get selected location 
   %--------------------------------------------------------------------------- 
    jXYZ   = XYZR(1:3,j);
    jR     = XYZR(4,j);
    jRname = Rname(j,:);
   
   [L,i] = spm_XYZreg('NearestXYZ',jXYZ,XYZ); 
    

   % find voxels within radius 
   %--------------------------------------------------------------------------- 
   d = [XYZ(1,:)-L(1); XYZ(2,:)-L(2); XYZ(3,:)-L(3)]; 
   q = find(sum(d.^2) <= jR^2); 
   y = spm_extract([SPM.swd '/Y.mad'],SPM.QQ(Q(q))); 
   rcp = VOL.iM(1:3,:)*[XYZ(:,q);ones(size(q))]; 

   %-Parameter estimates: beta = xX.pKX*xX.K*y; 
   %--------------------------------------------------------------------------- 
   if isstruct(xSDM.F_iX0) 
           Ic = xSDM.F_iX0(1).iX0; 
   else 
           Ic = xSDM.F_iX0; 
   end 
   beta = ones(length(Ic),size(q,2)); 
   for i = 1:length(Ic) 
           beta(i,:) = ... 
           spm_sample_vol(xSDM.Vbeta(Ic(i)),rcp(1,:),rcp(2,:),rcp(3,:),0); 
   end 

   % remove confounds and filter 
   %--------------------------------------------------------------------------- 
   y = spm_filter('apply',xX.K, y) - xX.xKXs.X(:,Ic)*beta; 

   % compute regional response in terms of first eigenvariate for raw data
   %--------------------------------------------------------------------------- 
   [u s v] = svd(y,0); 
   d    = sign(mean(v(:,1))); 
   u    = u*d; 
   v    = v*d; 
   Y    = u(:,1); 
   s    = diag(s).^2; 
   if size(y,2) > 1
    M    = mean(y')';
   else
    M    = y; 
   end 
   
   % create structure 
   %--------------------------------------------------------------------------- 
   Yx      = struct('Rname', jRname,... 
                    'pc'   , Y,... 
                    'y'    , y,...
                    'XYZ'  , L,... 
		    'mean' , M,...
                    'rad'  , jR,...
		    'q'    , q,...
		    'v'    , v(:,1));
		    
		     
   Regions(j) = Yx; 


eimage  = [eimage; v(:,1)];
indices = [indices q];
end % for j =1:n

% save 
%--------------------------------------------------------------------------- 
save([SPM.swd '/REGIONS.mat'],'Regions','xSDM','SPM','xX') 


% display MIP of VOI and timecourse 
%--------------------------------------------------------------------------- 
spm_results_ui('Clear',Fgraph,2); 
figure(Fgraph); 
axes('Position',[0.300 0.6100 0.5500 0.3388]) 
spm_mip(eimage,XYZ(:,indices),VOL.M,VOL.DIM) 
title('VOI weighting ') 

% display tabular data on regions
%-----------------------------------------------------------------------
subplot(2,1,2)
title('Selected regions','FontSize',16)
y     = 0;
line([1 7],[y y])
y     = y - 1;
text(1,y,['Region'])
text(2,y,['Name'])
text(3,y,['Voxels'])
text(5,y,['Location'])
text(6,y,['Radius'])
y     = y - 1;
line([1 7],[y y],'LineWidth',4)
y     = y - 2;
for j = 1:n
    text(1,y,sprintf('region %0.0f',j)                     ,'FontSize',8)
    text(2,y,Regions(j).Rname                              ,'FontSize',8)
    text(3,y,sprintf('%0.0f',size(Regions(j).q,2))         ,'FontSize',8)
    text(5,y,sprintf('%-6.0f %-6.0f %-6.0f',Regions(j).XYZ),'FontSize',8)
    text(6.3,y,sprintf('%-6.0f {mm}',Regions(j).rad)       ,'FontSize',8)
    y     = y - 1;
end
line([1 7],[y y])
y     = y - 1;
text(1,y,SPM.swd,'FontSize',10)
axis off


%-Reset title 
%----------------------------------------------------------------------- 
spm('FigName',['SPM{',SPM.STAT,'}: Results']); 


