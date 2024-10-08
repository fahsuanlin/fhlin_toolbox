function [ccimg,map]=etc_montage(layout,varargin)
%   etc_montage     make montage from data/files
%
%  [ccimg,map]=etc_montage(layout, [option, option_value])
%
%   layout: a 2D matrix consisting of 1,...n. Positions of these numbers
%   indicate the locations of data in the 2D montage.
%
% option:
%   mont_data:  a 3D (for multiple 2D data) or 4D (for multiple 3D data)
%   data matrix to be rendered
%   mont_file: a cell string including the file names to figures used for
%   making a montage
%   crop_rect: a 1x4 veector about the crop rectangular
%
%   fhlin@aug. 14 2008

mont_file=[];
mont_data=[];
crop_rect=[];
resize_size=[];
text_string='';
text_x=[];
text_y=[];
font_name='helvetica';
font_size=16;
font_color=[0 1 1];
flag_frame=1;
flag_auto_crop=1;
flag_display=0;

flag_colorbar=0;
colorbar_value_flag_pos=1;
colorbar_value_flag_neg=1;
colorbar_threshold=[];

horizontalalignment='left';

map=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'mont_data'
            mont_data=option_value;
        case 'mont_file'
            mont_file=option_value;
        case 'crop_rect'
            crop_rect=option_value;
        case 'resize_size'
            resize_size=option_value;
        case 'text_string'
            text_string=option_value;
        case 'text_x'
            text_x=option_value;
        case 'text_y'
            text_y=option_value;
        case 'font_name'
            font_name=option_value;
        case 'font_size'
            font_size=option_value;
        case 'flag_colorbar'
            flag_colorbar=option_value;
        case'colorbar_value_flag_pos'
            colorbar_value_flag_pos=option_value;
        case 'colorbar_value_flag_neg'
            colorbar_value_flag_neg=option_value;
        case 'colorbar_threshold'
            colorbar_threshold=option_value;
        case 'font_color'
            font_color=option_value;
        case 'flag_frame'
            flag_frame=option_value;
        case 'flag_auto_crop'
            flag_auto_crop=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'horizontalalignment'
            horizontalalignment=option_value;
        otherwise
            error(sprintf('unknown option [%s]!\n',option));
            return;
    end;
end;

nd=ndims(mont_data);
nn=max([length(mont_file),size(mont_data,nd)]);

if(nn<1)
    error('no data to render!\n');
    return;
else
    fprintf('[%d] data to render...\n',nn);
end;

if(~isempty(mont_data))
    mx=max(mont_data(:));
end;

for i=1:nn
    if(isempty(mont_data))
        if(flag_display)
            fprintf('reading [%s]...\n',mont_file{i});
        end;
        [img,map]=imread(mont_file{i});
        if(ndims(img)==3)
            if(size(img,3)==4)
                img=img(:,:,1:3);
            end;
        end;
    else
        if(ndims(mont_data)==3)
            img=mont_data(:,:,i);
        elseif(ndims(mont_data)==4)
            img=mont_data(:,:,:,i);
        end;
    end;
    mx=max(img(:));

    if(flag_display)
        fprintf('trimming...\n');
    end;
    hor=sum(sum(img,3),1);
    ver=sum(sum(img,3),2);
    ll=max(find(hor(1:floor(length(hor)/2))==0));
    rr=min(find(hor(floor(length(hor)/2):end)==0))+floor(length(hor)/2)-1;
    tt=max(find(ver(1:floor(length(ver)/2))==0));
    dd=min(find(ver(floor(length(ver)/2):end)==0))+floor(length(ver)/2)-1;
    if(flag_auto_crop)
        crop_rect=[ll,tt,rr-ll+1,dd-tt+1];
    end;

    if(~isempty(crop_rect))
        pp=imcrop(img,crop_rect);
    else
        pp=img;
    end;

    %     if(i>1)
    % 		xx=[];
    % 		for ch=1:size(pp,3)
    % 			xx(:,:,ch)=imresize(pp(:,:,ch),[size(cimg,1),size(cimg,2)]);
    % 		end;
    % 		pp=xx;
    % 	end;

    if(~isempty(resize_size))
        pp=imresize(pp,resize_size);
    end;


    if(flag_frame)
        pp(1,1:end,:)=mx;
        pp(end,1:end,:)=mx;
        pp(:,1,:)=mx;
        pp(:,end,:)=mx;
    end;

    if(size(pp,3)>1)
        cimg(:,:,:,i)=pp;
    else
        cimg(:,:,i)=pp;
    end;
end;

rows=size(layout,1);
cols=size(layout,2);

width=size(cimg,2);
height=size(cimg,1);

%if(length(size(cimg))==3)
if(ndims(cimg)==4)
    ccimg=zeros(size(cimg,1)*rows,size(cimg,2)*cols,size(cimg,3));
else
    ccimg=zeros(size(cimg,1)*rows,size(cimg,2)*cols);
end;
%elseif(length(size(cimg))==4)
%        ccimg=zeros(size(cimg,1)*rows,size(cimg,2)*cols,size(cimg,3));
%end;
for i=1:nn
    [r,c]=ind2sub(size(layout),find(layout==i));
    if(ndims(cimg)==4)
        ccimg((r-1)*height+1:r*height,(c-1)*width+1:c*width,:)=squeeze(cimg(:,:,:,i));
    else
        ccimg((r-1)*height+1:r*height,(c-1)*width+1:c*width)=squeeze(cimg(:,:,i));
    end;
end;
imagesc(ccimg./max(max(max(ccimg))));
axis off image;

hold on;
for i=1:nn
    [r,c]=ind2sub(size(layout),find(layout==i));
    if(~isempty(text_string))
        h=text((c-1)*width+text_x,(r-1)*height+text_y,text_string{i});
        set(h,'fontname',font_name,'fontsize',font_size,'color',font_color,'horizontalalignment',horizontalalignment);
    end;
end;

if(flag_colorbar&~isempty(colorbar_threshold))
    brain_axis=gca;
    brain_axis_pos=get(gca,'pos');
    brain_axis_pos(1)=0;
    brain_axis_pos(3)=1;

    set(brain_axis,'pos',[brain_axis_pos(1) 0.2 brain_axis_pos(3) 0.8]);
    h_colorbar=subplot('position',[brain_axis_pos(1) 0.0 brain_axis_pos(3) 0.2]);

    %stc
    %colorbar_pos_cmap=autumn(80); %overlay colormap;
    %colorbar_neg_cmap=winter(80); %overlay colormap;

    %topology
    tmp=jet(256);
    colorbar_pos_cmap=tmp(161:end,:);
    colorbar_neg_cmap=flipud(tmp(1:96,:));


    bg_color=[1 1 1];

    cmap=[colorbar_pos_cmap; colorbar_neg_cmap];
    hold on;

    if(colorbar_value_flag_pos)
        h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
        image([1:size(colorbar_pos_cmap,1)]); axis off; colormap(cmap);
        h=text(-3,1,sprintf('%1.3f',min(colorbar_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-bg_color);
        h=text(size(colorbar_pos_cmap,1)+3,1,sprintf('%1.3f',max(colorbar_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-bg_color);
    else
        h_colorbar_pos=[];
    end;

    if(colorbar_value_flag_neg)
        h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
        image([size(colorbar_pos_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
        h=text(-3,1,sprintf('-%1.3f',min(colorbar_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-bg_color);
        h=text(size(colorbar_pos_cmap,1)+3,1,sprintf('-%1.3f',max(colorbar_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-bg_color);
    else
        h_colorbar_neg=[];
    end;
end;

set(gcf,'invert','off');
if(isempty(map))
    map=colormap(gcf);
end;
%print('-dtiff',sprintf('%s_shift_%s.tif',orient{oo},view{k}));

