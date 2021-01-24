function [imgov,cmap,status] = fmri_overlay_bw(img,overlay,idx,threshold,varargin)
%
% [imgov cmap status] = fmri_overlay_bw(img,overlay,idx,threshold,relative_scale)
%
% Create an black-white overlay image by providing underlay(img) and overlay(overlay)
%
%img: 2D image of underlay (img could be multiple fold of overlay. )
%overlay: 2D image of overlay
%status: output flag. 1: successul; 0: otherwise
%
%
%idx: a string specifying output mode
%	idx='>': voxels of overlay greater or equal to threshold will be shown
%	idx='<': voxels of overlay smaller or equal to threshold will be shown
%	idx='~': voxels of overlay between 2 thresholds will be shown
%threshold: the threshold for overlay, a 2-element vector
%	idx='>': threshold(1) is the minimal value to be shown.
%		 (threshold(2) is an option; all voxels >=threshold(2) will be set as threshold(2).)
%	idx='<': threshold(1) is the maximal value to be shown.
%		 (threshold(2) is an option; all voxels <=threshold(2) will be set as threshold(2).)
%	idx='~': voxels between threshold(1) and threshold(2) will be shown.
% relative_scale: 100% based floating number to describe the display range.
%		  default: 100% (1)
%
%image toolbox function 'imresize' is used.
%
% written by fhlin@nov. 17,2000

status=1;
img_depth=128;
overlay_depth=128;

if(nargin < 4)
  msg = 'USAGE: [imgov cmap cscale] = imgoverlay(img,overlay,ovmin,<ovmax>)'
  disp(msg);
  status=0;
  return;
end

if (nargin==4)
	relative_scale=1;
else
	relative_scale=varargin{1};
end;

%make img a 2D image
if(length(size(img))==3)
	figure;
	[y,x,z]=size(img);
	fmri_mont(reshape(img,[y,x,1,z]));
	img=getimage;
	close(gcf);
end;

%make overlay a 2D image
if(length(size(overlay))==3)
	figure;
	[y,x,z]=size(overlay);
	fmri_mont(reshape(overlay,[y,x,1,z]));
	overlay=getimage;
	close(gcf);
end;

%get information about padded area
extra_slice=prod(size(overlay))./(y*x)-z;
if(extra_slice>0)
	extra_y_start=size(overlay,1)-y+1;
	extra_y_end=size(overlay,1);
	extra_x_start=size(overlay,2)-extra_slice*x+1;
	extra_x_end=size(overlay,2);
else
	extra_y_start=0;
	extra_y_end=0;
	extra_x_start=0;
	extra_x_end=0;
end;


nImgRows  = size(img,1);
nImgCols  = size(img,2);
nImgDepth = size(img,3);

nOvRows  = size(overlay,1);
nOvCols  = size(overlay,2);
nOvDepth = size(overlay,3);

if(nImgDepth ~= 1 & nImgDepth ~= nOvDepth)
  msg = sprintf('Overlay (%d) and Underlay (%d) depths differ\n',...
                nImgDepth,nOvDepth);
  disp(msg);
end


img=reshape(img,[nImgRows*nImgCols*nImgDepth,1]);
img_min = min(img);
img_max = max(img);
img = (img_depth-1) .* (img - img_min)/ (img_max - img_min) + 1; %normalize img between 1 and img_depth

% make overlay and image of the same size %
oo=overlay;
overlay = reshape(imresize(overlay(:,:),[nImgRows nImgCols]),[nImgRows*nImgCols,1]);


% get indices of extra padded area
mx=max(overlay);
if(extra_y_start>0 & extra_x_start>0)
	oo(extra_y_start:extra_y_end,extra_x_start:extra_x_end)=mx+1;
end;
oo = reshape(imresize(oo(:,:),[nImgRows nImgCols]),[nImgRows*nImgCols,1]);
orig_index=find(oo<=mx);
extra_index=find(oo==mx+1);
overlay=overlay(orig_index);
img=img(orig_index);



omin=min(overlay);
omax=max(overlay);

if(idx=='>')
	ovmin=threshold(1);
	if(length(threshold)==1);
		limit=max(max(overlay));
	else
		limit=threshold(2);
	end;
	ovmax=limit;
	mode=1;
	if(ovmin>omax)
		disp('minimal threshold exceeds the overlay maximum!');
		s=sprintf('max of overlay = %f', omax);
		disp(s);
		status=0;
		return;
	end;
elseif(idx=='<')
	ovmax=threshold(1);
	if(length(threshold)==1)
		limit=min(min(overlay));
	else
		limit=threshold(2);
	end;
	ovmin=limit;
	mode=2;
	if(ovmax<omin)
		disp('maximal threshold below the overlay minimum!');
		s=sprintf('min of overlay = %f', omin);
		disp(s);
		status=0;
		return;
	end;
elseif(idx=='~')
	ovmax=threshold(2);
	ovmin=threshold(1);
	mode=3;
	if(ovmax>omax|ovmin<omin)
		disp('threshold range exceeds the overlay!');
		s=sprintf('max of overlay = %f', omax);
		disp(s);
		s=sprintf('min of overlay = %f', omin);
		disp(s);
		status=0;
		return;
	end;
else
	disp('invalid display mode!');
	return;
end;

% Construct the Colormap %
cmap(1:img_depth,:) =gray(img_depth);

% thresholding %
switch mode
	case 1,
		overlay(find(overlay>ovmax))=ovmax;
		
		idx_scale=find(overlay>=ovmin);
		idx_replace=find(overlay<ovmin);
		[ovmin,index]=min(overlay(idx_scale));

		overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - ovmin)/ (ovmax-ovmin) + (img_depth+1);
		
		overlay(idx_replace)=img(idx_replace);
		overlay(idx_replace)=overlay(idx_replace)*0.8;
		
		%overlay_map=autumn(overlay_depth);
		overlay_map=ones(overlay_depth,3);

		cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
	case 2,
		overlay(find(overlay<ovmin))=ovmin;
		
		idx_scale=find(overlay<=ovmax);
		idx_replace=find(overlay>ovmax);
		[ovmax,index]=max(overlay(idx_scale));

		overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - ovmin)/ (ovmax-ovmin) + (img_depth+1);
		
		overlay(idx_replace)=img(idx_replace);
		overlay(idx_replace)=overlay(idx_replace)*0.8;

		%overlay_map=winter(overlay_depth);
		overlay_map=ones(overlay_depth,3);
		
		cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
	case 3,
		idx_scale=find((overlay<=ovmax)&(overlay>=ovmin));
		idx_replace=find((overlay>ovmax)|(overlay<ovmin));
		
		overlay(find(overlay<ovmin))=ovmin;
		overlay(find(overlay>ovmax))=ovmax;
		
		[ovmax,index]=max(overlay(idx_scale));
		[ovmin,index]=min(overlay(idx_scale));

		overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - ovmin)/ (ovmax-ovmin) + (img_depth+1);

		overlay(idx_replace)=img(idx_replace);
		overlay(idx_replace)=overlay(idx_replace)*0.8;
		
		%overlay_map=jet(overlay_depth);
		overlay_map=ones(overlay_depth,3);
		
		cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
		
end;
oo=zeros(nImgRows*nImgCols,1);
oo(orig_index)=overlay;
oo(extra_index)=1;



%% Compress the range of the overlays %%
imgov(:,:) = reshape(oo,[nImgRows nImgCols]);


%set extra padded area to black
if(extra_y_start>0 & extra_x_start>0)
	imgov(extra_y_start:extra_y_end,extra_x_start:extra_x_end)=1;
end;

% set bk to black
m=imgov(2,2);
idx=find(imgov==m);
imgov(idx)=min(min(imgov));

%setup figure
figure;
set(gcf,'color',[0,0,0]);
set(gcf,'inverthardcopy','off')
%h=axes('position', [0 0 .8 1]);

%paste the overlay and underlay
fmri_mont(imgov);
axis image;
set(gca,'xtick',[]);
set(gca,'ytick',[]);

%apply the palette
colormap(cmap);


%show colorbar
%bar=colorbar;

%set(h,'pos',[0,0,0.8,1]);
%set(bar,'pos',[0.9,0,0.1,1]);
%set(bar,'ycolor',[1,1,1]);
%set(bar,'ylim',[128,256]);
%set(bar,'ytick',[130:16:256]);


%s=str2num(num2str(reshape([ovmin:(ovmax-ovmin)/7:ovmax],[8,1]),'%1.3f'));
%set(bar,'yticklabel',s(1:8));
%set(bar,'yaxislocation','left');
