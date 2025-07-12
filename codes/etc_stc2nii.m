function fn=etc_stc2nii(stc_fstem,varargin)
% etc_stc2nii   convert stc files into volumne nii files
%
% fn=etc_stc2nii(stc_fstem,[option, option_value,...]);
%
% stc_fstem: str cell for stc file stem
%
% options:
%   'subject': subject ID; 'fsvaerage' (default)
%   'hemi': hemisphere; 'lh', 'rh', or {'lh','rh'} (default).
%   'flag_under': create underlay nii file; 1 (default)
%
% fhlin@july 12 2025
%

fn='';
subject='fsaverage';
hemi={'lh','rh'};

flag_under=1;
flag_display=1;

%stc_fstem={
%    'diff_fconn_rest_surf_entorhinal_hippo_aseg_mc_t';
%    };
for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'hemi'
            hemi=option_value;
        case 'subject'
            subject=option_value;
        case 'flag_under'
            flag_under=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

for f_idx=1:length(stc_fstem)
    [stc_lh,v_lh]=inverse_read_stc(sprintf('%s-lh.stc',stc_fstem{f_idx}));
    [stc_rh,v_rh]=inverse_read_stc(sprintf('%s-rh.stc',stc_fstem{f_idx}));


     f=figure; 
     set(f,'visible','off');
     h=etc_render_fsbrain('subject',subject,'hemi',hemi,'overlay_vertex',{v_lh,v_rh},'overlay_stc',{stc_lh,stc_rh});
 
     
     fn{f_idx}=sprintf(sprintf('%s.nii',stc_fstem{f_idx}));
     if(flag_display)
         fprintf('writing overlay [%s]...\n',fn{f_idx});
     end;
     MRIwrite(h.overlay_vol,fn{f_idx});

    if(flag_under)
        fn{f_idx}=sprintf(sprintf('%s_under.nii',stc_fstem{f_idx}));
        if(flag_display)
            fprintf('writing underlay [%s]...\n',fn{f_idx});
        end;
        MRIwrite(h.vol,fn{f_idx});
    end;
end;

return;