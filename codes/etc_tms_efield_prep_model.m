function [status, t, P, normals, Center, Area, Indicator, name, tissue, cond, enclosingTissueIdx, condin, condout, contrast, tneighbor, RnumberE, ineighborE, EC, file_mesh, file_meshp] =etc_tms_efield_prep_model(file_tissue_index, varargin)
%
%
% etc_tms_efield_prep_model a wrapper for calculating the e-field geneated by a
% TMS coil; This is only for preparing TMS coil and head models.
%
% fhlin@March 10 2024
%
%   This is a mesh processor script: it computes basis triangle parameters
%   and necessary potential integrals, and constructs a combined mesh of a
%   multi-object structure (for example, a head or a whole body)
%
%   Copyright SNM/WAW 2017-2020



% t=[];
% P=[];
% normals=[];
Center=[];
Area=[];
Indicator=[];
name=[];
tissue=[];
cond=[];
enclosingTissueIdx=[];
condin=[];
condout=[];
contrast=[];

tneighbor=[];
RnumberE=[];
ineighborE=[];
EC=[];


status=0;

flag_display=1;
flag_save=1;
file_mesh = 'CombinedMesh.mat';
file_meshp  = 'CombinedMeshP.mat';

path_tissue_mesh='.';

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'flag_save'
            flag_save=option_value;
        case 'file_mesh'
            file_mesh=option_value;
        case 'file_meshp'
            file_meshp=option_value;
        case 'path_tissue_mesh'
            path_tissue_mesh=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option)
            return;
    end;
end;


%% Load tissue filenames and tissue display names from index file
if(exist(sprintf('%s/%s',path_tissue_mesh,file_tissue_index),'file'))
    [name, tissue, cond, enclosingTissueIdx] = tissue_index_read(sprintf('%s/%s',path_tissue_mesh,file_tissue_index));
else
    fprintf('No tissue index file specified!\n');

    return;
end;
%%  Generic tissue list (for graphics only)
% tissue{1} = ' scalp'; 
% tissue{2} = ' skull';
% tissue{3} = ' CSF'; 
% tissue{4} = ' GM';
% tissue{5} = ' cerebellum'; 
% tissue{6} = ' WM'; 
% tissue{7} = ' ventricles';

%%  Load tissue meshes and combine individual meshes into a single mesh
tic
PP = [];
tt = [];
nnormals = [];
Indicator = [];

%   Combine individual meshes into a single mesh
for m = 1:length(name)
    load(name{m}); 
    P = P*1e-3;     %  only if the original data were in mm!
    tt = [tt; t+size(PP, 1)];
    PP = [PP; P];
    nnormals = [nnormals; normals];    
    Indicator= [Indicator; repmat(m, size(t, 1), 1)];
    if(flag_display)
        disp(['Successfully loaded file [' name{m} ']']);
    end;
end
t = tt;
P = PP;
normals = nnormals;
LoadBaseDataTime = toc;

%%  Fix triangle orientation (just in case, optional)
tic
t = meshreorient(P, t, normals);
%%   Process other mesh data
Center      = 1/3*(P(t(:, 1), :) + P(t(:, 2), :) + P(t(:, 3), :));  %   face centers
Area        = meshareas(P, t);  
SurfaceNormalTime = toc;

%%  Assign facet conductivity information
tic
condambient = 0.0; %   air
[contrast, condin, condout] = assign_initial_conductivities(cond, condambient, Indicator, enclosingTissueIdx);
InitialConductivityAssignmentTime = toc;

%%  Check for and process triangles that have coincident centroids
tic
if(flag_display)
    disp('Checking combined mesh for duplicate facets ...');
end;
[P, t, normals, Center, Area, Indicator, condin, condout, contrast] = ...
    clean_coincident_facets(P, t, normals, Center, Area, Indicator, condin, condout, contrast);
if(flag_display)
    disp('Resolved all duplicate facets');
end;
N           = size(t, 1);
DuplicateFacetTime = toc;

%%   Find topological neighbors
tic
DT = triangulation(t, P); 
tneighbor = neighbors(DT);
% Fix cases where not all triangles have three neighbors
tneighbor = pad_neighbor_triangles(tneighbor);

%%   Save base data
if(flag_save)
    if(flag_display)
        fprintf('saving [%s]...\n',sprintf('%s/%s',path_tissue_mesh,file_mesh));
    end;
    save(sprintf('%s/%s',path_tissue_mesh,file_mesh), 'P', 't', 'normals', 'Area', 'Center', 'Indicator', 'name', 'tissue', 'cond', 'enclosingTissueIdx', 'condin', 'condout', 'contrast');
end;
ProcessBaseDataTime = toc;

%%   Add accurate integration for electric field/electric potential on neighbor facets
%   Indexes into neighbor triangles
numThreads = 4;        %   number of cores to be used
RnumberE        = 4;    %   number of neighbor triangles for analytical integration (fixed, optimized)
ineighborE      = knnsearch(Center, Center, 'k', RnumberE);   % [1:N, 1:Rnumber]
ineighborE      = ineighborE';           %   do transpose    
EC         = meshneighborints_2(P, t, normals, Area, Center, RnumberE, ineighborE, numThreads);

%%   Normalize sparse matrix EC by variable contrast (for speed up)
N   = size(Center, 1);
ii  = ineighborE;
jj  = repmat(1:N, RnumberE, 1); 
CO  = sparse(ii, jj, contrast(ineighborE));
EC  = CO.*EC;

tic
if(flag_save)
    if(flag_display)
        fprintf('saving [%s]...\n',sprintf('%s/%s',path_tissue_mesh,file_meshp));
    end;
    save(sprintf('%s/%s',path_tissue_mesh,file_meshp), 'tneighbor',  'RnumberE',   'ineighborE', 'EC', '-v7.3');
end;
SaveBigDataTime = toc;


try
    global etc_render_fsbrain;

    if(isfield(etc_render_fsbrain,'tissue_def_file'))
        fn=etc_render_fsbrain.tissue_def_file;
    else
        fn='';
    end;

    etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.PrepModelLamp),'g',fn);
    etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.EfieldCalclLamp),'r');
catch
end;

status=1;