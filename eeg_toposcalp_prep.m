function topo_config=toposcalp_prep(electrodes,varargin)
% toposcalp_prep    Prepare topology of EEG/MEG data on a scalp
%
% topo_config=toposcalp_prep(electrodes,varargin)
%
% fhlin@jan. 3 2016
%

% electrodes={
%  'Fp1';
%  'Fp2';
%  'F3';
%  'F4';
%  'C3';
%  'C4';    
%  'P3';
%  'P4';
%  'O1';
%  'O2';
%  'F7';
%  'F8';
%  'T7';
%  'T8';
%  'P7';
%  'P8';
%  'Fz';
%  'Cz';
%  'Pz';
%  'FC1';
%  'FC2';
%  'CP1';
%  'CP2';
%  'FC5';
%  'FC6';
%  'CP5';
%  'CP6';
%  'TP9';
%  'TP10';
%  };
 
topo_config=[];

surf_os='/Users/fhlin_admin/workspace/subjects//lf/bem/watershed/lf_outer_skull_surface';


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'surfin_os'
             surf_os=option_value;
        otherwise
            fprintf('unknown option [%s].\n',option);
            fprintf('error!\n');
            return;
    end;
end;
                 
topo_config.electrodes=electrodes;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[verts_os, faces_os] = mne_read_surface(surf_os);

topo_config.faces_os=faces_os;
topo_config.verts_os=verts_os;

fvc=repmat([256 180 100]./256,[size(verts_os,1),1]);
idx=find(verts_os(:,3)>0.01);
fvc(idx,:)=repmat([0 0 1],[length(idx),1]);

P_tmp=patch('Faces',faces_os,'Vertices',verts_os,'FaceVertexCData',fvc,'FaceColor','flat','edgecolor','none');
 
axis equal off; material dull;


hold on;
view(-2,80); camlight;
set(gcf,'color','k','invert','off');
axis vis3d;

for ii=1:length(electrodes)
    fprintf('click to locate electrode [%s]]\n',electrodes{ii});
    waitforbuttonpress 
    pt=inverse_select3d(P_tmp);
    click_point=plot3(pt(1),pt(2),pt(3),'.');
    set(click_point,'color','y');
    
    [dummy,min_idx]=min(sum(abs(verts_os-repmat(pt(:)',[size(verts_os,1),1])).^2,2));

    topo_config.electrodes_pos(ii,:)=pt';
    topo_config.electrodes_vertex(ii)=min_idx;
end;