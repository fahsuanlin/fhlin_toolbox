function [overlay_vol_stc, overlay_vol_idx]=etc_vol2surf(overlay_vol,varargin)
%
% etc_vol2surf  converts a MRI volume into surface STC
%
%
% [overlay_vol_stc, overlay_vol_idx]=etc_vol2surf(overlay_vol,varargin)
%
% overlay_vol: an MRI object with 'vol' field containing 3D/4D values to be
% rendered on a surface
% 
% 'subject': name of FreeSurer subject
% 'subjects_dir': folder name of the environment variable SUBJECTS_DIR
% 'vol_reg', a 4x4 registration matrix to transform the surface coordinates
% from the chosen subject to the subject implied by the variable
% 'overlay_vol'.
%
% fhlin@oct. 17, 2019
%

subjects_dir=getenv('SUBJECTS_DIR');
subject='fsaverage';

overlay_vol_stc=[];
overlay_vol_idx=[];

orig_vertex_coords=[];
vertex_coords=[];
faces=[];

vol_reg=eye(4);

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'subject'
            subject=option_value;
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'vol_reg'
            vol_reg=option_value;
    end;
end;


    %loading vertices/faces for both hemispheres.
    for hemi_idx=1:2
        switch hemi_idx
            case 1
                hemi_str='lh';
            case 2
                hemi_str='rh';
        end;
        
    
        file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi_str,'orig');
        %fprintf('reading orig [%s]...\n',file_orig_surf);
        [hemi_orig_vertex_coords{hemi_idx}, hemi_orig_faces{hemi_idx}] = read_surf(file_orig_surf);
    end;

    

%prepare mapping overlay values from "overlay_vol"
if(~isempty(overlay_vol))
    
    overlay_vol_value=reshape(overlay_vol.vol,[size(overlay_vol.vol,1)*size(overlay_vol.vol,2)*size(overlay_vol.vol,3), size(overlay_vol.vol,4)]);
    
    [C,R,S] = meshgrid([1:size(overlay_vol.vol,2)],[1:size(overlay_vol.vol,1)],[1:size(overlay_vol.vol,3)]);
    CRS=[C(:) R(:) S(:)];
    CRS=cat(2,CRS,ones(size(CRS,1),1))';
    
    
    for hemi_idx=1:2
        
        %choose 10242 sources arbitrarily for cortical soruces
        vol_A(hemi_idx).v_idx=[1:10242]-1;
        
        %vol_A(hemi_idx).vertex_coords=hemi_vertex_coords{hemi_idx};
        %vol_A(hemi_idx).faces=hemi_faces{hemi_idx};
        vol_A(hemi_idx).orig_vertex_coords=hemi_orig_vertex_coords{hemi_idx};
        
        SurfVertices=cat(2,vol_A(hemi_idx).orig_vertex_coords(vol_A(hemi_idx).v_idx+1,:),ones(length(vol_A(hemi_idx).v_idx),1));
                
        %vol_vox_tmp=(inv(vol.tkrvox2ras)*(vol_reg)*(SurfVertices.')).';
        vol_vox_tmp=(inv(overlay_vol.tkrvox2ras)*(vol_reg)*(SurfVertices.')).';
        vol_vox_tmp=round(vol_vox_tmp(:,1:3));
        
        all_idx=[1:prod(overlay_vol.volsize(1:3))];
        %[cort_idx,ii]=unique(sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3)));
        
        cort_idx=sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3));
        ii=[1:length(cort_idx)];
        vol_A(hemi_idx).v_idx=vol_A(hemi_idx).v_idx(ii);
        non_cort_idx=setdiff(all_idx,cort_idx);
        
        n_source(hemi_idx)=length(non_cort_idx)+length(cort_idx);
        n_dip(hemi_idx)=n_source(hemi_idx)*3;
              
        
        all_coords=inv(vol_reg)*overlay_vol.tkrvox2ras*CRS;
        all_coords=all_coords(1:3,:)';
        vol_A(hemi_idx).loc=all_coords(cort_idx,:);
        vol_A(hemi_idx).wb_loc=all_coords(non_cort_idx,:)./1e3;
        
        midx=[cort_idx(:)' non_cort_idx(:)'];
        overlay_vol_stc{hemi_idx}(1:length(vol_A(hemi_idx).v_idx),:)=overlay_vol_value(midx(1:length(cort_idx)),:);
        %overlay_vol_stc{hemi_idx}(length(vol_A(hemi_idx).v_idx)+1:n_source(hemi_idx),:)=overlay_vol_value(midx(length(cort_idx)+1:end),:);

        overlay_vol_idx{hemi_idx}=vol_A(hemi_idx).v_idx;
    end;
end;    