function image_fn=etc_stc2image(varargin)

subject={'fsaverage'};
view={'med','lat'};
hemi={'lh','rh'};
stcin='';
pick=[];
smooth=5;
output_stem='';
threshold=[];
surf='inflated';
alpha=1;

for i=1:length(varargin)/2;
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'hemi'
            hemi=option_value;
        case 'view'
            view=option_value;
        case 'stcin'
            stcin=option_value;
        case 'smooth'
            smooth=option_value;
        case 'threshold'
            threshold=option_value;
        case 'subject'
            subject=option_value;
        case 'surf'
            surf=option_value;
        case 'pick'
            pick=option_value;
        case 'output_stem'
            output_stem=option_value;
        case 'alpha'
            alpha=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

threshold=sort(threshold);
fthresh=threshold(1);
fmid=threshold(2);
fmax=threshold(3);

image_fn={};
for stc_idx=1:length(stcin)
    for subj_idx=1:length(subject)
        for pick_idx=1:length(pick)
            for view_idx=1:length(view)
                for hemi_idx=1:length(hemi)
                    if(isempty(output_stem))
                        %fn=sprintf('%s_%s_%04d_%s-%s.tif',stcin{stc_idx},subject{subj_idx},pick(pick_idx),view{view_idx},hemi{hemi_idx});
                        fn=sprintf('%s_%s_%1.1f_%1.1f_%1.1f',stcin{stc_idx},surf,fthresh,fmid,fmax);
                        fn(findstr(fn,'.'))='p';
                    else
                        %fn=sprintf('%s_%s_%04d_%s-%s.tif',output_stem,subject{subj_idx},pick(pick_idx),view{view_idx},hemi{hemi_idx});
                        fn=sprintf('%s_%s_%1.1f_%1.1f_%1.1f',output_stem,surf,fthresh,fmid,fmax);
                        fn(findstr(fn,'.'))='p';     
                    end;
                    
                    cmd=sprintf('!mne_make_movie --subject %s --spm --%s --stcin %s --view %s --fthresh %f --fmid %f --fmax %f --nocomments --tif %s --smooth %d --pick %d --surface %s --alpha %f', subject{subj_idx}, hemi{hemi_idx}, stcin{stc_idx}, view{view_idx}, fthresh, fmid, fmax,fn,smooth,pick(pick_idx),surf,alpha);
                    fprintf('%s',cmd);
                    eval(cmd);
                    
                    image_fn{end+1}=sprintf('%s-%05d.0-%s-%s.tif',fn,pick(pick_idx),view{view_idx},hemi{hemi_idx});
                end;
            end;
        end;
    end;
end;

return;

% mne_make_movie --subject fsaverage \
% 	--spm \
% 	--stcin ../average_fsaverage_kini_visual_gavg_01_inv_s_dspm \
% 	--rh \
% 	--view med \
% 	--fthresh 4 \
% 	--fmid 5 \
% 	--fmax 7 \
% 	--nocomments \
% 	--tif average_fsaverage_kini_visual_gavg_01_dspm_4_5_7 \
% 	--smooth 5 \
% 	--pick 0 \
%         --pick 100 \