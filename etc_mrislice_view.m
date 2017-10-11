function etc_mrislice_view(varargin)
%
% etc_mrislice_view    rendering volumetric MRI slices
%
% h = etc_mrislice_view([option1 option1_value, ...]);
%
%
% fhlin@oct 6 2017
%

h=[];

img={};
vox_dim={};
vol_alpha=0.2;
vol_threshold=nan;

slice_res=128; %pixel
slice_fov=256; %mm

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'img'
            img=option_value;
        case 'vox_dim'
            vox_dim=option_value;
        case 'vol_alpha'
            vol_alpha=option_value;
        case 'vol_threshold'
            vol_threshold=option_value;
        case 'slice_res'
            slice_res=option_value;
        case 'slice_fov'
            slice_fov=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end


global etc_mrislice_view;
etc_mrislice_view=[];

etc_mrislice_view.img=img;
etc_mrislice_view.fig_vol=[];
etc_mrislice_view.fig_img=[];

etc_mrislice_view.vol_alpha=vol_alpha;
if(isempty(vox_dim))
    vox_dim{1}=ones(1,ndims(img));
end;
etc_mrislice_view.vox_dim=vox_dim;
etc_mrislice_view.vol_alpha=ones(1,ndims(img)).*vol_alpha;
etc_mrislice_view.vol_threshold=ones(1,ndims(img)).*vol_threshold;

etc_mrislice_view.slice_res=slice_res;
etc_mrislice_view.slice_fov=slice_fov;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rendering starts here
for f_idx=1:length(etc_mrislice_view.img)
    [x,y,z]=meshgrid(([1:size(etc_mrislice_view.img{f_idx},1)]-1-size(etc_mrislice_view.img{f_idx},1)/2).*etc_mrislice_view.vox_dim{f_idx}(1),([1:size(etc_mrislice_view.img{f_idx},2)]-1-size(etc_mrislice_view.img{f_idx},2)/2).*etc_mrislice_view.vox_dim{f_idx}(2),([1:size(etc_mrislice_view.img{f_idx},3)]-1-size(etc_mrislice_view.img{f_idx},3)/2).*etc_mrislice_view.vox_dim{f_idx}(3));
    
    
    etc_mrislice_view.fig_vol(f_idx)=figure;
    hold on;
    Ds = smooth3(etc_mrislice_view.img{f_idx});
    
    if(isnan(etc_mrislice_view.vol_threshold(f_idx)))
        %automatic thresholding
        tmp=sort(etc_mrislice_view.img{f_idx}(:));
        etc_mrislice_view.vol_threshold(f_idx)=tmp(round(length(tmp).*0.95));
    end;
    
    etc_mrislice_view.h_vol(f_idx) = patch(isosurface(x,y,z,Ds,etc_mrislice_view.vol_threshold(f_idx)),...
        'FaceColor',[1,.75,.65],...
        'facealpha',etc_mrislice_view.vol_alpha(f_idx),...
        'EdgeColor','none');
    
    lightangle(45,30);
    lighting gouraud
    hcap.AmbientStrength = 0.6;
    hiso.SpecularColorReflectance = 0;
    hiso.SpecularExponent = 50;
    
    view(35,30)
    axis vis3d equal off
    set(gca,'xlim',[min(x(:)) max(x(:))]);
    set(gca,'ylim',[min(y(:)) max(y(:))]);
    set(gca,'ylim',[min(z(:)) max(z(:))]);
    
    
    %etc_mrislice_view.hsp(f_idx) = surf(([1:size(etc_mrislice_view.img{f_idx},1)]-1-size(etc_mrislice_view.img{f_idx},1)/2).*etc_mrislice_view.vox_dim{f_idx}(1),([1:size(etc_mrislice_view.img{f_idx},2)]-1-size(etc_mrislice_view.img{f_idx},2)/2).*etc_mrislice_view.vox_dim{f_idx}(1),zeros(size(etc_mrislice_view.img{f_idx},1),size(etc_mrislice_view.img{f_idx},2)));
    res=etc_mrislice_view.slice_fov./etc_mrislice_view.slice_res;
    etc_mrislice_view.hsp(f_idx) = surf(([1:etc_mrislice_view.slice_res]-1-etc_mrislice_view.slice_res/2).*res,([1:etc_mrislice_view.slice_res]-1-etc_mrislice_view.slice_res/2).*res,zeros(etc_mrislice_view.slice_res,etc_mrislice_view.slice_res));
 
    [az,el]=view;
    rotate(etc_mrislice_view.hsp(f_idx),[az el],0);
    set(etc_mrislice_view.hsp(f_idx),'visible','off');
    xd = etc_mrislice_view.hsp(f_idx).XData;
    yd = etc_mrislice_view.hsp(f_idx).YData;
    zd = etc_mrislice_view.hsp(f_idx).ZData;
    
    
    hold on;
    etc_mrislice_view.h_slice(f_idx)=slice(x,y,z,double(etc_mrislice_view.img{f_idx}),xd,yd,zd);
    set(etc_mrislice_view.h_slice(f_idx),'edgecolor','none');
    
    
    etc_mrislice_view.fig_img(f_idx)=figure;
    if(f_idx>1)
        pos1=get(etc_mrislice_view.fig_vol(f_idx-1),'pos');
        %pos2=get(etc_mrislice_view.fig_vol(f_idx),'pos');
        set(etc_mrislice_view.fig_vol(f_idx),'pos',[pos1(1) pos1(2)-pos1(4) pos1(3) pos1(4)]);
    end;
    pos1=get(etc_mrislice_view.fig_vol(f_idx),'pos');
    %pos2=get(etc_mrislice_view.fig_img(f_idx),'pos');
    %pos2(1)=pos1(1)+pos1(3);
    set(etc_mrislice_view.fig_img(f_idx),'pos',[pos1(1)+pos1(3) pos1(2) pos1(3) pos1(4)]);
    imagesc(get(etc_mrislice_view.h_slice(f_idx),'cdata'))
    colormap(gray);
    set(gca,'pos',[0 0 1 1]);
    set(etc_mrislice_view.fig_img(f_idx),'color','k');
    axis off image;
    
    
    %set focus back to volume
    figure(etc_mrislice_view.fig_vol(f_idx));
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %setup call-back function
    %%%%%%%%%%%%%%%%%%%%%%%%
    set(etc_mrislice_view.fig_img(f_idx),'WindowButtonDownFcn','etc_mrislice_view_handle(''bd'')');
    set(etc_mrislice_view.fig_img(f_idx),'KeyPressFcn','etc_mrislice_view_handle(''kb'')');
    set(etc_mrislice_view.fig_img(f_idx),'invert','off');
    
    set(etc_mrislice_view.fig_vol(f_idx),'WindowButtonDownFcn','etc_mrislice_view_handle(''bd'')');
    set(etc_mrislice_view.fig_vol(f_idx),'KeyPressFcn','etc_mrislice_view_handle(''kb'')');
    set(etc_mrislice_view.fig_vol(f_idx),'invert','off');
    
    hold on;
    
end;

etc_mrislice_view.fig_gui=gobjects(length(etc_mrislice_view.img),1);
etc_mrislice_view.translate_dist=zeros(length(etc_mrislice_view.img),1);
etc_mrislice_view.rotate_angle=zeros(length(etc_mrislice_view.img),1);
