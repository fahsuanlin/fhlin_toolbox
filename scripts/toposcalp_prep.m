close all; clear all;

surfin_os='/Users/fhlin_admin/workspace/subjects//lf/bem/watershed/lf_outer_skull_surface';

[verts, faces] = mne_read_surface(surfin_os);
[nv,nf]=reducepatch(faces,verts,0.1);

etc_render_topo('vol_vertex',verts,'vol_face',faces-1);

electrodes={
    'Fp1';
    'Fp2';
    'F7';
    'F3';
    'Fz';
    'F4';
    'F8';
    'T3';
    'C3';
    'Cz';
    'C4';
    'T4';
    'T5';
    'P3';
    'Pz';
    'P4';
    'T6';
    'O1';
    'O2';
    'A1';
    'A2';
     };
 
 output_file='toposcalp_prep.mat';
 verts_electrode_idx=[];
 

fprintf('saving [%s] for later scalp topology rendering...\n',output_file);
save(output_file,'faces','verts','verts_electrode_idx','electrodes');
