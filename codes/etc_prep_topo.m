function etc_prep_topo(varargin)

%default values
%outer-scalp mesh file
surfin_os='/Users/fhlin_admin/workspace/subjects//lf/bem/watershed/lf_outer_skull_surface';

%electrode names
electrodes={
    'EEG Fp1-Ref'
    'EEG Fp2-Ref'
    'EEG F7-Ref'
    'EEG F3-Ref'
    'EEG Fz-Ref'
    'EEG F4-Ref'
    'EEG F8-Ref'
    'EEG T3-Ref'
    'EEG C3-Ref'
    'EEG Cz-Ref'
    'EEG C4-Ref'
    'EEG T4-Ref'
    'EEG T5-Ref'
    'EEG P3-Ref'
    'EEG Pz-Ref'
    'EEG P4-Ref'
    'EEG T6-Ref'
    'EEG O1-Ref'
    'EEG O2-Ref'
    'EEG A1-Ref'
    'EEG A2-Ref'
    };


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'surfin_os'
            surfin_os=option_value;
        case 'electrodes'
            electrodes=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
            
    end;
end;

[verts_os, faces_os] = mne_read_surface(surfin_os);

fvc=repmat([256 180 100]./256,[size(verts_os,1),1]);
%idx=find(verts_os(:,3)>-0.00);
tmp=verts_os(:,3)-0.4.*verts_os(:,2);
idx=find(tmp>-0.02);
fvc(idx,:)=repmat([1 1 1].*0.6,[length(idx),1]);

P_tmp=patch('Faces',faces_os,'Vertices',verts_os,'FaceVertexCData',fvc,'FaceColor','flat','edgecolor','none');

axis equal off; material dull;


hold on;
view(-2,80); 
camlight(30,-30);
camlight(140,-30);
camlight(-90,30);


set(gcf,'WindowButtonDownFcn','etc_prep_topo_handle(''bd'')');
set(gcf,'KeyPressFcn','toposcalp_prep_handle(''kb'')');
set(gcf,'invert','off');


                
global toposcalp_prep_obj;

toposcalp_prep_obj.P=P_tmp;
toposcalp_prep_obj.verts=verts_os;
toposcalp_prep_obj.faces=faces_os;
toposcalp_prep_obj.ch_idx=1;
toposcalp_prep_obj.electrodes=electrodes;
toposcalp_prep_obj.electrodes_pos=[];
toposcalp_prep_obj.flag_done=0;
toposcalp_prep_obj.fvc=fvc;

fprintf('click to locate electrode [%s]]\n',toposcalp_prep_obj.electrodes{toposcalp_prep_obj.ch_idx});


return;



                
