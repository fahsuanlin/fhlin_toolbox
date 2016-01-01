function [ovs]=etc_smooth_fsbrain(overlay_value, overlay_vertex, varargin)
%
% etc_smooth_fsbrain   smooth the overlay of a freesurfer brain
%
% [ovs] = etc_smooth_fsbrain(overlay_value, [option1 option1_value, ...]);
%
% ovs: the smoothed values
%
% fhlin@dec.21 2014
%

h=[];

%fundamental anatomy geometry
subjects_dir=getenv('SUBJECTS_DIR');
subject='fsaverage';
surf='inflated';
flag_curv=1;
hemi='';
curv=[];


%overlay
overlay_smooth=5;

exc_vertex='';

flag_fixval=0;

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'subject'
            subject=option_value;
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'hemi'
            hemi=option_value;
        case 'surf'
            surf=option_value;
        case 'overlay_value'
            overlay_value=option_value;
        case 'overlay_vertex'
            overlay_vertex=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'exc_vertex'
            exc_vertex=option_value;            
        case 'flag_fixval'
            flag_fixval=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end


file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,surf);
fprintf('reading [%s]...\n',file_surf);

[vertex_coords, faces] = read_surf(file_surf);

ov=zeros(size(vertex_coords,1),1);

ov(overlay_vertex+1)=overlay_value;

ovs=inverse_smooth('','vertex',vertex_coords','face',faces','value',ov,'step',overlay_smooth,'flag_fixval',flag_fixval,'exc_vertex',exc_vertex);



return;
    