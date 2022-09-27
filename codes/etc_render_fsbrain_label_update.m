function []=etc_render_fsbrain_label_update(varargin)
%
% etc_render_fsbrain_label_update    add/update a label to the
% etc_render_fsbrain object.
%
% etc_render_fsbrain_label_update([option1 option1_value, ...]);
%
% file_label: the file of a label
% flag_show_cort_label_boundary: a flag to enable/disable the drawing of an ROI boundary
% flag_show_cort_label: a flag to enable/disable the drawing of an ROI 
% cort_label_boundary_color: the color of an ROI boundary
% cort_label_color: the color of an ROI
% label_index: indices of brain vertices for an ROI
% label_idx: indices of brain vertices for an ROI
%
% fhlin@jan. 10 2022
%


global etc_render_fsbrain;

cort_label_boundary_color=[0 0 1];
cort_label_color=[];

ii=[];
file_label='';

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'cort_label_boundary_color'
            etc_render_fsbrain.cort_label_boundary_color=option_value;
        case 'cort_label_color'
            etc_render_fsbrain.cort_label_color=option_value;
        case 'flag_show_cort_label_boundary'
            etc_render_fsbrain.flag_show_cort_label_boundary=option_value;
        case 'flag_show_cort_label'
            etc_render_fsbrain.flag_show_cort_label=option_value;
        case 'file_label'
            file_label=option_value;
        case 'label_index'
            ii=option_value;
        case 'label_idx'
            ii=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end

if(~isempty(file_label))
    [ii,d0,d1,d2, vv] = inverse_read_label(file_label);
end;

if(isempty(ii))
    fprintf('no label to be updated!\n');
    return;
end;

if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
    etc_render_fsbrain.label_vertex(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
    if(sum(etc_render_fsbrain.label_value(ii+1))>eps)
        fprintf('Warning! The loaded label overlaps with already-existed label(s), which are not replaced by the new index!\n');
    end;
    maxx=max(etc_render_fsbrain.label_value(:));
    %etc_render_fsbrain.label_value(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
    etc_render_fsbrain.label_value(ii+1)=maxx+1;
    etc_render_fsbrain.label_ctab.numEntries=etc_render_fsbrain.label_ctab.numEntries+1;
    etc_render_fsbrain.label_ctab.struct_names{end+1}=file_label;
    if(isempty(cort_label_color))
        switch mod(maxx+1,5)+1
            case 1
                etc_render_fsbrain.label_ctab.table(end+1,:)=[0*256   0.4470*256   0.741*256         0        maxx+1];
            case 2
                etc_render_fsbrain.label_ctab.table(end+1,:)=[0.8500*256 0.3250*256 0.0980*256          0        maxx+1];
            case 3
                etc_render_fsbrain.label_ctab.table(end+1,:)=[0.9290*256 0.6940*256 0.1250*256          0        maxx+1];
            case 4
                etc_render_fsbrain.label_ctab.table(end+1,:)=[0.4940*256 0.1840*256 0.5560*256          0        maxx+1];
            case 5
                etc_render_fsbrain.label_ctab.table(end+1,:)=[0.4660*256 0.6740*256 0.1880*256          0        maxx+1];
        end;
    else
         etc_render_fsbrain.label_ctab.table(end+1,:)=[cort_label_color(1)*256 cort_label_color(2)*256 cort_label_color(3)*256          0        maxx+1];
    end;
    etc_render_fsbrain.label_register(end+1)=1;
else
    etc_render_fsbrain.label_vertex=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
    etc_render_fsbrain.label_vertex(ii+1)=1;
    etc_render_fsbrain.label_value=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
    etc_render_fsbrain.label_value(ii+1)=1;
    s.numEntries=1;
    s.orig_tab='';
    s.struct_names={file_label};
    if(isempty(cort_label_color))
        s.table=[0*256   0.4470*256   0.741*256         0        1];
    else
        s.table=[cort_label_color(1)*256   cort_label_color(2)*256   cort_label_color(3)*256         0        1];
    end;
    etc_render_fsbrain.label_ctab=s;
    
    etc_render_fsbrain.label_register=1;
end;

etc_render_fsbrain_handle('update_label');

return;
