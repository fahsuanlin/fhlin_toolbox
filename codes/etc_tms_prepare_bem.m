function [status, bem_obj]=etc_efm_prepare_bem(subject,file_surf,output_file_surf,tissue_name,tissue_conductivity,tissue_enclosing,file_bem, varargin)
%%
% etc_efm_prepare_bem: prepare head/brain boundary element models for TMS
% e-field modeling
%
% [status,
% bem_obj]=etc_efm_prepare_bem(subject,file_surf,output_file_surf,tissue_name,tissue_conductivity,tissue_enclosing,file_bem);
%
% subject: subject to be modeled 
% file_surf: a string cell of file names for head/brain geometries to be read.
% output_file_surf: a string cell of file names of prepared head/brain geometries
% tissue_name: a strong cell of names for head/brain geometries
% tissue_conductivity: a vector of conducitivities for each surface (S/m)
% tissue_enclosing: a string cell of enclosing head/brain geometries
% file_bem: a file name for generated BEM description
%
% status: a flag of successful execution of the function
% bem_obj: object array of surfaces/bems
% 
% fhlin@June 11 2024


file_bem='';
status=0;

flag_display=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

if(isempty(file_bem))
    file_bem='tissue_index_bem.txt';
end;

% examples of calling parameters
%
% subjects_dir='/Users/fhlin/workspace/eegmri_memory/subjects';
% subject='s002';
%
% file_surf={
% {'outer_skin.surf'},        % scalp
% {'outer_skull.surf'},       % outer skull
% {'inner_skull.surf'},       % inner skull
% {'../surf/lh.orig'},        % brain
% {'../surf/rh.orig'},        % brain
% };
%
% output_file_surf={
% 'skin',
% 'skull',
% 'csf',
% 'gm_lh',
% 'gm_rh',
% };
%
% tissue_name={
%     'Skin';     %scalp
%     'Skull';    %outer skull
%     'CSF';      %inner skull
%     'GM_LH';    %brain
%     'GM_RH';    %brain
%     };
%
% % Electric field calculations in brain stimulation based on finite elements: An optimized processing pipeline for the generation and usage of accurate individual head models Hum. Brain Mapp., 34 (4) (2013), pp. 923-935, 10.1002/hbm.21479
% tissue_conductivity=[
%     0.465; % scalp (below scalp)
%     0.010; % skull (below outer skull)
%     1.654; % CSF (below inner skull)
%     0.275; % brain (below brain)
%     0.275; % brain (below brain)
%     ];
%
% tissue_enclosing={
%     'FreeSpace';    % ouside scalp
%     'Skin';         % outside outer skull
%     'Skull';        % outside inner skull
%     'CSF';          % otuside brain
%     'CSF';          % otuside brain
%     };
%
%
% file_bem='tissue_index_bem.txt';

subjects_dir=getenv('SUBJECTS_DIR');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f_idx=1:length(file_surf)
    vv=[];ff=[];
    for i_idx=1:length(file_surf{f_idx})
        if(length(file_surf{f_idx})==1)
            [vv,ff]=read_surf(sprintf('%s/%s/bem/%s',subjects_dir,subject, file_surf{f_idx}{i_idx}));
        else
            [vv_tmp,ff_tmp]=read_surf(sprintf('%s/%s/%s',subjects_dir,subject, file_surf{f_idx}{i_idx}));
            vv=cat(1,vv,vv_tmp);
            ff=cat(1,ff,ff_tmp);
        end;
    end;
    bem_obj(f_idx).filename=sprintf('%s/%s/bem/%s',subjects_dir,subject, file_surf{f_idx}{i_idx});
    
    bem_obj(f_idx).vertex=vv;
    bem_obj(f_idx).face=ff;

    bem_obj(f_idx).face=bem_obj(f_idx).face+1;

    TR = triangulation(bem_obj(f_idx).face,bem_obj(f_idx).vertex);

    bem_obj(f_idx).surf_center = incenter(TR);
    bem_obj(f_idx).surf_norm = faceNormal(TR);

    %save files for e-field modeling
    P=bem_obj(f_idx).vertex;
    t=bem_obj(f_idx).face;
    normals=bem_obj(f_idx).surf_norm;
    save(sprintf('%s_%s.mat',subject,output_file_surf{f_idx}),'P','t','normals');

    bem_obj(f_idx).filemat=sprintf('%s_%s.mat',subject,output_file_surf{f_idx});

    if(flag_display)
        hold on;
        colors=get(gca,'colororder');
        h=patch('vertices',bem_obj(f_idx).vertex,'faces',bem_obj(f_idx).face,'edgecolor','none','facecolor',colors(f_idx,:),'facealpha',0.2);
        %quiver3(bem_obj(f_idx).surf_center(:,1),bem_obj(f_idx).surf_center(:,2),bem_obj(f_idx).surf_center(:,3),bem_obj(f_idx).surf_norm(:,1),bem_obj(f_idx).surf_norm(:,2),bem_obj(f_idx).surf_norm(:,3),0.5,'color','r');
    end;
end;

if(flag_display)
    view(-160,20);
    lighting phong
    camlight
    axis off vis3d equal
end;

%%%%%%%%%%%%%%%%%%%%%

try
    [file,path,indx] = uiputfile(file_bem);
    fn=sprintf('%s%s',path,file);
    if(file==0) return; end;

    fp=fopen(fn,'w');

    for tissue_idx=1:length(tissue_name)
        tn=tissue_name{tissue_idx};
        fprintf(fp,'>%s : %s_%s.mat : %1.4f : %s \n',tn,subject,output_file_surf{tissue_idx},tissue_conductivity(tissue_idx),tissue_enclosing{tissue_idx});
    end;

    fclose(fp);
    status=1;
catch
    fprintf('error in writing tissue file!\n');

end;