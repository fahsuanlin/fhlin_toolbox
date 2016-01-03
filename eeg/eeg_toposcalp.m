function []=eeg_toposcalp(data,varargin)
% eeg_toposcalp    Show topology of EEG/MEG data on a scalp
%
% []=eeg_toposcalp(data,varargin)
%
% fhlin@jan. 3 2016
%


 

topoconfig=[];

clim=[];

flag_show_electrodes=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'topoconfig'
             topoconfig=option_value;
        case 'clim'
             clim=option_value;
        case 'flag_show_electrodes'
            flag_show_electrodes=option_value;
        otherwise
            fprintf('unknown option [%s].\n',option);
            fprintf('error!\n');
            return;
    end;
end;

if(isempty(topoconfig))
    load('eeg_topoconfig32.mat'); %default topology configuration
end;
                 
if(isempty(clim))
    dummy=sort(data(:));
    clim(1)=data(round(length(data(:))*0.05));
    clim(2)=data(round(length(data(:))*0.95));
end;

val=zeros(size(topoconfig.verts_os,1),1);
val(topoconfig.electrodes_vertex)=data;
cmap=colormap;

val_interp=inverse_smooth('','value',val,'step',20,'face',topoconfig.faces_os'-1,'vertex',topoconfig.verts_os','flag_fixval',1);
val_interp_c=inverse_get_color(cmap,val_interp,max(clim),min(clim));

idx=find(val_interp<=min(clim));
val_interp_c(idx,:)=repmat(cmap(1,:),[length(idx),1]);

idx=find(topoconfig.verts_os(:,3)<=0.01); %lower than z=0.01 m will be set to skin color
val_interp_c(idx,:)=repmat([256 180 100]./256,[length(idx),1]);

%figure;
patch('Vertices',topoconfig.verts_os,'Faces',topoconfig.faces_os,'FaceVertexCData',val_interp_c,'facecolor','flat','EdgeColor','none') 

caxis(clim);
view(0,0); camlight;
view(0,90); camlight;

axis equal off;material dull;

colorbar;

set(gcf,'color','w','invert','off')

return;

