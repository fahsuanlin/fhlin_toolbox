function etc_trace_handle(param,varargin)

global etc_trace_obj;


cc=[];
time_idx=[];

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'c0'
            cc='c0';
        case 'cc'
            cc=option;
        case 'time_idx'
            time_idx=option;
    end;
end;

if(isempty(etc_trace_obj))
    return;
end;

if(isempty(cc))
    %cc=get(etc_trace_obj.fig_trace,'currentchar');
    cc=get(gcf,'currentchar');
end;

switch lower(param)
    case 'draw_pointer'
        draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    case 'redraw'
        redraw;
    case 'del'
        
        try
            delete(etc_trace_obj.fig_topology);
        catch ME
            if(isfield(etc_trace_obj,'fig_topology'))
                close(etc_trace_obj.fig_topology,'force');
            else
                close(gcf,'force');
            end;
        end;
        try
            delete(etc_trace_obj.fig_trigger);
        catch ME
            if(isfield(etc_trace_obj,'fig_trigger'))
                close(etc_trace_obj.fig_trigger,'force');
            else
                close(gcf,'force');
            end;
        end; 
        try
            delete(etc_trace_obj.fig_config);
        catch ME
            if(isfield(etc_trace_obj,'fig_config'))
                close(etc_trace_obj.fig_config,'force');
            else
                close(gcf,'force');
            end;
        end; 
        try
            delete(etc_trace_obj.fig_montage);
        catch ME
            if(isfield(etc_trace_obj,'fig_montage'))
                close(etc_trace_obj.fig_montage,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_trace_obj.fig_avg);
        catch ME
            if(isfield(etc_trace_obj,'fig_avg'))
                close(etc_trace_obj.fig_avg,'force');
            else
                close(gcf,'force');
            end;
        end; 
        try
            delete(etc_trace_obj.fig_info);
        catch ME
            if(isfield(etc_trace_obj,'fig_info'))
                close(etc_trace_obj.fig_info,'force');
            else
                close(gcf,'force');
            end;
        end;         
%         try
%             delete(etc_trace_obj.fig_load);
%         catch ME
%             if(isfield(etc_trace_obj,'fig_load'))
%                 close(etc_trace_obj.fig_load,'force');
%             else
%                 close(gcf,'force');
%             end;
%         end;    
        
        try
            delete(etc_trace_obj.fig_trace);
        catch ME
            if(isfield(etc_trace_obj,'fig_trace'))
                close(etc_trace_obj.fig_trace,'force');
            else
                close(gcf,'force');
            end;
        end;  
        
        try
            delete(etc_trace_obj.fig_control);
        catch ME
            if(isfield(etc_trace_obj,'fig_control'))
                close(etc_trace_obj.fig_control,'force');
            else
                close(gcf,'force');
            end;
        end;   
        
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (etc_trace_obj.tif if no specified output file name)\n');
                fprintf('r: force redrawing \n');
                fprintf('m: montage selection \n');
                fprintf('v: triggers \n');
                fprintf('t: topology plot\n');
                fprintf('s: switch on/off the tigger labeling\n');
                fprintf('q: exit\n');
                fprintf('\n\n fhlin@dec 25, 2014\n');
            case 'a'
                fprintf('archiving...\n');
                
                tstr=datestr(datetime('now'),'mmddyy_HHMMss');
                
                fn=sprintf('etc_trace_obj_%s.tif',tstr);
                fprintf('saving [%s]...\n',fn);
                set(gcf,'PaperPositionMode','auto')
                print(fn,'-dtiff','-r0')
                %print(fn,'-dtiff');
            case 'q'
                fprintf('\nclosing all figures!\n');
                close(etc_trace_obj.fig_trace);
            case 'r'
                fprintf('\nredrawing...\n');
                redraw;
            case 'g'
            case 'k'
            case 's' %mark triggers/events
                %if(etc_trace_obj.flag_mark)
                %    fprintf('start making triggers/events...\n');
                %else
                %    fprintf('stop making triggers/events...\n');
                %end;
                %etc_trace_obj.flag_mark=~etc_trace_obj.flag_mark;
            case 'v'
                fprintf('show triggers/events....\n');
                if(isfield(etc_trace_obj,'fig_trigger'))
                    etc_trace_obj.fig_trigger=[];
                end;
                etc_trace_obj.fig_trigger=etc_trace_trigger_gui;

                set(etc_trace_obj.fig_trigger,'Name','trigger','resize','off');

                pp0=get(etc_trace_obj.fig_trigger,'outerpos');
                pp1=get(etc_trace_obj.fig_trace,'outerpos');
                set(etc_trace_obj.fig_trigger,'outerpos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp0(4)]);
                set(etc_trace_obj.fig_trigger,'Resize','off');
                
            case 'f'
                fprintf('show configuration....\n');
                if(isfield(etc_trace_obj,'fig_config'))
                    etc_trace_obj.fig_config=[];
                end;
                etc_trace_obj.fig_config=etc_trace_config_gui;
                
                pp0=get(etc_trace_obj.fig_config,'outerpos');
                pp1=get(etc_trace_obj.fig_trace,'outerpos');
                set(etc_trace_obj.fig_config,'outerpos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp0(4)]);
                set(etc_trace_obj.fig_config,'Name','display config.');
                set(etc_trace_obj.fig_config,'Resize','off');
            case 'c'
                fprintf('show controls....\n');
                if(isfield(etc_trace_obj,'fig_control'))
                    if(isvalid(etc_trace_obj.fig_control))
                        figure(etc_trace_obj.fig_control);
                    else
                        etc_trace_obj.fig_control=[];
                        etc_trace_obj.fig_control=etc_trace_control_gui;
                    end;
                else
                    etc_trace_obj.fig_control=[];
                    etc_trace_obj.fig_control=etc_trace_control_gui;
                end;
                
                pp0=get(etc_trace_obj.fig_control,'outerpos');
                pp1=get(etc_trace_obj.fig_trace,'outerpos');
                set(etc_trace_obj.fig_control,'outerpos',[pp1(1)+(pp1(3))/2-pp0(3)/2, pp1(2)-pp0(4),pp0(3), pp0(4)]);
                set(etc_trace_obj.fig_control,'Name','control');
                set(etc_trace_obj.fig_control,'Resize','off');    
            case 't'
                fprintf('show topology....\n');
                
                if(isfield(etc_trace_obj,'time_select_idx'))
                    if(~isempty(etc_trace_obj.time_select_idx))
                        try
                            data=etc_trace_obj.data(:,etc_trace_obj.time_select_idx);
                            
                            global etc_render_fsbrain;
                            
                            if(isempty(etc_trace_obj.topo)) %no topo field, the first time loading the topology
                                [filename, pathname, filterindex] = uigetfile({'*.mat','topology Matlab file'}, 'Pick a topology definition file');
                                if(filename>0)
                                    try
                                        load(sprintf('%s/%s',pathname,filename));
                                        etc_trace_obj.topo.vertex=vertex;
                                        etc_trace_obj.topo.face=face;
                                        
                                        Index=find(contains(electrode_name,etc_trace_obj.ch_names));
                                        if(length(Index)<=length(etc_trace_obj.ch_names)) %all electrodes were found on topology
                                            for ii=1:length(etc_trace_obj.ch_names)
                                                for idx=1:length(electrode_name)
                                                    if(strcmp(electrode_name{idx},etc_trace_obj.ch_names{ii}))
                                                        Index(ii)=idx;
                                                        electrode_data_idx(idx)=ii;
                                                    end;
                                                end;
                                            end;
                                            if(isempty(Index))
                                                fprintf('cannot find corresponding channels!\nerror in loading the topology!\n'); 
                                                etc_trace_obj.topo=[];
                                                return;
                                            end;
                                            etc_trace_obj.topo.ch_names=electrode_name(Index);
                                            etc_trace_obj.topo.electrode_idx=electrode_idx(Index);
                                            etc_trace_obj.topo.electrode_data_idx=electrode_data_idx;
                                        else
                                            etc_trace_obj.topo=[];
                                            fprintf('error in finding the corresponding channel names!\n'); return;
                                        end;
                                        
                                        %etc_trace_obj.topo.ch_names=electrode_name;
                                        %etc_trace_obj.topo.electrode_idx=electrode_idx;
                                        
                                        if(isfield(etc_trace_obj,'fig_topology'))
                                            if(isvalid(etc_trace_obj.fig_topology))
                                                figure(etc_trace_obj.fig_topology);
                                                flag_camlight=0;
                                                
                                                global etc_render_fsbrain;
                                                [aa bb]=view;
                                                etc_render_fsbrain.view_angle=[aa bb];
                                                
                                            else
                                                etc_trace_obj.fig_topology=figure;
                                                set(etc_trace_obj.fig_topology,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')'); 
                                                flag_camlight=1;
                                            end;
                                        else
                                            etc_trace_obj.fig_topology=figure;
                                            set(etc_trace_obj.fig_topology,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')'); 
                                            flag_camlight=1;
                                        end;
                                        
                                        etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',10,'topo_threshold',[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ],'flag_camlight',flag_camlight,'topo_aux_point_name',etc_trace_obj.topo.ch_names, 'topo_aux_point_coords',etc_trace_obj.topo.vertex(etc_trace_obj.topo.electrode_idx,:));

                                    catch ME
                                        fprintf('error in loading the topology!\n'); 
                                        etc_trace_obj.topo=[];
                                    end;
                                end;
                            else %topo field exists in etc_trace_obj
                                if(isfield(etc_render_fsbrain,'fig_brain'))
                                    if(isvalid(etc_render_fsbrain.fig_brain))
                                        etc_trace_obj.fig_topology=etc_render_fsbrain.fig_brain;
                                    end;
                                end;
                                if(isfield(etc_trace_obj,'fig_topology'))
                                    if(isvalid(etc_trace_obj.fig_topology))
                                        figure(etc_trace_obj.fig_topology);
                                        etc_render_fsbrain.flag_camlight=0;
                                    else
                                        etc_trace_obj.fig_topology=figure;
                                        etc_render_fsbrain.fig_brain=etc_trace_obj.fig_topology;

                                        set(etc_trace_obj.fig_topology,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                                        set(etc_trace_obj.fig_topology,'DeleteFcn','etc_render_fsbrain_handle(''del'')');
                                        set(etc_trace_obj.fig_topology,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')');                                        
                                        set(etc_trace_obj.fig_topology,'KeyPressFcn',@etc_render_fsbrain_kbhandle);
                                        set(etc_trace_obj.fig_topology,'invert','off');
                                        etc_render_fsbrain.flag_camlight=1;
                                    end;
                                else
                                    etc_trace_obj.fig_topology=figure;
                                    etc_render_fsbrain.fig_brain=etc_trace_obj.fig_topology;
                                    
                                    set(etc_trace_obj.fig_topology,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                                    set(etc_trace_obj.fig_topology,'DeleteFcn','etc_render_fsbrain_handle(''del'')');
                                    set(etc_trace_obj.fig_topology,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')');
                                    set(etc_trace_obj.fig_topology,'KeyPressFcn',@etc_render_fsbrain_kbhandle);
                                    set(etc_trace_obj.fig_topology,'invert','off');
                                    etc_render_fsbrain.flag_camlight=1;
                                end;
                                
                                
                                etc_render_fsbrain.overlay_value=data(etc_trace_obj.topo.electrode_data_idx);
                                etc_render_fsbrain_handle('redraw');
                                    
                            end;
                        catch ME
                            fprintf('error in preparing the topology....\n');
                        end;
                    else
                    end;
                else
                end;
            case 'm' %a list box of montages
                if(isvalid(etc_trace_obj.fig_montage))
                    
                    figure(etc_trace_obj.fig_montage)
                else
                    etc_trace_obj.fig_montage = etc_trace_montage_gui;
                end;
                
                set(etc_trace_obj.fig_montage,'Name','montages');
                set(etc_trace_obj.fig_montage,'Resize','off');
                set(etc_trace_obj.fig_montage, 'Visible','on');
                pp0=get(etc_trace_obj.fig_montage,'outerpos');
                pp1=get(etc_trace_obj.fig_trace,'outerpos');
                set(etc_trace_obj.fig_montage,'outerpos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp0(4)]);
                
            case 'l' %a list box of all electrodes
                if(isfield(etc_trace_obj,'fig_electrode_listbox'))
                    if(isvalid(etc_trace_obj.fig_electrode_listbox))
                        
                        figure(etc_trace_obj.fig_electrode_listbox)
                    else
                        etc_trace_obj.fig_electrode_listbox = figure('Visible','off');
                    end;
                else
                    etc_trace_obj.fig_electrode_listbox = figure('Visible','off');
                end;
                set(etc_trace_obj.fig_electrode_listbox, 'Visible','on');
                set(etc_trace_obj.fig_electrode_listbox,'pos',[200 600 200 200]);
                %pp0=get(etc_trace_obj.fig_electrode_listbox,'outerpos');
                %pp1=get(etc_trace_obj.fig_trace,'outerpos');
                %set(etc_trace_obj.fig_electrode_listbox,'outerpos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp0(4)]);
                %set(etc_trace_obj.fig_electrode_listbox,'outerpos',[pp1(1), pp1(2),pp0(3), pp0(4)]);
                set(etc_trace_obj.fig_electrode_listbox,'Name','channels');
                set(etc_trace_obj.fig_electrode_listbox,'Resize','off');
                
                if(isfield(etc_trace_obj,'trace_selected_idx'))
                    if(~isempty(etc_trace_obj.trace_selected_idx))
                        etc_trace_obj.electrode_listbox=uicontrol('Value',etc_trace_obj.trace_selected_idx,'Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.ch_names,'Callback',@etc_trace_electrode_listbox_callback);
                    else
                        etc_trace_obj.electrode_listbox=uicontrol('Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.ch_names,'Callback',@etc_trace_electrode_listbox_callback);
                    end;
                else
                    etc_trace_obj.electrode_listbox=uicontrol('Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.ch_names,'Callback',@etc_trace_electrode_listbox_callback);
                end;
                
                
            case 'd' %change overlay threshold or time course limits
                
                if(isfield(etc_trace_obj,'trace_selected_idx'))
                    if(~isempty(etc_trace_obj.trace_selected_idx))
                        fprintf('change y limits for [%s]...\n',etc_trace_obj.ch_names{etc_trace_obj.trace_selected_idx});
                        ss=diag(etc_trace_obj.scaling{etc_trace_obj.scaling_idx});
                        ss=ss(1:end-1);
                        fprintf('current limits = %s\n',mat2str(etc_trace_obj.ylim./ss(etc_trace_obj.trace_selected_idx)));
                        def={num2str(etc_trace_obj.ylim./ss(etc_trace_obj.trace_selected_idx))};
                        answer=inputdlg(sprintf('change limits for [%s]',etc_trace_obj.ch_names{etc_trace_obj.trace_selected_idx}),sprintf('current threshold = %s',mat2str(etc_trace_obj.ylim)),1,def);
                        if(~isempty(answer))
                            nn=str2num(answer{1});
                            ss=abs(diff(etc_trace_obj.ylim))./abs(diff(nn));
                            etc_trace_obj.scaling{etc_trace_obj.scaling_idx}(etc_trace_obj.trace_selected_idx,etc_trace_obj.trace_selected_idx)=ss;
                            fprintf('updated time course limits = %s\n',mat2str(etc_trace_obj.ylim.*ss));
                            
                            redraw;
                        end;
                    else
                        fprintf('change limits...\n');
                        if(isempty(etc_trace_obj.ylim))
                            etc_trace_obj.ylim=get(gca,'ylim');
                        end;
                        fprintf('current limits = %s\n',mat2str(etc_trace_obj.ylim));
                        def={num2str(etc_trace_obj.ylim)};
                        answer=inputdlg('change limits',sprintf('current threshold = %s',mat2str(etc_trace_obj.ylim)),1,def);
                        if(~isempty(answer))
                            etc_trace_obj.ylim=str2num(answer{1});
                            fprintf('updated time course limits = %s\n',mat2str(etc_trace_obj.ylim));
                            
                            global etc_render_fsbrain
                            if(~isempty(etc_render_fsbrain))
                                etc_render_fsbrain.overlay_threshold=[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ];
                                etc_trace_handle('bd');
                            end;
                            
                            redraw;
                        end;
                    end;
                end;
            otherwise
        end;
    case 'bd'
        global etc_render_fsbrain;
        global etc_trace_obj;
        
        figure(etc_trace_obj.fig_trace);
        
        clickType = get(gcf, 'SelectionType');
        if(strcmp(clickType,'alt'))
            % right mouse clicked!!
            
            flag_ask=1;

            if(isfield(etc_trace_obj,'trigger_add_rightclick'))
                if(etc_trace_obj.trigger_add_rightclick)
                    flag_ask=0;
                end;
            end;
            if(flag_ask)
                add_trigger=etc_trace_trigger_add_question_gui;
                switch add_trigger
                    case 'No'
                        etc_trace_obj.trigger_add_rightclick=0;
                        obj=findobj('Tag','checkbox_trigger_rightclick');
                        if(~isempty(obj))
                            set(obj,'Value',0);
                        end;
                    case 'Yes'
                        etc_trace_obj.trigger_add_rightclick=1;
                        obj=findobj('Tag','checkbox_trigger_rightclick');
                        if(~isempty(obj))
                            set(obj,'Value',1);
                        end;
                end;
                if(strcmp(add_trigger,'No')) return; end;
            end;
            
            time_idx_now=etc_trace_obj.time_select_idx;
            class_now=etc_trace_obj.trigger_now;
            
            if(isempty(class_now)) return; end;
                        
            all_time_idx=[];
            all_class=[];
            if(~isempty(etc_trace_obj.trigger))
                all_time_idx=etc_trace_obj.trigger.time;
                all_class=etc_trace_obj.trigger.event;
            end;

            
            
            idx=find(all_time_idx==time_idx_now);      
            found=0;
            if(~isempty(idx))
                if(strcmp(all_class{idx(1)},class_now))
                    found=1;
                end;
            end;
            
            if(~found)
                fprintf('adding [%d] (sample) in class {%s}...\n',time_idx_now,class_now);
                
                if(isempty(etc_trace_obj.trigger))
                    etc_trace_obj.trigger.time=time_idx_now;
                    etc_trace_obj.trigger.event{1}=class_now;
                else
                    etc_trace_obj.trigger.time=cat(1,time_idx_now, etc_trace_obj.trigger.time(:));
                    for i=1:length(etc_trace_obj.trigger.event)
                        tmp{i+1}=etc_trace_obj.trigger.event{i};
                    end;
                    tmp{1}=class_now;
                    etc_trace_obj.trigger.event=tmp;
                end;

                %update event list boxes
                obj_time=findobj('tag','listbox_time');
                obj_time_idx=findobj('tag','listbox_time_idx');
                obj_class=findobj('tag','listbox_class');
                
                
                str=[];
                for i=1:length(etc_trace_obj.trigger.time)
                    str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
                end;
                set(obj_time_idx,'string',str);
                str=[];
                for i=1:length(etc_trace_obj.trigger.time)
                    str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
                end;
                set(obj_time,'string',str);
                set(obj_class,'string',etc_trace_obj.trigger.event);

    
                %update event edits
                hObject=findobj('tag','edit_local_trigger_time_idx');
                set(hObject,'string',sprintf('%d',time_idx_now));
                set(hObject,'Value',1);
                hObject=findobj('tag','edit_local_trigger_time');
                set(hObject,'string',sprintf('%1.3f',(time_idx_now-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                set(hObject,'Value',1);
                hObject=findobj('tag','edit_local_trigger_class');
                set(hObject,'string',sprintf('%s',class_now));
                set(hObject,'Value',1);

                %update trace trigger
                hObject=findobj('tag','listbox_trigger');
                set(hObject,'string',unique(etc_trace_obj.trigger.event(:)));
                IndexC = strcmp(unique(etc_trace_obj.trigger.event(:)),etc_trace_obj.trigger_now);
                tmp=find(IndexC);
                set(hObject,'Value',tmp(1));
                hObject=findobj('tag','edit_trigger_time');
                set(hObject,'string',sprintf('%1.3f',(time_idx_now-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                hObject=findobj('tag','edit_trigger_time_idx');
                set(hObject,'string',sprintf('%d',time_idx_now));

                
            else
                fprintf('duplicated [%d] (sample) in class {%s}...\n',all_time_idx(idx),class_now);
                
                obj_time.Value=idx;
                obj_class.Value=idx;
            end;
            
            
        
        else %left mouse click
            if(isfield(etc_trace_obj,'time_select_line'))
                try
                    delete(etc_trace_obj.time_select_line);
                catch
                end;
            end;
            ylim=get(etc_trace_obj.axis_trace,'ylim');
            hold on;
            
            if(isempty(time_idx))
                xx=get(gca,'currentpoint');
                xx=xx(1);
                etc_trace_obj.time_select_idx=round(xx)+etc_trace_obj.time_window_begin_idx-1;
            else
                etc_trace_obj.time_select_idx=time_idx;
            end;
            fprintf('selected time <%3.3f> (s) [index [%d] (sample)]\n',(etc_trace_obj.time_select_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin, etc_trace_obj.time_select_idx);
            
            if(~etc_trace_obj.flag_mark)
                if(etc_trace_obj.config_current_time_flag)
                    figure(etc_trace_obj.fig_trace);
                    %etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'m','linewidth',2);
                    etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1],ylim,'m','linewidth',2);
                    set(etc_trace_obj.time_select_line,'color',etc_trace_obj.config_current_time_color);
                end;
            else
                if(etc_trace_obj.config_current_time_flag)
                    figure(etc_trace_obj.fig_trace);
                    %etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'r','linewidth',2);
                    etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1],ylim,'m','linewidth',2);                    
                end;
            end;
            
            %update trace GUI
            hObject=findobj('tag','edit_time_now_idx');
            set(hObject,'String',num2str(etc_trace_obj.time_select_idx));
            hObject=findobj('tag','edit_time_now');
            set(hObject,'String',num2str((etc_trace_obj.time_select_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin,'%1.3f'));

            %update trigger GUI
            hObject=findobj('tag','edit_local_trigger_time_idx');
            set(hObject,'String',num2str(etc_trace_obj.time_select_idx));
            hObject=findobj('tag','edit_local_trigger_time');
            set(hObject,'String',(etc_trace_obj.time_select_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin);
            if(isfield(etc_trace_obj,'trigger_now'))
                if(~isempty(etc_trace_obj.trigger_now))
                    hObject=findobj('tag','edit_local_trigger_class');
                    set(hObject,'String',num2str(etc_trace_obj.trigger_now));
                else
                    fprintf('now the trigger is set for "def_0" (default trigger name)!\n');
                    etc_trace_obj.trigger_now='def_0'; %default event name
                    hObject=findobj('tag','edit_local_trigger_class');
                    set(hObject,'String',num2str(etc_trace_obj.trigger_now));
                end;
            end;
            
            %update topology
            try
                data=etc_trace_obj.data(:,etc_trace_obj.time_select_idx);
            catch ME
            end;
            if(isfield(etc_trace_obj,'fig_topology'))
                if(isvalid(etc_trace_obj.fig_topology))
                    global etc_render_fsbrain;
                    
                    try
                        delete(etc_render_fsbrain.click_point);
                        delete(etc_render_fsbrain.click_vertex_point);
                        delete(etc_render_fsbrain.click_overlay_vertex_point);
                        
                        etc_render_fsbrain.flag_camlight=0;
                        etc_render_fsbrain.overlay_value=data(etc_trace_obj.topo.electrode_data_idx);
                        etc_render_fsbrain_handle('redraw');
                        
                    catch ME
                    end;
                    
                else
                    if(~isempty(etc_trace_obj.topo)) %topology data exist; create the figure;
                        if(isfield(etc_render_fsbrain,'fig_brain'))
                            if(isvalid(etc_render_fsbrain.fig_brain))
                                etc_trace_obj.fig_topology=etc_render_fsbrain.fig_brain;
                            end;
                        end;
                        if(isfield(etc_trace_obj,'fig_topology'))
                            if(isvalid(etc_trace_obj.fig_topology))
                                figure(etc_trace_obj.fig_topology);
                                etc_render_fsbrain.flag_camlight=0;
                            else
                                etc_trace_obj.fig_topology=figure;
                                etc_render_fsbrain.fig_brain=etc_trace_obj.fig_topology;
                                if(isfield(etc_render_fsbrain,'fig_brain_pos'))
                                    set(etc_render_fsbrain.fig_brain,'pos',etc_render_fsbrain.fig_brain_pos);
                                end;
                                
                                set(etc_trace_obj.fig_topology,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                                set(etc_trace_obj.fig_topology,'DeleteFcn','etc_render_fsbrain_handle(''del'')');
                                set(etc_trace_obj.fig_topology,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')');
                                set(etc_trace_obj.fig_topology,'KeyPressFcn',@etc_render_fsbrain_kbhandle);
                                set(etc_trace_obj.fig_topology,'invert','off');
                                etc_render_fsbrain.flag_camlight=1;
                            end;
                        else
                            etc_trace_obj.fig_topology=figure;
                            etc_render_fsbrain.fig_brain=etc_trace_obj.fig_topology;
                            
                            if(isfield(etc_render_fsbrain,'fig_brain_pos'))
                                set(etc_render_fsbrain.fig_brain,'pos',etc_render_fsbrain.fig_brain_pos);
                            end;
                            
                            set(etc_trace_obj.fig_topology,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                            set(etc_trace_obj.fig_topology,'DeleteFcn','etc_render_fsbrain_handle(''del'')');
                            set(etc_trace_obj.fig_topology,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')');
                            set(etc_trace_obj.fig_topology,'KeyPressFcn',@etc_render_fsbrain_kbhandle);
                            set(etc_trace_obj.fig_topology,'invert','off');
                            etc_render_fsbrain.flag_camlight=1;
                        end;
                        
                        if(~isempty(etc_trace_obj.topo))
                            etc_render_fsbrain.overlay_value=data(etc_trace_obj.topo.electrode_data_idx);
                            etc_render_fsbrain_handle('redraw');
                        end;
                    end;
                end;
            end;
            figure(etc_trace_obj.fig_trace);
        end;
        
        
        if(gcf==etc_trace_obj.fig_trace)
            if(~isempty(etc_render_fsbrain))
                try
                    xx= etc_trace_obj.time_select_idx;
                    if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
                        etc_render_fsbrain.overlay_stc_timeVec_idx=round(xx);
                        fprintf('showing STC at time index [%d] (sample)\n',etc_render_fsbrain.overlay_stc_timeVec_idx);
                    else
                        %[dummy,etc_render_fsbrain.overlay_stc_timeVec_idx]=min(abs(etc_render_fsbrain.overlay_stc_timeVec-xx));
                        etc_render_fsbrain.overlay_stc_timeVec_idx=xx;
                        if(isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                            unt='sample';
                        else
                            unt=etc_render_fsbrain.overlay_stc_timeVec_unit;
                        end;
                        fprintf('showing STC at time [%2.2f] %s\n',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx),unt);
                    end;
                    
                    if(~iscell(etc_render_fsbrain.overlay_value))
                        etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                    else
                        for h_idx=1:length(etc_render_fsbrain.overlay_value)
                            etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                        end;
                    end;
                    
                    %if(~isempty(etc_render_fsbrain.overlay_stc))
                    %    etc_render_fsbrain_handle('draw_stc');
                    %end
                    
                    if(ishandle(etc_render_fsbrain.fig_gui))
                        set(findobj(etc_render_fsbrain.fig_gui,'tag','slider_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                        set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                        set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
                    end;
                    
                    %figure(etc_render_fsbrain.fig_brain);
                    %etc_render_fsbrain.flag_camlight=0;
                    %etc_render_fsbrain_handle('redraw');
                    figure(etc_render_fsbrain.fig_stc);
                    
                    if(~isempty(etc_render_fsbrain.overlay_stc))
                        if(~isempty(etc_trace_obj.trace_selected_idx))
                            etc_render_fsbrain.click_overlay_vertex=etc_trace_obj.trace_selected_idx;
                        end;
                        etc_render_fsbrain_handle('draw_stc');
                    end;                    
                catch ME
                end;
            end;
        end;
        
        figure(etc_trace_obj.fig_trace);
end;

return;


function redraw()
global etc_trace_obj;

if(~isvalid(etc_trace_obj.fig_trace))
    return;
end;

figure(etc_trace_obj.fig_trace);
%tmp=get(etc_trace_obj.fig_trace,'child');
%etc_trace_obj.axis_trace=tmp(end);
etc_trace_obj.axis_trace=findobj('Tag','axis_trace');
cla(etc_trace_obj.axis_trace);

hold(etc_trace_obj.axis_trace,'on');

%plot trace
if(isfield(etc_trace_obj,'aux_data'))
    if(~isempty(etc_trace_obj.aux_data))
        cc=[
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840
            0    0.4470    0.7410
            ]; %color order
        
        for ii=1:length(etc_trace_obj.aux_data)
            %%scaling
            %tmp=etc_trace_obj.S*tmp;
            
            %tmp=bsxfun(@plus, etc_trace_obj.aux_data{ii}(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.aux_data{ii},1)-1]);
            
            %%montage
            %tmp=etc_trace_obj.M*tmp;
                       
            if((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2))
                tmp=etc_trace_obj.aux_data{ii}(:,etc_trace_obj.time_window_begin_idx:etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1);
            else
                tmp=etc_trace_obj.aux_data{ii};
            end;

            tmp=cat(1,tmp,ones(1,size(tmp,2)));
            
            %select channels;
            tmp=etc_trace_obj.select{etc_trace_obj.select_idx}*tmp;
            
            %montage channels;
            tmp=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix*tmp;
            
            %scaling channels;
            tmp=etc_trace_obj.scaling{etc_trace_obj.scaling_idx}*tmp;
            
            %vertical shift for display
            S=eye(size(tmp,1));
            
            switch(etc_trace_obj.view_style)
                case 'trace'
                    S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*[0:size(tmp,1)-2])'; %typical 
                case 'butterfly'
                    %S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*ones(size(tmp,1)-1,1).*round(size(tmp,1)/2))'; %butterfly
                    ss=mean([min(etc_trace_obj.ylim)-0.5 max(etc_trace_obj.ylim)+0.5+(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-2)*diff(sort(etc_trace_obj.ylim))]);
                    S(1:(size(tmp,1)-1),end)=ss.*ones(size(tmp,1)-1,1)'; %butterfly                      
                case 'image'
                    S(1:(size(tmp,1)-1),end)=0; %image
            end;
            tmp=S*tmp;
            
            
            tmp=tmp(1:end-1,:);
            tmp=tmp';
            
            %hh=plot(etc_trace_obj.axis_trace, tmp,'color',cc(ii,:));
            if(etc_trace_obj.config_aux_trace_flag)
                %hh=plot(etc_trace_obj.axis_trace, tmp,'color',etc_trace_obj.config_aux_trace_color);
                hh_aux{ii}=plot(etc_trace_obj.axis_trace, tmp,'color',cc(mod(ii-1,7)+1,:));
                %set(hh,'linewidth',etc_trace_obj.config_aux_trace_width,'color',etc_trace_obj.config_aux_trace_color);
                %set(hh_aux{ii},'linewidth',etc_trace_obj.config_aux_trace_width,'color',cc(mod(ii-1,7)+1,:));
                set(hh_aux{ii},'linewidth',etc_trace_obj.config_aux_trace_width,'color',etc_trace_obj.aux_data_color(ii,:));
                
                if(etc_trace_obj.aux_data_idx(ii))
                    set(hh_aux{ii},'Visible','on');                    
                else
                    set(hh_aux{ii},'Visible','off');
                end;
            end;
            hold(etc_trace_obj.axis_trace,'on');
        end;
    end;
end;

% if((etc_trace_obj.time_begin_idx>=1)&&(etc_trace_obj.time_end_idx<=size(etc_trace_obj.data,2)))
%     tmp=etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx);
% elseif((etc_trace_obj.time_begin_idx<1)&&(etc_trace_obj.time_end_idx<=size(etc_trace_obj.data,2)))
%     tmp=etc_trace_obj.data(:,1:etc_trace_obj.time_end_idx);
% elseif((etc_trace_obj.time_begin_idx>=1)&&(etc_trace_obj.time_end_idx>size(etc_trace_obj.data,2)))
%     tmp=etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:end);
% else((etc_trace_obj.time_begin_idx<1)&&(etc_trace_obj.time_end_idx>size(etc_trace_obj.data,2)))
%     tmp=etc_trace_obj.data(:,1:end);
% end;

if((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2))
    tmp=etc_trace_obj.data(:,etc_trace_obj.time_window_begin_idx:etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1);
else
    tmp=etc_trace_obj.data;
end;
tmp=cat(1,tmp,ones(1,size(tmp,2)));

%select channels;
tmp=etc_trace_obj.select{etc_trace_obj.select_idx}*tmp;

%montage channels;
tmp=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix*tmp;

%scaling channels;
tmp=etc_trace_obj.scaling{etc_trace_obj.scaling_idx}*tmp;

%vertical shift for display
S=eye(size(tmp,1));
switch(etc_trace_obj.view_style)
    case 'trace'
        S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*[0:size(tmp,1)-2])'; %typical 
    case 'butterfly'
        %S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*ones(size(tmp,1)-1,1).*round(size(tmp,1)/2))'; %butterfly
        ss=mean([min(etc_trace_obj.ylim)-0.5 max(etc_trace_obj.ylim)+0.5+(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-2)*diff(sort(etc_trace_obj.ylim))]);
        S(1:(size(tmp,1)-1),end)=ss.*ones(size(tmp,1)-1,1)'; %butterfly        
    case 'image'
        S(1:(size(tmp,1)-1),end)=0; %image
end;
tmp=S*tmp;



tmp=tmp(1:end-1,:);
tmp=tmp';
if(etc_trace_obj.config_trace_flag)

    switch(etc_trace_obj.view_style)
        case {'trace','butterfly'}
            hh=[];
            hh=plot(etc_trace_obj.axis_trace, tmp,'color',etc_trace_obj.config_trace_color);
            set(hh,'linewidth',etc_trace_obj.config_trace_width);
            %assign a tag for each trace
            etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names={};
            for idx=1:length(hh)
                m=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix(idx,:);
                ii=find(m>eps);
                if(~isempty(ii))
                    ss=etc_trace_obj.ch_names{ii(1)};
                    if(length(ii)>1)
                        for ii_idx=2:length(ii)
                            ss=sprintf('%s+%1.0fx%s',ss,m(ii(ii_idx)),etc_trace_obj.ch_names{ii(ii_idx)});
                        end;
                    end;
                end;
                
                ii=find(-m>eps);
                if(~isempty(ii))
                    ss=sprintf('%s%1.0fx%s',ss,m(ii(1)),etc_trace_obj.ch_names{ii(1)});
                    if(length(ii)>1)
                        for ii_idx=2:length(ii)
                            ss=sprintf('%s-%1.0fx%s',ss,-m(ii(ii_idx)),etc_trace_obj.ch_names{ii(ii_idx)});
                        end;
                    end;
                end;
                etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names{idx}=ss;
                set(hh(idx),'tag',ss);
            end;

            set(hh,'ButtonDownFcn',@etc_trace_callback);

        case 'image'
            %imagesc(1,1,tmp');
            hha=[];
            hh=[];
            for idx=1:size(tmp,2)
                hha(idx)=imagesc(1,idx,tmp(:,idx)');
                hh(idx)=rectangle('pos',[0.5,idx-0.5,size(tmp,1),1],'edgecolor','c','visible','off');
            end;
            set(gca,'clim',etc_trace_obj.ylim);
            colormap(etc_trace_obj.colormap);
            
            %assign a tag for each trace
            for idx=1:length(hha)
                m=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix(idx,:);
                ii=find(m>eps);
                if(~isempty(ii))
                    ss=etc_trace_obj.ch_names{ii(1)};
                    if(length(ii)>1)
                        for ii_idx=2:length(ii)
                            ss=sprintf('%s+%1.0fx%s',ss,m(ii(ii_idx)),etc_trace_obj.ch_names{ii(ii_idx)});
                        end;
                    end;
                end;
                
                ii=find(-m>eps);
                if(~isempty(ii))
                    ss=sprintf('%s%1.0fx%s',ss,m(ii(1)),etc_trace_obj.ch_names{ii(1)});
                    if(length(ii)>1)
                        for ii_idx=2:length(ii)
                            ss=sprintf('%s-%1.0fx%s',ss,-m(ii(ii_idx)),etc_trace_obj.ch_names{ii(ii_idx)});
                        end;
                    end;
                end;
                etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names{idx}=ss;
                set(hha(idx),'tag',ss);
            end;

            set(hha,'ButtonDownFcn',@etc_trace_callback);

    end;
end;

%highlight selected trace
if(isfield(etc_trace_obj,'trace_selected_idx'))
    if(~isempty(etc_trace_obj.trace_selected_idx))
        
        switch(etc_trace_obj.view_style)
            case {'trace','butterfly'}
                set(hh(etc_trace_obj.trace_selected_idx),'linewidth',4,'color','b');
                
                if(etc_trace_obj.config_aux_trace_flag)
                    for ii=1:length(etc_trace_obj.aux_data)
                        
                        %automatic gray out other auxillary traces except
                        %the selected one
                        for jj=1:length(hh_aux{ii})
                            if(jj~=etc_trace_obj.trace_selected_idx)
                                set(hh_aux{ii}(jj),'linewidth',1,'color',[1 1 1].*0.7);
                            else
                                set(hh_aux{ii}(etc_trace_obj.trace_selected_idx),'linewidth',4);
                            end;
                        end;
                            
                        if(etc_trace_obj.aux_data_idx(ii))
                            set(hh_aux{ii},'Visible','on');
                        else
                            set(hh_aux{ii},'Visible','off');
                        end;
                    end;
                end;
                
                if(isfield(etc_trace_obj,'electrode_listbox'))
                    if(isvalid(etc_trace_obj.electrode_listbox))
                        set(etc_trace_obj.electrode_listbox,'Value', etc_trace_obj.trace_selected_idx);
                    else
                    end;
                else
                end;
                
                obj=findobj('Tag','listbox_channel');
                if(~isempty(obj))
                    set(obj,'Value', etc_trace_obj.trace_selected_idx);
                end;
            case 'image'
                set(hh(etc_trace_obj.trace_selected_idx),'linewidth',2,'edgecolor','c','visible','on');
                
                if(isfield(etc_trace_obj,'electrode_listbox'))
                    if(isvalid(etc_trace_obj.electrode_listbox))
                        set(etc_trace_obj.electrode_listbox,'Value', etc_trace_obj.trace_selected_idx);
                    else
                    end;
                else
                end;                
        end;
        
    else
    end;
else
end;

global etc_render_fsbrain;
try
    if(~isempty(etc_trace_obj.trace_selected_idx))
        etc_render_fsbrain.click_overlay_vertex=etc_trace_obj.trace_selected_idx;
    end;
    etc_render_fsbrain_handel('draw_stc');
catch ME
end;

try
    switch(etc_trace_obj.view_style)
        case {'trace','butterfly'}
            set(etc_trace_obj.axis_trace,'ylim',[min(etc_trace_obj.ylim)-0.5 max(etc_trace_obj.ylim)+0.5+(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-2)*diff(sort(etc_trace_obj.ylim))]);
        case 'image'
            set(etc_trace_obj.axis_trace,'ylim',[0.5 size(tmp,2)+0.5]);
    end;
    set(etc_trace_obj.axis_trace,'xlim',[1 etc_trace_obj.time_duration_idx]);
    set(etc_trace_obj.axis_trace,'xtick',round([0:5]./5.*etc_trace_obj.time_duration_idx)+1);
    set(etc_trace_obj.axis_trace,'ydir','reverse');
    xx=(round([0:5]./5.*etc_trace_obj.time_duration_idx)+etc_trace_obj.time_window_begin_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin;
    set(etc_trace_obj.axis_trace,'xticklabel',cellstr(num2str(xx')));
catch ME
end;

try
    %plot electrode names
    switch(etc_trace_obj.view_style)
        case 'trace'
            if(~isempty(etc_trace_obj.montage_ch_name))
                set(etc_trace_obj.axis_trace,'ytick',diff(sort(etc_trace_obj.ylim)).*[0:(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-1)-1]);
                set(etc_trace_obj.axis_trace,'yticklabels',etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names);
                %
                %set(etc_trace_obj.axis_trace,'ButtonDownFcn',@etc_trace_callback);

            end;
        case 'butterfly'
            set(etc_trace_obj.axis_trace,'ytick',(diff(sort(etc_trace_obj.ylim)).*round(size(tmp,2)/2)));
            set(etc_trace_obj.axis_trace,'yticklabels','all');
        case 'image'
            if(~isempty(etc_trace_obj.montage_ch_name))
                set(etc_trace_obj.axis_trace,'ytick',[1:size(tmp,2)]);
                set(etc_trace_obj.axis_trace,'yticklabels',etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names);
            end;
    end;
    
catch ME
end;
%plot trigger
try
    %all triggers
    idx=find((etc_trace_obj.trigger.time>=etc_trace_obj.time_window_begin_idx)&(etc_trace_obj.trigger.time<=(etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx)));
    
    if(etc_trace_obj.config_current_trigger_flag)
        h=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.trigger.time(idx)-etc_trace_obj.time_window_begin_idx,[2 1]),repmat(get(etc_trace_obj.axis_trace,'ylim')',[1 length(idx)]),'LineWidth',2,'LineStyle',':','Color',etc_trace_obj.config_current_trigger_color);
    end;
    
    %current selected trigger
    if(isfield(etc_trace_obj,'trigger_now'))
        if(~isempty(etc_trace_obj.trigger_now))
            trigger_idx=find(etc_trace_obj.trigger.event==etc_trace_obj.trigger_now);
            trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
            idx=find((etc_trace_obj.trigger.time(trigger_idx)>=etc_trace_obj.time_window_begin_idx)&(etc_trace_obj.trigger.time(trigger_idx)<=(etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx)));
        
            if(etc_trace_obj.config_current_trigger_flag)
                h=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.trigger.time(trigger_idx(idx))-etc_trace_obj.time_window_begin_idx,[1 2])',repmat(get(etc_trace_obj.axis_trace,'ylim')',[1 length(idx)]),'LineWidth',2,'LineStyle','-','Color',etc_trace_obj.config_current_trigger_color);
            end;
        end;
    end;
catch ME
end;

%plot selected time
try
    if(isfield(etc_trace_obj,'time_select_line'))
        try
            delete(etc_trace_obj.time_select_line);
        catch
        end;
    end;
    ylim=get(etc_trace_obj.axis_trace,'ylim');
    if(~etc_trace_obj.flag_mark)
        if(etc_trace_obj.config_current_time_flag)
            %etc_trace_obj.time_select_line=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1,[2 1]),get(etc_trace_obj.axis_trace,'ylim')','LineWidth',2,'LineStyle','-','Color',etc_trace_obj.config_current_time_color);
            etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1],ylim,'m','linewidth',2);
            set(etc_trace_obj.time_select_line,'color',etc_trace_obj.config_current_time_color);
        end;
    else
        if(etc_trace_obj.config_current_trigger_flag)
            %etc_trace_obj.time_select_line=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1,[2 1]),get(etc_trace_obj.axis_trace,'ylim')','LineWidth',2,'LineStyle','-','Color','r');
            etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_window_begin_idx+1],ylim,'m','linewidth',2);                    
        end;
    end;
catch ME
end;

%font style
set(etc_trace_obj.axis_trace,'fontname','helvetica','fontsize',12);
set(etc_trace_obj.fig_trace,'color','w')

return;




function etc_trace_callback(src,~)

global etc_trace_obj;

fprintf('[%s] was selected\n',src.Tag);

%Index = find(strcmp(etc_trace_obj.ch_names,src.Tag));
Index = find(strcmp(etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names, src.Tag));

if(isfield(etc_trace_obj,'trace_selected_idx'))
    if(~isempty(etc_trace_obj.trace_selected_idx))
        if(Index==etc_trace_obj.trace_selected_idx)
            etc_trace_obj.trace_selected_idx=[];
        else
            etc_trace_obj.trace_selected_idx=Index;
        end;
    else
        etc_trace_obj.trace_selected_idx=Index;
    end;
else
    etc_trace_obj.trace_selected_idx=Index;
end;

global etc_render_fsbrain;

%fprintf('----\n');
%etc_render_fsbrain.click_overlay_vertex

redraw;

if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        etc_render_fsbrain.flag_overlay_stc_surf=1;
        etc_render_fsbrain.flag_overlay_stc_vol=0;
        etc_render_fsbrain_handle('draw_stc');
    end;
end;
figure(etc_trace_obj.fig_trace);
%etc_render_fsbrain.click_overlay_vertex
%fprintf('----\n');

return;


function etc_trace_electrode_listbox_callback(hObj,event)

global etc_trace_obj;

Index=get(hObj,'value');
fprintf('[%s] selected in the list box\n',etc_trace_obj.ch_names{Index});
etc_trace_obj.trace_selected_idx=Index;

redraw;

return;



