function etc_render_fsbrain_update_time(overlay_stc_timeVec_idx,varargin)

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

global etc_render_fsbrain

try
    etc_render_fsbrain.overlay_stc_timeVec_idx=overlay_stc_timeVec_idx;
    
    if(~iscell(etc_render_fsbrain.overlay_value))
        etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
    else
        for h_idx=1:length(etc_render_fsbrain.overlay_value)
            etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
        end;
    end;
    
    
    %update time index edit
    h=findobj('tag','edit_timeVec');
    if(~isempty(h))
        set(h,'value',time);
        set(h,'string',sprintf('%1.1f',time));
    end;
    
    if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
        if(flag_display)
            fprintf('showing STC at time index [%d] (sample)\n',etc_render_fsbrain.overlay_stc_timeVec_idx);
        end;
    else
        if(flag_display)
            fprintf('showing STC at time [%2.2f] ms\n',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
        end;
    end;
    
    etc_render_fsbrain_handle('update_overlay_vol');
    
    if(~isempty(etc_render_fsbrain.overlay_stc))
        etc_render_fsbrain_handle('draw_stc');
    end;
    
    %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    
    etc_render_fsbrain_handle('redraw');
    
    global etc_trace_obj;
    
    if(~isempty(etc_trace_obj))
        etc_trace_obj.time_select_idx=etc_render_fsbrain.overlay_stc_timeVec_idx;
        etc_trcae_gui_update_time;
    end;
    
catch
    
end;
