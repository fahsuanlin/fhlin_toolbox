function [overlay_vol, overlay_D,loc_vol_idx]=etc_volstc2vol(overlay_vol_stc,vol_A,vol,varargin)

overlay_vol=[];
loc_vol_idx={};
overlay_D={};
overlay_smooth=5;
vol_reg=eye(4);
flag_display=1;

flag_morph=0;
targ_subj=[];
targ_xfm=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        %case 'overlay_vol'
        %    overlay_vol=option_value;
        case 'loc_vol_idx'
            loc_vol_idx=option_value;
        case 'overlay_d'
            overlay_D=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'vol_reg'
            vol_reg=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_morph'
            flag_morph=option_value;
        case 'targ_subj'
            targ_subj=option_value;
        case 'targ_xfm'
            targ_xfm=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


%try
smooth_kernel=[];
for time_idx=1:size(overlay_vol_stc,2)
    if(flag_display)
        fprintf('vol2stc to vol...[%04d|%04d]...',time_idx,size(overlay_vol_stc,2));
    end;
    
    %initialize
    loc_vol=[];
    for hemi_idx=1:2
        
        n_dip(hemi_idx)=(size(vol_A(hemi_idx).loc,1)+size(vol_A(hemi_idx).wb_loc,1)).*3;
        n_source(hemi_idx)=n_dip(hemi_idx)/3;
        
        switch hemi_idx
            case 1
                offset=0;
            case 2
                offset=n_source(1);
        end;
        
        %get source estimates at cortical and sub-cortical locations
        if(~isempty(overlay_vol_stc))
            X_hemi_cort=overlay_vol_stc(offset+1:offset+length(vol_A(hemi_idx).v_idx),time_idx);
            X_hemi_subcort=overlay_vol_stc(offset+length(vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),time_idx);
            
            %smoothing over the volume
            if(isfield(vol_A(hemi_idx),'src_wb_idx'))
                v=zeros(size(vol.vol));
                v(vol_A(hemi_idx).src_wb_idx)=overlay_vol_stc(offset+length(vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),time_idx);
                pos_idx=find(v(:)>10.*eps);
                neg_idx=find(v(:)<-10.*eps);
                mx=max(v(pos_idx));
                mn=max(-v(neg_idx));
                fwhm=5; %<size of smoothing kernel; fwhm in mm.
                [vs,smooth_kernel]=fmri_smooth(v,fwhm,'vox',[vol.xsize,vol.ysize,vol.zsize],'kernel',smooth_kernel);
                pos_idx=find(vs(:)>10.*eps);
                neg_idx=find(vs(:)<-10.*eps);
                if(length(pos_idx)>1&&~isempty(mx))
                    vs(pos_idx)=fmri_scale(vs(pos_idx),mx,0);
                end;
                if(length(neg_idx)>1&&~isempty(mn))
                    vs(neg_idx)=-fmri_scale(-vs(neg_idx),mn,0);
                end;
                Vs{hemi_idx}=vs;
                X_hemi_subcort=vs(vol_A(hemi_idx).src_wb_idx);
            else
                Vs{hemi_idx}=[];
            end;
        else
            X_hemi_cort=[];
            X_hemi_subcort=[];
        end;
        
        %smooth source estimates at cortical locations
        if(~isempty(vol_A(hemi_idx).vertex_coords));
            if(~isempty(X_hemi_cort))
                ov=zeros(size(vol_A(hemi_idx).vertex_coords,1),1);
                ov(vol_A(hemi_idx).v_idx+1)=X_hemi_cort;
            else
                ov=[];
            end;
            flag_overlay_D_init=1;
            %if(isfield(etc_render_fsbrain,'overlay_D'))
            if(~isempty(overlay_D))
                if(length(overlay_D)==2)
                    if(~isempty(overlay_D{hemi_idx}))
                        flag_overlay_D_init=0;
                    end;
                end;
            end;
            if(flag_overlay_D_init) overlay_D{hemi_idx}=[];end;
            
            if(~isempty(ov))
                [ovs,dd0,dd1,overlay_Ds,overlay_D{hemi_idx}]=inverse_smooth('','vertex',vol_A(hemi_idx).vertex_coords','face',vol_A(hemi_idx).faces','value',ov,'value_idx',vol_A(hemi_idx).v_idx+1,'step',overlay_smooth,'n_ratio',length(ov)/size(X_hemi_cort,1),'flag_display',0,'flag_regrid',0,'flag_fixval',0,'D',overlay_D{hemi_idx});
            else
                ovs=[];
            end;
            %assemble smoothed source at cortical locations and sources at sub-cortical locations
            X_wb{hemi_idx}=cat(1,ovs(:),X_hemi_subcort(:));
            
            flag_cal_loc_vol_idx=1;
            %if(isfield(etc_render_fsbrain,'loc_vol_idx'))
            if(~isempty(loc_vol_idx))
                if(length(loc_vol_idx)==2)
                    if(~isempty(loc_vol_idx{hemi_idx}))
                        flag_cal_loc_vol_idx=0;
                    end;
                end;
            end;
            
            
            if(flag_cal_loc_vol_idx==1)
                loc_vol_idx{hemi_idx}=[];
                %get coordinates from surface to volume
                loc=cat(1,vol_A(hemi_idx).vertex_coords./1e3,vol_A(hemi_idx).wb_loc);
                %loc=cat(1,etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords./1e3,etc_render_fsbrain.vol_A(hemi_idx).wb_loc);
                loc_surf=[loc.*1e3 ones(size(loc,1),1)]';
                tmp=inv(vol.tkrvox2ras)*(vol_reg)*loc_surf;
                loc_vol{hemi_idx}=round(tmp(1:3,:))';
                loc_vol{hemi_idx}=round(tmp(1:3,:))';
                loc_vol_idx{hemi_idx}=sub2ind(size(vol.vol),loc_vol{hemi_idx}(:,2),loc_vol{hemi_idx}(:,1),loc_vol{hemi_idx}(:,3));
            end;
        else
            X_wb{hemi_idx}=[];
        end;
    end;
    
    
    tmp=zeros(size(vol.vol));
    
    for hemi_idx=1:2
        if(~isempty(Vs{hemi_idx}))
            tmp=tmp+Vs{hemi_idx};
        end;
        if(~isempty(X_wb{hemi_idx}))
            tmp(loc_vol_idx{hemi_idx})=X_wb{hemi_idx};
        end;
    end;
    
    if(isempty(overlay_vol))
        overlay_vol=vol;
        
        %allocating memory; can be problematic....
        if(~flag_morph)
            overlay_vol.vol=zeros([size(vol.vol,1),size(vol.vol,2),size(vol.vol,3),size(overlay_vol_stc,2)]);
        else
            overlay_vol=[];
        end;
    end;
    if(~flag_morph)
        overlay_vol.vol(:,:,:,time_idx)=tmp;
    else
        overlay_vol=vol;
        overlay_vol.vol=tmp;
    end;
    
    if(flag_morph&&~isempty(targ_subj)&&~isempty(targ_xfm))
        if(flag_display)
            fprintf('morphing...');
        end;
        if(time_idx==1)
            %                 if(strcmp(target_subject,'fsaverage'))
            %                     targ_subj=MRIread('/Applications/freesurfer/average/mni305.cor.subfov2.mgz'); %MNI-Talairach space with 2mm resolution (for MAC)
            %                     %targ_subj=MRIread(sprintf('%s/average/mni305.cor.subfov2.mgz',getenv('FREESURFER_HOME'))); %MNI-Talairach space with 2mm resolution (for server)
            %
            %                     fprintf('loading transformation for subject [%s]...\n',subject);
            %                     targ_xfm=etc_read_xfm('subject',subject);
            %                 end;
            
            
            %mov=MRIread(fn_under_output);
            R=vol.tkrvox2ras*inv(vol.vox2ras)*inv(targ_xfm)*targ_subj.vox2ras*inv(targ_subj.tkrvox2ras);
            %R=inv(vol.vox2ras)*inv(targ_xfm)*(targ_subj.vox2ras);
            mri_underlay_tal=etc_MRIvol2vol(vol,targ_subj,R);
            %MRIwrite(mri_underlay_tal,sprintf('%s%s_under-tal.2mm.mgh',output_stem,fstem));
            
            mri_overlay_tal=mri_underlay_tal;
            mri_overlay_tal.nframes=size(overlay_vol_stc,2);
            mri_overlay_tal.vol=zeros(mri_overlay_tal.volsize(1),mri_overlay_tal.volsize(2),mri_overlay_tal.volsize(3),size(overlay_vol_stc,2));
        end;
        %mov=MRIread(fn_output);
        R=vol.tkrvox2ras*inv(vol.vox2ras)*inv(targ_xfm)*(targ_subj.vox2ras)*inv(targ_subj.tkrvox2ras);
        %R=inv(vol.vox2ras)*inv(targ_xfm)*(targ_subj.vox2ras);
        tmp=etc_MRIvol2vol(overlay_vol,targ_subj,R);
        mri_overlay_tal.vol(:,:,:,time_idx)=tmp.vol;
    else
        mri_overlay_tal=[];
    end;
    
    
    if(flag_display)
        fprintf('\r');
    end;
    
end;
fprintf('\n');

if(~isempty(mri_overlay_tal))
    overlay_vol=mri_overlay_tal;
end;
overlay_vol.nframes=time_idx;

%catch ME
%end;
return;
