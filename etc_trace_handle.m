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
    cc=get(etc_trace_obj.fig_trace,'currentchar');
end;

switch lower(param)
    case 'draw_pointer'
        draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    case 'redraw'
        redraw;
    case 'del'
        try
            delete(etc_trace_obj.fig_topology);
            delete(etc_trace_obj.fig_trigger);
            delete(etc_trace_obj.fig_montage);
            delete(etc_trace_obj.fig_trace);
        catch ME
        end;
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('r: force redrawing \n');
                fprintf('m: montage selection \n');
                fprintf('v: triggers \n');
                fprintf('t: topology plot\n');
                fprintf('s: switch on/off the tigger labeling\n');
                fprintf('q: exit\n');
                fprintf('\n\n fhlin@dec 25, 2014\n');
            case 'a'
                fprintf('archiving...\n');
                fn=sprintf('etc_trace_obj.tif');
                fprintf('saving [%s]...\n',fn);
                print(fn,'-dtiff');
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
                fprintf('show events....\n');
                if(isfield(etc_trace_obj,'fig_trigger'))
                    etc_trace_obj.fig_trigger=[];
                end;
                etc_trace_obj.fig_trigger=etc_trace_trigger_gui;
                
                pp0=get(etc_trace_obj.fig_trigger,'pos');
                pp1=get(etc_trace_obj.fig_trace,'pos');
                set(etc_trace_obj.fig_trigger,'pos',[pp1(1)-pp0(3), pp1(2),pp0(3), pp0(4)]);
                set(etc_trace_obj.fig_trigger,'Name','events');
                set(etc_trace_obj.fig_trigger,'Resize','off');
 
            case 'f' 
                fprintf('show configuration....\n');
                if(isfield(etc_trace_obj,'fig_config'))
                    etc_trace_obj.fig_config=[];
                end;
                etc_trace_obj.fig_config=etc_trace_config_gui;
                
                pp0=get(etc_trace_obj.fig_config,'pos');
                pp1=get(etc_trace_obj.fig_trace,'pos');
                set(etc_trace_obj.fig_config,'pos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp0(4)]);
                set(etc_trace_obj.fig_config,'Name','events');
                set(etc_trace_obj.fig_config,'Resize','off');

            case 't'
                fprintf('show topology....\n');
                
                if(isfield(etc_trace_obj,'time_select_idx'))
                    if(~isempty(etc_trace_obj.time_select_idx))
                        data=etc_trace_obj.data(:,etc_trace_obj.time_select_idx);
                                                
                        if(isempty(etc_trace_obj.topo))
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
                                        etc_trace_obj.topo.ch_names=electrode_name(Index);
                                        etc_trace_obj.topo.electrode_idx=electrode_idx(Index);
                                        etc_trace_obj.topo.electrode_data_idx=electrode_data_idx;
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
                                            flag_camlight=1;
                                        end;
                                    else
                                        etc_trace_obj.fig_topology=figure;
                                        flag_camlight=1;
                                    end;
                                    
                                    global etc_render_fsbrain;
                                    if(isempty(etc_render_fsbrain))
                                        etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',10,'topo_threshold',[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ],'flag_camlight',flag_camlight);
                                    else
                                        delete(etc_render_fsbrain.click_point);
                                        delete(etc_render_fsbrain.click_vertex_point);
                                        delete(etc_render_fsbrain.click_overlay_vertex_point);
                                        
                                        etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                                    end;
                                catch ME
                                end;
                            end;
                        else
                            if(isfield(etc_trace_obj,'fig_topology'))
                                if(isvalid(etc_trace_obj.fig_topology))
                                    figure(etc_trace_obj.fig_topology);
                                    flag_camlight=0;
                                else
                                    etc_trace_obj.fig_topology=figure;
                                    flag_camlight=1;
                                end;
                            else
                                etc_trace_obj.fig_topology=figure;
                                flag_camlight=1;
                            end;                           
                            
                            global etc_render_fsbrain;
                            if(isempty(etc_render_fsbrain))
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',10,'topo_threshold',[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ],'flag_camlight',flag_camlight);
                            else
                                delete(etc_render_fsbrain.click_point);
                                delete(etc_render_fsbrain.click_vertex_point);
                                delete(etc_render_fsbrain.click_overlay_vertex_point);
                                
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                            end;
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
                set(etc_trace_obj.fig_electrode_listbox,'pos',[200 600 200 200]);
                set(etc_trace_obj.fig_electrode_listbox,'Name','electrodes');
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
                
                set(etc_trace_obj.fig_electrode_listbox, 'Visible','on');
                
            case 'd' %change overlay threshold or time course limits
                
                if(isfield(etc_trace_obj,'trace_selected_idx'))
                    if(~isempty(etc_trace_obj.trace_selected_idx))
                        fprintf('change y limits for [%s]...\n',etc_trace_obj.ch_names{etc_trace_obj.trace_selected_idx});
                        ss=diag(etc_trace_obj.scaling{etc_trace_obj.montage_idx});
                        ss=ss(1:end-1);
                        fprintf('current limits = %s\n',mat2str(etc_trace_obj.ylim./ss(etc_trace_obj.trace_selected_idx)));
                        def={num2str(etc_trace_obj.ylim./ss(etc_trace_obj.trace_selected_idx))};
                        answer=inputdlg(sprintf('change limits for [%s]',etc_trace_obj.ch_names{etc_trace_obj.trace_selected_idx}),sprintf('current threshold = %s',mat2str(etc_trace_obj.ylim)),1,def);
                        if(~isempty(answer))
                            nn=str2num(answer{1});
                            ss=abs(diff(etc_trace_obj.ylim))./abs(diff(nn));
                            etc_trace_obj.scaling{etc_trace_obj.montage_idx}(etc_trace_obj.trace_selected_idx,etc_trace_obj.trace_selected_idx)=ss;
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
        if(gcf==etc_trace_obj.fig_trace)
            %detect right mouse click
            clickType = get(gcf, 'SelectionType');
            if(strcmp(clickType,'alt'))
                
            else
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
                    etc_trace_obj.time_select_idx=round(xx)+etc_trace_obj.time_begin_idx-1;
                else
                    etc_trace_obj.time_select_idx=time_idx;
                end;
                fprintf('selected time <%3.3f> (s) [index [%d] (sample)]\n',etc_trace_obj.time_select_idx/etc_trace_obj.fs, etc_trace_obj.time_select_idx);
                
                if(~etc_trace_obj.flag_mark)
                    if(etc_trace_obj.config_current_time_flag)
                        etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'m','linewidth',2);
                        set(etc_trace_obj.time_select_line,'color',etc_trace_obj.config_current_time_color);
                    end;
                else
                    if(etc_trace_obj.config_current_time_flag)
                        etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'r','linewidth',2);
                    end;
                end;
                
                %update trace GUI
                hObject=findobj('tag','edit_time_now_idx');
                set(hObject,'String',num2str(etc_trace_obj.time_select_idx));
                hObject=findobj('tag','edit_time_now');
                set(hObject,'String',num2str((etc_trace_obj.time_select_idx-1)/etc_trace_obj.fs));
                
                %update trigger GUI
                hObject=findobj('tag','edit_time');
                set(hObject,'String',num2str(etc_trace_obj.time_select_idx));
                if(isfield(etc_trace_obj,'trigger_now'))
                    if(~isempty(etc_trace_obj.trigger_now))
                        hObject=findobj('tag','edit_class');
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
                        figure(etc_trace_obj.fig_topology);
                        flag_camlight=0;
                        global etc_render_fsbrain;
                        [aa bb]=view;
                        etc_render_fsbrain.view_angle=[aa bb];
                        
                        if(isempty(etc_trace_obj.topo))
                            [filename, pathname, filterindex] = uigetfile({'*.mat','topology Matlab file'}, 'Pick a topology definition file');
                            if(filename>0)
                                try
                                    load(sprintf('%s/%s',pathname,filename));
                                    etc_trace_obj.topo.vertex=vertex;
                                    etc_trace_obj.topo.face=face;
                                    
                                    Index=find(contains(electrode_name,etc_trace_obj.ch_names));
                                    if(length(Index)==length(etc_trace_obj.ch_names)) %all electrodes were found on topology
                                        for ii=1:length(etc_trace_obj.ch_names)
                                            for idx=1:length(electrode_name)
                                                if(stcmp(electrode_name{idx},etc_trace_obj.ch_names{ii}))
                                                    Index(ii)=idx;
                                                end;
                                            end;
                                        end;
                                        etc_trace_obj.topo.ch_names=electrode_name(Index);
                                        etc_trace_obj.topo.electrode_idx=electrode_idx(Index);
                                    end;
                                    
                                    %etc_trace_obj.topo.ch_names=electrode_name;
                                    %etc_trace_obj.topo.electrode_idx=electrode_idx;
                                    
                                catch ME
                                end;
                                
                                global etc_render_fsbrain;
                                if(isempty(etc_render_fsbrain))
                                    etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',10,'topo_threshold',[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ],'flag_camlight',flag_camlight);
                                else
                                    try
                                        delete(etc_render_fsbrain.click_point);
                                        delete(etc_render_fsbrain.click_vertex_point);
                                        delete(etc_render_fsbrain.click_overlay_vertex_point);
                                    
                                        etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                                    catch ME
                                    end;
                                end;
                                
                            end;
                        else
                            global etc_render_fsbrain;
                            if(isempty(etc_render_fsbrain))
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',10,'topo_threshold',[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ],'flag_camlight',flag_camlight);
                            else
                                try
                                    delete(etc_render_fsbrain.click_point);
                                    delete(etc_render_fsbrain.click_vertex_point);
                                    delete(etc_render_fsbrain.click_overlay_vertex_point);
                                    
                                    etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(etc_trace_obj.topo.electrode_data_idx),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                                catch ME
                                end;
                            end;
                        end;
                    end;
                end;
                figure(etc_trace_obj.fig_trace);
            end;
        end;
end;

return;


function redraw()
global etc_trace_obj;

figure(etc_trace_obj.fig_trace);
tmp=get(etc_trace_obj.fig_trace,'child');
etc_trace_obj.axis_trace=tmp(end);
cla(etc_trace_obj.axis_trace);

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

            tmp=etc_trace_obj.aux_data{ii}(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx);
            tmp=cat(1,tmp,ones(1,size(tmp,2)));
            
            %select channels;
            tmp=etc_trace_obj.select*tmp;
            
            %montage channels;
            tmp=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix*tmp;
            
            %scaling channels;
            tmp=etc_trace_obj.scaling{etc_trace_obj.montage_idx}*tmp;
            
            %vertical shift for display
            S=eye(size(tmp,1));
            S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*[0:size(tmp,1)-2])';
            tmp=S*tmp;
            
            
            tmp=tmp(1:end-1,:);
            tmp=tmp';
             
            %hh=plot(etc_trace_obj.axis_trace, tmp,'color',cc(ii,:));
            if(etc_trace_obj.config_aux_trace_flag)
                hh=plot(etc_trace_obj.axis_trace, tmp,'color',etc_trace_obj.config_aux_trace_color);
                set(hh,'linewidth',etc_trace_obj.config_aux_trace_width);
            end;
            hold(etc_trace_obj.axis_trace,'on');
        end;
    end;
end;

tmp=etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx);
tmp=cat(1,tmp,ones(1,size(tmp,2)));

%select channels;
tmp=etc_trace_obj.select*tmp;

%montage channels;
tmp=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix*tmp;

%scaling channels;
tmp=etc_trace_obj.scaling{etc_trace_obj.montage_idx}*tmp;

%vertical shift for display 
S=eye(size(tmp,1));
S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*[0:size(tmp,1)-2])';
tmp=S*tmp;



tmp=tmp(1:end-1,:);
tmp=tmp';
hh=plot(etc_trace_obj.axis_trace, tmp,'color',etc_trace_obj.config_trace_color);
set(hh,'linewidth',etc_trace_obj.config_trace_width);

%assign a tag for each trace
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
    %set(hh(idx),'tag',etc_trace_obj.ch_names{idx}); 
    set(hh(idx),'tag',ss); 
end;
set(hh,'ButtonDownFcn',@etc_trace_callback);

%highlight selected trace
if(isfield(etc_trace_obj,'trace_selected_idx'))
    if(~isempty(etc_trace_obj.trace_selected_idx))
        set(hh(etc_trace_obj.trace_selected_idx),'linewidth',2,'color','b');
        
        if(isfield(etc_trace_obj,'electrode_listbox'))
            if(isvalid(etc_trace_obj.electrode_listbox))
                set(etc_trace_obj.electrode_listbox,'Value', etc_trace_obj.trace_selected_idx);
            else
            end;
        else
        end;
        
    else
    end;
else
end;

set(etc_trace_obj.axis_trace,'ylim',[min(etc_trace_obj.ylim) min(etc_trace_obj.ylim)+(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-1)*diff(sort(etc_trace_obj.ylim))]);
set(etc_trace_obj.axis_trace,'xlim',[1 etc_trace_obj.time_duration_idx]);
set(etc_trace_obj.axis_trace,'xtick',round([0:5]./5.*etc_trace_obj.time_duration_idx));
set(etc_trace_obj.axis_trace,'ydir','reverse');
xx=(etc_trace_obj.time_begin_idx+round([0:5]./5.*etc_trace_obj.time_duration_idx))-1;
set(etc_trace_obj.axis_trace,'xticklabel',cellstr(num2str((xx./etc_trace_obj.fs)')));


%plot electrode names
set(etc_trace_obj.axis_trace,'ytick',diff(sort(etc_trace_obj.ylim)).*[0:(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-1)-1]);
set(etc_trace_obj.axis_trace,'yticklabels',etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names);

%plot trigger
try
    %all triggers
    idx=find((etc_trace_obj.trigger.time>=etc_trace_obj.time_begin_idx)&(etc_trace_obj.trigger.time<=etc_trace_obj.time_end_idx));
    
    if(etc_trace_obj.config_current_trigger_flag)
        h=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.trigger.time(idx)-etc_trace_obj.time_begin_idx,[2 1]),repmat(get(etc_trace_obj.axis_trace,'ylim')',[1 length(idx)]),'LineWidth',2,'LineStyle',':','Color',etc_trace_obj.config_current_trigger_color);
    end;
    
    %current selected trigger
    trigger_idx=find(etc_trace_obj.trigger.event==etc_trace_obj.trigger_now);
    trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    
    idx=find((etc_trace_obj.trigger.time(trigger_idx)>=etc_trace_obj.time_begin_idx)&(etc_trace_obj.trigger.time(trigger_idx)<=etc_trace_obj.time_end_idx));
    
    if(etc_trace_obj.config_current_trigger_flag)
        h=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.trigger.time(trigger_idx(idx))-etc_trace_obj.time_begin_idx,[2 1]),repmat(get(etc_trace_obj.axis_trace,'ylim')',[1 length(idx)]),'LineWidth',2,'LineStyle','-','Color',etc_trace_obj.config_current_trigger_color);
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
            etc_trace_obj.time_select_line=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1,[2 1]),get(etc_trace_obj.axis_trace,'ylim')','LineWidth',2,'LineStyle','-','Color',etc_trace_obj.config_current_time_color);
        end;
    else
        if(etc_trace_obj.config_current_trigger_flag)
            etc_trace_obj.time_select_line=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1,[2 1]),get(etc_trace_obj.axis_trace,'ylim')','LineWidth',2,'LineStyle','-','Color','r');
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

redraw;

return;


function etc_trace_electrode_listbox_callback(hObj,event)

global etc_trace_obj;

Index=get(hObj,'value');
fprintf('[%s] selected in the list box\n',etc_trace_obj.ch_names{Index});
etc_trace_obj.trace_selected_idx=Index;

redraw;

return;



