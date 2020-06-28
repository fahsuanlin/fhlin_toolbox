
function etc_render_fsbrain_gui_update(handles)
global etc_render_fsbrain;

%surface opacity slider
set(handles.slider_alpha,'value',get(etc_render_fsbrain.h,'facealpha'));
set(handles.edit_alpha,'string',sprintf('%1.1f',get(etc_render_fsbrain.h,'facealpha')));

%timeVec slider
try
    set(handles.slider_timeVec,'Enable','off');
    set(handles.edit_timeVec,'Enable','off');

    if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'))
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
            if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                set(handles.slider_timeVec,'Enable','on');
                set(handles.slider_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));

                set(handles.edit_timeVec,'Enable','on');
                set(handles.edit_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                set(handles.edit_timeVec,'string',sprintf('%1.1f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
            end;
        end;
    end;
catch
end;
set(handles.text_timeVec_unit,'String',etc_render_fsbrain.overlay_stc_timeVec_unit);


%overlay smooth
set(handles.edit_smooth,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_smooth,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_smooth,'enable','on');
    end;
end;

%truncate overlay flags
set(handles.checkbox_overlay_truncate_pos,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.checkbox_overlay_truncate_pos,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_overlay_truncate_pos,'enable','on');
    end;
end;
set(handles.checkbox_overlay_truncate_neg,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.checkbox_overlay_truncate_neg,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_overlay_truncate_neg,'enable','on');
    end;
end;

%auto threshold button
set(handles.pushbutton_auto_threshold,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.pushbutton_auto_threshold,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.pushbutton_auto_threshold,'enable','on');
    end;
end;

%threshold min/max
set(handles.edit_threshold_min,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_threshold_min,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_threshold_min,'enable','on');
    end;
end;
set(handles.edit_threshold_max,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_threshold_max,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_threshold_max,'enable','on');
    end;
end;

%colorbar check box
set(handles.checkbox_show_colorbar,'value',0);
set(handles.checkbox_show_vol_colorbar,'value',0);
if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
    if(~isempty(etc_render_fsbrain.h_colorbar_pos))
        set(handles.checkbox_show_colorbar,'value',1);
        set(handles.checkbox_show_vol_colorbar,'value',1);
    end;
end;


%overlay listboxes
str={};
for str_idx=1:length(etc_render_fsbrain.overlay_buffer) str{str_idx}=etc_render_fsbrain.overlay_buffer(str_idx).name; end;
if(isempty(str))
    set(findobj('tag','listbox_overlay_main'),'string','[none]');
    set(findobj('tag','listbox_overlay_main'),'value',1);
else
    set(handles.listbox_overlay_main,'string',str);
    set(handles.listbox_overlay_main,'value',etc_render_fsbrain.overlay_buffer_main_idx);
end;
set(handles.listbox_overlay,'string',str);
set(handles.listbox_overlay,'min',0);
if(length(etc_render_fsbrain.overlay_buffer)==1)
    set(handles.listbox_overlay,'max',2);
else
    set(handles.listbox_overlay,'max',length(etc_render_fsbrain.overlay_buffer));
end;
set(handles.listbox_overlay,'value',etc_render_fsbrain.overlay_buffer_idx);

%colorbar checkboxes
if(get(handles.checkbox_show_colorbar,'value'))
    set(handles.checkbox_show_colorbar,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
end;
if(get(handles.checkbox_show_vol_colorbar,'value'))
    set(handles.checkbox_show_vol_colorbar,'enable','on');
else
    set(handles.checkbox_show_vol_colorbar,'enable','off');
end;

if(~isempty(etc_render_fsbrain.overlay_value)||~isempty(etc_render_fsbrain.overlay_stc))
    set(handles.checkbox_show_colorbar,'enable','on');
    set(handles.checkbox_show_overlay,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
    set(handles.checkbox_show_overlay,'enable','off');
end;


if(~isempty(etc_render_fsbrain.overlay_vol_value)||~isempty(etc_render_fsbrain.overlay_vol_stc))
    set(handles.checkbox_show_vol_colorbar,'enable','on');
    set(handles.checkbox_show_vol_overlay,'enable','on');
    set(handles.checkbox_show_vol_colorbar,'enable','on');
else
    set(handles.checkbox_show_vol_colorbar,'enable','off');
    set(handles.checkbox_show_vol_overlay,'enable','off');
    set(handles.checkbox_show_vol_colorbar,'enable','off');
end;


if(~isempty(etc_render_fsbrain.aux_point_coords))
    set(handles.pushbutton_aux_point_color,'BackgroundColor',etc_render_fsbrain.aux_point_color);
    set(handles.edit_aux_point_size,'string',sprintf('%3.3f',etc_render_fsbrain.aux_point_size));
    if(~isfield(etc_render_fsbrain,'aux_point_label_flag'))
        etc_render_fsbrain.aux_point_label_flag=1;
    end;
    set(handles.checkbox_aux_point_label,'value',etc_render_fsbrain.aux_point_label_flag);
    set(handles.pushbutton_aux_point_text_color,'BackgroundColor',etc_render_fsbrain.aux_point_text_color);
    set(handles.edit_aux_point_text_size,'string',sprintf('%d',etc_render_fsbrain.aux_point_text_size));

else
    set(handles.pushbutton_aux_point_color,'enable','off');
    set(handles.edit_aux_point_size,'enable','off');
    set(handles.checkbox_aux_point_label,'enable','off');
    set(handles.pushbutton_aux_point_text_color,'enable','off');
    set(handles.edit_aux_point_text_size,'enable','off');
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    set(handles.pushbutton_aux2_point_color,'BackgroundColor',etc_render_fsbrain.aux2_point_color);
    set(handles.edit_aux2_point_size,'string',sprintf('%d',etc_render_fsbrain.aux2_point_size));
    v1=etc_render_fsbrain.show_all_contacts_mri_flag;
    v2=etc_render_fsbrain.show_all_contacts_brain_surface_flag;
    set(handles.checkbox_electrode_contacts,'value',v1|v2);
    
    set(handles.checkbox_selected_contact,'value',etc_render_fsbrain.selected_contact_flag);
    set(handles.pushbutton_selected_contact_color,'BackgroundColor',etc_render_fsbrain.selected_contact_color);
    set(handles.edit_selected_contact_size,'string',sprintf('%d',etc_render_fsbrain.selected_contact_size));
    
    set(handles.checkbox_selected_electrode,'value',etc_render_fsbrain.selected_electrode_flag);
    set(handles.pushbutton_selected_electrode_color,'BackgroundColor',etc_render_fsbrain.selected_electrode_color);
    set(handles.edit_selected_electrode_size,'string',sprintf('%d',etc_render_fsbrain.selected_electrode_size));
else
    set(handles.pushbutton_aux2_point_color,'enable','off');
    set(handles.edit_aux2_point_size,'enable','off');
    set(handles.checkbox_electrode_contacts,'enable','off');

    set(handles.checkbox_selected_contact,'enable','off');
    set(handles.pushbutton_selected_contact_color,'enable','off');
    set(handles.edit_selected_contact_size,'enable','off');
    
    set(handles.checkbox_selected_electrode,'enable','off');
    set(handles.pushbutton_selected_electrode_color,'enable','off');
    set(handles.edit_selected_electrode_size,'enable','off');
end;


set(handles.checkbox_nearest_brain_surface,'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);
set(handles.checkbox_brain_surface,'value',etc_render_fsbrain.show_brain_surface_location_flag);
set(handles.pushbutton_click_vertex_point_color,'BackgroundColor',etc_render_fsbrain.click_vertex_point_color);
set(handles.edit_click_vertex_point_size,'string',sprintf('%d',etc_render_fsbrain.click_vertex_point_size));
set(handles.pushbutton_click_point_color,'BackgroundColor',etc_render_fsbrain.click_point_color);
set(handles.edit_click_point_size,'string',sprintf('%d',etc_render_fsbrain.click_point_size));

set(handles.checkbox_overlay_truncate_neg,'value',etc_render_fsbrain.flag_overlay_truncate_neg);
set(handles.checkbox_overlay_truncate_pos,'value',etc_render_fsbrain.flag_overlay_truncate_pos);

if(isempty(etc_render_fsbrain.lut))
    set(handles.listbox_overlay_vol_mask,'string',{});
    set(handles.listbox_overlay_vol_mask,'enable','off');
    set(handles.checkbox_overlay_aux_vol,'enable','off');                                                        
    set(handles.slider_overlay_aux_vol,'enable','off');                                                          
    set(handles.pushbutton_overlay_aux_vol,'enable','off');
else
    set(handles.listbox_overlay_vol_mask,'string',etc_render_fsbrain.lut.name);
    set(handles.listbox_overlay_vol_mask,'enable','on');
    set(handles.checkbox_overlay_aux_vol,'enable','on');                                                        
    set(handles.slider_overlay_aux_vol,'enable','on');
    set(handles.pushbutton_overlay_aux_vol,'enable','on');
end;                
return;
