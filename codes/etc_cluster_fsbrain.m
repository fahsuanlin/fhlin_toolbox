function output_file=etc_cluster_fsbrain(file_stc,threshold,varargin)

output_file_stem={};
output_file={};
target_subject='fsaverage';
source_subject='fsaverage';
aparc_filestem='aparc';
overlay_smooth=5;
sign_str='pos';
time_idx_pick=1;
minarea=40;

threshold_min=min(threshold);
threshold_max=max(threshold);

flag_fixval=0;
flag_regrid=1;
flag_regrid_zero=0;

overlay_exclude_fstem='';
overlay_exclude=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'target_subject'
            target_subject=option_value;
        case 'source_subject'
            source_subject=option_value;
        case 'aparc_filestem'
            aparc_filestem=option_value;
        case 'sign_str'
            sign_str=option_value;
        case 'time_idx_pick'
            time_idx_pick=option_value;
        case 'minarea'
            minarea=option_value;
        case 'flag_fixval'
            flag_fixval=option_value;
        case 'flag_regrid_zero'
            flag_regrid_zero=option_value;
        case 'flag_regrid'
            flag_regrid=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'overlay_exclude_fstem'
            overlay_exclude_fstem=option_value;
        case 'output_file_stem'
            output_file_stem=option_value;
        otherwise
            fprintf('unknown option [%s]\nerror!\n',option);
            return;
    end;
end;
pdir=pwd;

if(isempty(output_file_stem))
    output_file_stem=file_stc;
end;


for f_idx=1:length(file_stc)
    output_stem=sprintf('%s_cluster_%s',output_file_stem{f_idx},sign_str);
    output_stem(findstr(output_stem,'('))='_';
    output_stem(findstr(output_stem,')'))='_';
    for hemi_idx=1:2
        switch hemi_idx
            case 1
                hemi='lh';
            case 2
                hemi='rh';
        end;
        
        
        %excluding labels
        if(~isempty(overlay_exclude_fstem))
                overlay_exclude_tmp=inverse_read_label(sprintf('%s-%s.label',overlay_exclude_fstem,hemi));
                overlay_exclude=overlay_exclude_tmp+1;
        end;
        
        [stc,v_idx]=inverse_read_stc(sprintf('%s-%s.stc',file_stc{f_idx},hemi));
        
        stc(find(isnan(stc(:))))=0;
        
        [stcs]=etc_smooth_fsbrain(stc(:,time_idx_pick),v_idx,'hemi',hemi,'exc_vertex',overlay_exclude,'overlay_smooth',overlay_smooth,'flag_fixval',0,'flag_regrid_zero',flag_regrid_zero,'flag_regrid',flag_regrid);
                    
        inverse_write_wfile(sprintf('tmp-%s.w',hemi),stcs(:),[1:size(stcs,1)]-1);
        
        cmd=sprintf('!mri_surf2surf  --sfmt w --srcsubject fsaverage --trgsubject %s --hemi %s --sval %s/tmp-%s.w --tval ./tmp2-%s.mgh --tfmt mgh',target_subject, hemi, pdir,hemi, hemi);
        eval(cmd);
        
        output_file{end+1}=sprintf('%s-%s.txt',output_stem, hemi);
        cmd=sprintf('!mri_surfcluster --fwhm 10 --minarea %f --in tmp2-%s.mgh --subject %s --hemi %s --annot %s --thmin %f --thmax %f --sign %s --no-adjust --sum %s',minarea, hemi, target_subject, hemi, aparc_filestem, threshold_min, threshold_max, sign_str,output_file{end});
        eval(cmd)
        
        eval('!rm tmp*w tmp*mgh');        
    end;
end;

return;


%mri_surf2surf --sfmt w \
%--srcsubject ico \
%--trgsubject fsaverage \
%--hemi rh \
%--srcsurfval pls_120413_comp03_z-rh.w \
%--trgsurfval test-rh.mgh \
%--nsmooth-in 1 \
%--sfmt w \
%--tfmt mgh


%mri_surfcluster --in test-lh.mgh \
%   --subject fsaverage \
%   --hemi lh \
%   --annot aparc \
%   --thmin 2 \
%   --thmax 4\
%   --sign pos \
%   --no-adjust \
%   --sum pls_120413_comp03_z-lh.txt
%
