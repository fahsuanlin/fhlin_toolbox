function surf_val = etc_MRIvol2surf(mov,targ,R,varargin)
% vol = etc_MRIvol2surf(mov,targ,<R>)
%
% mov: the volume image to be moved. an MRI object from MRIread. can have
% multiple frames.
% targ: the target surface. an MRI object from MRIread
%
% R maps targ to mov (mov = R * targ).
%

%
subjects_dir=getenv('SUBJECTS_DIR');
subject='fsaverage';
surf='inflated';
hemi='lh'; %hemi={'lh','rh'}; for showing both hemispheres;

mov_targ=[]; %the transformed mov to targ object.

flag_display=0;

frames=[]; %all time points

surf_val=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch(lower(option))
        case 'flag_display'
            flag_display=option_value;
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'subject'
            subject=option_value;
        case 'surf'
            surf=option_value;
        case'hemi'
            hemi=option_value;
        case 'frames'
            frames=option_value;
        case 'mov_targ'
            mov_targ=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


if(~ispc)
    file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,surf);
else
    file_surf=sprintf('%s\\%s\\surf\\%s.%s',subjects_dir,subject,hemi,surf);    
end;
if(flag_display) fprintf('reading [%s]...\n',file_surf); end;

[vertex_coords, faces] = read_surf(file_surf);

vertex_coords_hemi=vertex_coords;
faces_hemi=faces;

if(~ispc)
    file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,'orig');
else
    file_orig_surf=sprintf('%s\\%s\\surf\\%s.%s',subjects_dir,subject,hemi,'orig');    
end;
if(flag_display) fprintf('reading orig [%s]...\n',file_orig_surf); end;

[orig_vertex_coords, orig_faces] = read_surf(file_orig_surf);

orig_vertex_coords_hemi=orig_vertex_coords;
orig_faces_hemi=faces;

%loading vertices/faces for both hemispheres.
for hemi_idx=1:2
    switch hemi_idx
        case 1
            hemi_str='lh';
        case 2
            hemi_str='rh';
    end;
    if(~ispc)
        file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi_str,surf);
    else
        file_surf=sprintf('%s\\%s\\surf\\%s.%s',subjects_dir,subject,hemi_str,surf);
    end;
    %fprintf('reading [%s]...\n',file_surf);
    [hemi_vertex_coords{hemi_idx}, hemi_faces{hemi_idx}] = read_surf(file_surf);
    
    if(~ispc)
        file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi_str,'orig');
    else
        file_orig_surf=sprintf('%s\\%s\\surf\\%s.%s',subjects_dir,subject,hemi_str,'orig');    
    end;
    %fprintf('reading orig [%s]...\n',file_orig_surf);
    [hemi_orig_vertex_coords{hemi_idx}, hemi_orig_faces{hemi_idx}] = read_surf(file_orig_surf);
end;

if(~ispc)
    targ_orig_vol=MRIread(sprintf('%s/%s/mri/orig.mgz',subjects_dir,subject));
else
    targ_orig_vol=MRIread(sprintf('%s\\%s\\mri\\orig.mgh',subjects_dir,subject));
end;

tmp=cat(2,orig_vertex_coords,ones(size(orig_vertex_coords,1),1));

CRS=inv(targ_orig_vol.tkrvox2ras)*R*tmp';
vox_ind=sub2ind([size(targ_orig_vol.vol,1),size(targ_orig_vol.vol,2),size(targ_orig_vol.vol,3)],CRS(2,:),CRS(1,:),CRS(3,:));

if(isempty(frames))
    frames=[1:size(mov.vol,4)];
end;

if(isempty(mov_targ))
    mov_targ=etc_MRIvol2vol(mov,targ_orig_vol,R,'frames',frames,'flag_display',flag_display);
end;

for t_idx=1:length(frames)
    if(flag_display) fprintf('*'); end;
    %mov_tmp=etc_MRIvol2vol(mov,targ_orig_vol,R,'frames',frames(t_idx));
    tmp=mov_targ.vol(:,:,:,t_idx);
    if(t_idx==1)
        surf_val=zeros(length(vox_ind),length(frames));
    end;
    surf_val(:,t_idx)=tmp(round(vox_ind));
end;
if(flag_display) fprintf('\n'); end;
return;


