function [datamat_select_idx,datamat_select_idx_value,varargout] = fmri_overlay(img,overlay,idxx,threshold,varargin)
%
% [datamat_select_idx] = fmri_overlay(img,overlay,idx,threshold,datamat)
%
% Create an overlay image by providing underlay(img) and overlay(overlay)
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
%	idx='=': voxels of overlay equal the threshold will be shown
%threshold: the threshold for overlay, a 2-element vector
%	idx='>': threshold(1) is the minimal value to be shown.
%		 (threshold(2) is an option; all voxels >=threshold(2) will be set as threshold(2).)
%	idx='<': threshold(1) is the maximal value to be shown.
%		 (threshold(2) is an option; all voxels <=threshold(2) will be set as threshold(2).)
%	idx='~': voxels between threshold(1) and threshold(2) will be shown.
%  idx='=': voxels equal threshold(1) will be shown.
%
% datamat
%
%image toolbox function 'imresize' is used.
%
% written by fhlin@nov. 17,1999

if(nargin < 4)
  fprintf('insufficient input arguments!\n');
  fprintf('error!\n');
  eval('help fmri_overlay');
  return;
end

img0=img;
overlay0=overlay;

status=1;				
img_depth=128;				%default: 128 gray level underlay
overlay_depth=128;		    %default: 128 color level overlay
colorbar_flag=1;			%default: with color bar

overlay_orig=overlay;

init=1;
datamat_flag=0;
coords=[];
datamat=[];
TR=[];
flag_archive=0;

beta=[];
contrast=[];
fout='';

flag_normalize_under=1;

if(length(varargin)>0)
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        switch lower(option)
        case 'datamat'
            datamat=option_value;
            datamat_flag=1;
        case 'coords'
            coords=option_value;
            datamat_flag=1;
        case 'tr'
            TR=option_value;
        case 'beta'
            beta=option_value;
        case 'contrast'
            contrast=option_value;
        case 'flag_normalize_under'
            flag_normalize_under=option_value;
        case 'fout'
            fout=option_value;
        case 'archive'
            flag_archive=option_value;
        case 'colorbar'
            colorbar_flag=option_value;
        case 'init'
            flag_init=option_value;
        case 'ud'
            ud=option_value;
            flag_init=ud.init;
            colorbar_flag=ud.colorbar;
            fout=ud.fout;
%             beta=ud.beta;
            datamat=ud.datamat;
            coords=ud.coords;
            img=ud.underlay;
            overlay=ud.overlay;
            idxx=ud.idxx;
            threshold=ud.threshold;
            init=ud.init;
%             TR=ud.TR:
        otherwise
            fprintf('unknown option [%s]\n',option);
            return;
        end;
    end;
end;    



%make img a 2D image
if(length(size(img))==3)
	[y,x,z]=size(img);
	[dummy,img]=fmri_mont(reshape(img,[y,x,z]),[],'null');
end;


if(length(size(img))==2)
	[y,x]=size(img);
    z=1;
	[dummy,img]=fmri_mont(reshape(img,[y,x,z]),[],'null');
end;


%make overlay a 2D image
if(length(size(overlay))==3)
	[y,x,z]=size(overlay);
	[dummy,overlay]=fmri_mont(reshape(overlay,[y,x,1,z]),[],'null');
end;


%get information about padded area
extra_y_start=0;
extra_y_end=0;
extra_x_start=0;
extra_x_end=0;
if(length(size(overlay))>2)
    extra_slice=prod(size(overlay))./(y*x)-z;
    if(extra_slice>0)
      	extra_y_start=size(overlay,1)-y+1;
    	extra_y_end=size(overlay,1);
    	extra_x_start=size(overlay,2)-extra_slice*x+1;
    	extra_x_end=size(overlay,2);
    end;
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
if(flag_normalize_under)
    img = (img_depth-1) .* (img - img_min)/ (img_max - img_min) + 1; %normalize img between 1 and img_depth
end;

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




if(idxx=='>')
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
elseif(idxx=='<')
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
elseif(idxx=='~')
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
elseif(idxx=='=')
    ovmax=threshold(1);
    ovmin=threshold(1);
    mode=4;
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
    
    if(flag_normalize_under)
        overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
    else
        overlay(idx_replace)=img(idx_replace);
    end;
    
    overlay_map=autumn(overlay_depth);
    overlay_map=hot(211);
	overlay_map=overlay_map(83:211,:);
    
    cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
    
case 2,
    overlay(find(overlay<ovmin))=ovmin;
    
    idx_scale=find(overlay<=ovmax);
    idx_replace=find(overlay>ovmax);
    [ovmax,index]=max(overlay(idx_scale));
    
    overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - ovmin)/ (ovmax-ovmin) + (img_depth+1);
    
    overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
    
    overlay_map=winter(overlay_depth);
    cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
case 3,
    idx_scale=find((overlay<=ovmax)&(overlay>=ovmin));
    idx_replace=find((overlay>ovmax)|(overlay<ovmin));
    
    overlay(find(overlay<ovmin))=ovmin;
    overlay(find(overlay>ovmax))=ovmax;
    
    [ovmax,index]=max(overlay(idx_scale));
    [ovmin,index]=min(overlay(idx_scale));
    
    overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - ovmin)/ (ovmax-ovmin) + (img_depth+1);
    
    overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
    
    overlay_map=jet(overlay_depth);
    cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
case 4,
    
    idx_scale=find((overlay==ovmax));
    idx_replace=find((overlay~=ovmax));
    
    overlay(idx_scale)=  overlay_depth  + img_depth;
    
    overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
    
    cmap(img_depth+1:img_depth+overlay_depth,:) = repmat([1 1 0],[overlay_depth,1]); %yellow as index
    
    colorbar_flag=0;
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

%paste the overlay and underlay
h=fmri_mont(imgov);

%apply the palette
colormap(cmap);

%setup figure
set(gca,'color',[1,1,1]);
set(gcf,'color',[0,0,0]);
if(colorbar_flag)
    set(gca,'DataAspectRatioMode','auto');
    set(gca,'PlotBoxAspectRatioMode','manual');
    set(gca,'PlotBoxAspectRatio',[1 1 1]);
    set(gca,'unit','normalized');
    pos=get(gca,'pos');
    
    bar=colorbar('peer',gca);
    set(bar,'tag','colorbar');
    set(bar,'unit','normalized');
    set(bar,'pos',[pos(1)+pos(3),pos(2),pos(3)/8,pos(4)]);
    set(bar,'color',[0 0 0]);
    set(bar,'ycolor',[1,1,1]);
    set(bar,'ylim',[128,256]);
    set(bar,'ytickmode','manual');
    set(bar,'ytick',[130:13:255]);
    set(bar,'yaxislocation','right');
    set(bar,'yticklabelmode','manual');
    s=num2str(reshape([ovmin:(ovmax-ovmin)/9:ovmax],[10,1]),'%1.3f');
    set(bar,'yticklabel',s);
    
    pos_a=get(gca,'pos');
    pos_b=get(bar,'pos');
    pos_b(1)=pos_a(1)+pos_a(3);
    set(bar,'pos',pos_b);
    hh=rectangle('pos',[pos_b(1),pos_b(2),pos_b(3)/2,pos_b(4)]);
    
end;
datamat_select_idx=[];
varargout{1}=gca;



if(flag_archive)
    if(~isempty(fout))
        fprintf('saving [%s]...\n',fout);
        imwrite(imgov,cmap,fout,'tiff');
    else
        fprintf('saving [fmri_overlay.tiff]...\n');
        imwrite(imgov,cmap,'fmri_overlay.tiff','tiff');
    end;
end;


fig_overlay=gcf;

datamat_select_idx=[];
if(init)
    fig_project=0;
    fig_profile=0;
    select_pixel=0;
    disp('init...');
    set(fig_overlay,'KeyPressFcn','fmri_overlay_handle(''kb'')');
    set(fig_overlay,'WindowButtonDownFcn','fmri_overlay_handle(''bd'')');
    ud.flag=0;
    ud.xx=1;
    ud.yy=1;
    ud.imgov=imgov;
    ud.x=x;
    ud.y=y;
    ud.z=z;
    ud.pointer=[];
%     ud.pointer_mark_project=[];
%     ud.pointer_mark_overlay=[];
    ud.pointer_mark=[];
    ud.coords=coords;
    ud.overlay_orig=overlay_orig;
    ud.fig_profile=fig_profile;
    ud.fig_overlay=fig_overlay;
    ud.fig_project=fig_project;
    ud.select_pixel=select_pixel;
    ud.datamat_select_idx=[];
    if((~isempty(beta))&(~isempty(contrast)))
        datamat(:,:,2)=contrast*beta;
    end;
    ud.datamat=datamat;
    ud.TR=TR;
    ud.underlay=img0;
    ud.overlay=overlay0;
    ud.idxx=idxx;
    ud.threshold=threshold;
    ud.fout=fout;
    ud.window_id='overlay';
    if(colorbar_flag)
        ud.colorbar=1;
    else
        ud.colorbar=0;
    end;
    
    if(exist('varargin'))
        ud.varargin=varargin;
    else
        ud.varargin=[];
    end;
    ud.init=init;
    set(gca,'userdata',ud);


end;

return;

