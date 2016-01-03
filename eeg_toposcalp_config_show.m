function []=eeg_toposcalp_config_show(topo_config,varargin)
% eeg_toposcalp_config_show    Show topology of EEG/MEG data on a scalp
%
% []=eeg_toposcalp_config_show(topo_config,varargin)
%
% fhlin@jan. 3 2016
%


 

surf_os='/Users/fhlin_admin/workspace/subjects//lf/bem/watershed/lf_outer_skull_surface';

flag_show_electrodes=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'surfin_os'
             surf_os=option_value;
        case 'flag_show_electrodes'
            flag_show_electrodes=option_value;
        otherwise
            fprintf('unknown option [%s].\n',option);
            fprintf('error!\n');
            return;
    end;
end;
                 
%topo_config.electrodes=electrodes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[verts_os, faces_os] = mne_read_surface(surf_os);

%topo_config.faces_os=faces_os;
%topo_config.verts_os=verts_os;

fvc=repmat([256 180 100]./256,[size(verts_os,1),1]);
idx=find(verts_os(:,3)>0.01);
fvc(idx,:)=repmat([0 0 1],[length(idx),1]);

P_tmp=patch('Faces',faces_os,'Vertices',verts_os,'FaceVertexCData',fvc,'FaceColor','flat','edgecolor','none');
 
axis equal off; material dull;


hold on;
view(-2,80); camlight;

for ii=1:length(topo_config.electrodes)
    %fprintf('click to locate electrode [%s]]\n',electrodes{ii});
    %waitforbuttonpress 
    %pt=inverse_select3d(P_tmp);
    pt(1)=topo_config.electrodes_pos(ii,1);
    pt(2)=topo_config.electrodes_pos(ii,2);
    pt(3)=topo_config.electrodes_pos(ii,3);
    click_point=plot3(pt(1),pt(2),pt(3),'.');
    set(click_point,'color','c','markersize',20);
    
    if(flag_show_electrodes)
        h=text(pt(1)*1.1,pt(2)*1.1,pt(3)*1.1,topo_config.electrodes{ii});
        set(h,'color','y','fontsize',14,'fontname','helvetica');
    end;
    %[dummy,min_idx]=min(sum(abs(verts_os-repmat(pt(:)',[size(verts_os,1),1])).^2,2));

    %topo_config.electrodes_pos(ii,:)=pt';
    %topo_config.electrodes_vertex(ii)=min_idx;
end;
set(gcf,'color','k','invert','off');
axis vis3d;