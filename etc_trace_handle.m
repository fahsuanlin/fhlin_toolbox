function etc_trace_handle(param,varargin)

global etc_trace_obj;


cc=[];

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'c0'
            cc='c0';
        case 'cc'
            cc=option;
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
    case 'draw_stc'
        draw_stc;
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('g: open time course GUI \n');
                fprintf('k: open registration GUI\n');
                fprintf('l: open electrode list\n');
                fprintf('w: open coordinates GUI\n');
                fprintf('s: smooth overlay \n');
                fprintf('d: interactive threshold change\n');
                fprintf('c: switch on/off the colorbar\n');
                fprintf('u: show cluster labels from files\n');
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
                %                 %fprintf('\nGUI...\n');
                %                 if(isfield(etc_render_fsbrain,'fig_gui'))
                %                     etc_trace_obj.fig_gui=[];
                %                 end;
                %                 etc_trace_obj.fig_gui=etc_render_fsbrain_gui;
                %                 set(etc_trace_obj.fig_gui,'unit','pixel');
                %                 pos=get(etc_trace_obj.fig_gui,'pos');
                %                 pos_brain=get(etc_trace_obj.fig_brain,'pos');
                %                 set(etc_trace_obj.fig_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
            case 'k'
                %                 %fprintf('\nregister points...\n');
                %                 if(isfield(etc_render_fsbrain,'fig_register'))
                %                     etc_trace_obj.fig_register=[];
                %                 end;
                %                 etc_trace_obj.fig_register=etc_render_fsbrain_register;
                %                 set(etc_trace_obj.fig_register,'unit','pixel');
                %                 pos=get(etc_trace_obj.fig_register,'pos');
                %                 pos_brain=get(etc_trace_obj.fig_brain,'pos');
                %                 set(etc_trace_obj.fig_register,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
            case 's' %mark triggers/events
                if(etc_trace_obj.flag_mark)
                    fprintf('start making triggers/events...\n');
                    
                else
                    fprintf('stop making triggers/events...\n');
                    
                end;
                etc_trace_obj.flag_mark=~etc_trace_obj.flag_mark;
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
                                    
                                    etc_trace_obj.topo.ch_names=electrode_name;
                                    etc_trace_obj.topo.electrode_idx=electrode_idx;
                                    
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
                                        etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',10,'topo_threshold',[10 20],'flag_camlight',flag_camlight);
                                    else
                                        delete(etc_render_fsbrain.click_point);
                                        delete(etc_render_fsbrain.click_vertex_point);
                                        delete(etc_render_fsbrain.click_overlay_vertex_point);
                                        
                                        etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
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
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',10,'topo_threshold',[10 20],'flag_camlight',flag_camlight);
                            else
                                delete(etc_render_fsbrain.click_point);
                                delete(etc_render_fsbrain.click_vertex_point);
                                delete(etc_render_fsbrain.click_overlay_vertex_point);
                                
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                            end;
                        end;
                    else
                    end;
                else
                end;
            case 'm' %a list box of montages
                if(isfield(etc_trace_obj,'fig_montage_listbox'))
                    if(isvalid(etc_trace_obj.fig_montage_listbox))
                        
                        figure(etc_trace_obj.fig_montage_listbox)
                    else
                        etc_trace_obj.fig_montage_listbox = figure('Visible','off');
                    end;
                else
                    etc_trace_obj.fig_montage_listbox = figure('Visible','off');
                end;
                set(etc_trace_obj.fig_montage_listbox,'pos',[200 600 200 200]);
                set(etc_trace_obj.fig_montage_listbox,'Name','montages');
                set(etc_trace_obj.fig_montage_listbox,'Resize','off');
                
                etc_trace_obj.fig_montage_listbox=uicontrol('Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.montage_name,'Callback',@etc_trace_montage_listbox_callback);
                
%                 if(isfield(etc_trace_obj,'trace_selected_idx'))
%                     if(~isempty(etc_trace_obj.trace_selected_idx))
%                         etc_trace_obj.electrode_listbox=uicontrol('Value',etc_trace_obj.trace_selected_idx,'Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.ch_names,'Callback',@etc_trace_electrode_listbox_callback);
%                     else
%                         etc_trace_obj.electrode_listbox=uicontrol('Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.ch_names,'Callback',@etc_trace_electrode_listbox_callback);
%                     end;
%                 else
%                     etc_trace_obj.electrode_listbox=uicontrol('Style', 'listbox','Position',[1 1 200 200],'string',etc_trace_obj.ch_names,'Callback',@etc_trace_electrode_listbox_callback);
%                 end;
                
                set(etc_trace_obj.fig_montage_listbox, 'Visible','on');                
                
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
                        if(~isfield(etc_trace_obj,'ylim_single'))
                            etc_trace_obj.ylim_single=etc_trace_obj.ylim;
                        end;
                        fprintf('change y limits for a single channel...\n');
                        if(isempty(etc_trace_obj.ylim_single))
                            etc_trace_obj.ylim_single=get(gca,'ylim');
                        end;
                        fprintf('current limits = %s\n',mat2str(etc_trace_obj.ylim_single));
                        def={num2str(etc_trace_obj.ylim_single)};
                        answer=inputdlg('change limits for a single channel',sprintf('current threshold = %s',mat2str(etc_trace_obj.ylim)),1,def);
                        if(~isempty(answer))
                            etc_trace_obj.ylim_single=str2num(answer{1});
                            fprintf('updated time course limits = %s\n',mat2str(etc_trace_obj.ylim_single));
                            redraw;
                        end;
                    else
                        fprintf('change y limits...\n');
                        if(isempty(etc_trace_obj.ylim))
                            etc_trace_obj.ylim=get(gca,'ylim');
                        end;
                        fprintf('current limits = %s\n',mat2str(etc_trace_obj.ylim));
                        def={num2str(etc_trace_obj.ylim)};
                        answer=inputdlg('change limits',sprintf('current threshold = %s',mat2str(etc_trace_obj.ylim)),1,def);
                        if(~isempty(answer))
                            etc_trace_obj.ylim=str2num(answer{1});
                            fprintf('updated time course limits = %s\n',mat2str(etc_trace_obj.ylim));
                            redraw;
                        end;
                    end;
                end;
            otherwise
        end;
    case 'bd'        
        if(gcf==etc_trace_obj.fig_trace)
            
            xx=get(gca,'currentpoint');
            xx=xx(1);
            etc_trace_obj.time_select_idx=round(xx)+etc_trace_obj.time_begin_idx-1;
            fprintf('selected time <%3.3f> (s) [index [%d] (sample)]\n',etc_trace_obj.time_select_idx/etc_trace_obj.fs, etc_trace_obj.time_select_idx);
            
            if(isfield(etc_trace_obj,'time_select_line'))
                try
                    delete(etc_trace_obj.time_select_line);
                catch
                end;
            end;
            ylim=get(etc_trace_obj.axis_trace,'ylim');
            hold on;

            if(~etc_trace_obj.flag_mark)
                etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'m','linewidth',2);
            else
                etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'r','linewidth',2);
            end;
            
            %update topology
            data=etc_trace_obj.data(:,etc_trace_obj.time_select_idx);
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
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',10,'topo_threshold',[10 20],'flag_camlight',flag_camlight);
                            else
                                delete(etc_render_fsbrain.click_point);
                                delete(etc_render_fsbrain.click_vertex_point);
                                delete(etc_render_fsbrain.click_overlay_vertex_point);
                                
                                etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                            end;
                            
                        end;
                    else
                        global etc_render_fsbrain;
                        if(isempty(etc_render_fsbrain))
                            etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',10,'topo_threshold',[10 20],'flag_camlight',flag_camlight);
                        else
                            delete(etc_render_fsbrain.click_point);
                            delete(etc_render_fsbrain.click_vertex_point);
                            delete(etc_render_fsbrain.click_overlay_vertex_point);
                            
                            etc_render_topo('vol_vertex',etc_trace_obj.topo.vertex,'vol_face',etc_trace_obj.topo.face-1,'topo_vertex',etc_trace_obj.topo.electrode_idx-1,'topo_value',data(:),'topo_smooth',etc_render_fsbrain.overlay_smooth,'topo_threshold',etc_render_fsbrain.overlay_threshold,'flag_camlight',flag_camlight,'view_angle',etc_render_fsbrain.view_angle);
                        end;
                    end;
                end;
            end;
            
            figure(etc_trace_obj.fig_trace);
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
% tmp=bsxfun(@plus, etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.data,1)-1]);
% h=plot(etc_trace_obj.axis_trace, tmp,'color',[0    0.4470    0.7410]);

if(isfield(etc_trace_obj,'aux_data'))
    if(~isempty(etc_trace_obj.aux_data))
        for ii=1:length(etc_trace_obj.aux_data)
            %%scaling 
            %tmp=etc_trace_obj.S*tmp;

            %tmp=bsxfun(@plus, etc_trace_obj.aux_data{ii}(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.aux_data{ii},1)-1]);
            tmp=bsxfun(@plus, etc_trace_obj.aux_data{ii}(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.aux_data{ii},1)-1]);
            
            %%montage 
            %tmp=etc_trace_obj.M*tmp;

            hold(etc_trace_obj.axis_trace,'on');
            h=plot(etc_trace_obj.axis_trace, tmp);
        end;
    end;
end;

tmp=etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx);
tmp=cat(1,tmp,ones(1,size(tmp,2)));

%montage;
tmp=etc_trace_obj.montage*tmp;

%scaling
s=diag(etc_trace_obj.scaling);
s=s(1:end-1);
if(isfield(etc_trace_obj,'trace_selected_idx'))
    if(~isempty(etc_trace_obj.trace_selected_idx))
        s(etc_trace_obj.trace_selected_idx)=abs(diff(etc_trace_obj.ylim))./abs(diff(etc_trace_obj.ylim_single));
    end;
end;
s(end+1)=1;
etc_trace_obj.scaling=diag(s);
tmp=etc_trace_obj.scaling*tmp;

%vertical shift for display 
S=eye(size(tmp,1));
S(1:(size(tmp,1)-1),end)=(diff(sort(etc_trace_obj.ylim)).*[0:size(tmp,1)-2])';
tmp=S*tmp;

%tmp=bsxfun(@plus, etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.data,1)-1]);


tmp=tmp(1:end-1,:);
tmp=tmp';
hh=plot(etc_trace_obj.axis_trace, tmp,'color',[0    0.4470    0.7410]);
for idx=1:length(hh) set(hh(idx),'tag',etc_trace_obj.ch_names{idx}); end;

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

set(etc_trace_obj.axis_trace,'ylim',[min(etc_trace_obj.ylim) min(etc_trace_obj.ylim)+size(etc_trace_obj.data,1)*diff(sort(etc_trace_obj.ylim))]);
set(etc_trace_obj.axis_trace,'xlim',[1 etc_trace_obj.time_duration_idx]);
set(etc_trace_obj.axis_trace,'xtick',round([0:5]./5.*etc_trace_obj.time_duration_idx));
xx=(etc_trace_obj.time_begin_idx+round([0:5]./5.*etc_trace_obj.time_duration_idx))-1;
set(etc_trace_obj.axis_trace,'xticklabel',cellstr(num2str((xx./etc_trace_obj.fs)')));
set(hh,'ButtonDownFcn',@etc_trace_callback);

%plot electrode names
set(etc_trace_obj.axis_trace,'ytick',diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.data,1)-1]);
set(etc_trace_obj.axis_trace,'yticklabels',etc_trace_obj.ch_names);

%plot trigger
try
    %all triggers
    idx=find((etc_trace_obj.trigger.time>=etc_trace_obj.time_begin_idx)&(etc_trace_obj.trigger.time<=etc_trace_obj.time_end_idx));
    
    h=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.trigger.time(idx)-etc_trace_obj.time_begin_idx,[2 1]),repmat(get(etc_trace_obj.axis_trace,'ylim')',[1 length(idx)]),'LineWidth',2,'LineStyle','-.','Color',[1 1 1].*0.6);
    
    
    %current selected trigger
    trigger_idx=find(etc_trace_obj.trigger.event==str2num(etc_trace_obj.trigger_now));
    trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    
    idx=find((etc_trace_obj.trigger.time(trigger_idx)>=etc_trace_obj.time_begin_idx)&(etc_trace_obj.trigger.time(trigger_idx)<=etc_trace_obj.time_end_idx));
    
    h=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.trigger.time(trigger_idx(idx))-etc_trace_obj.time_begin_idx,[2 1]),repmat(get(etc_trace_obj.axis_trace,'ylim')',[1 length(idx)]),'LineWidth',2,'LineStyle','-','Color',[0 1 0].*1.0);
    
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
        etc_trace_obj.time_select_line=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1,[2 1]),get(etc_trace_obj.axis_trace,'ylim')','LineWidth',2,'LineStyle','-','Color','m');
    else
        etc_trace_obj.time_select_line=line(etc_trace_obj.axis_trace, repmat(etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1,[2 1]),get(etc_trace_obj.axis_trace,'ylim')','LineWidth',2,'LineStyle','-','Color','r');
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

Index = find(strcmp(etc_trace_obj.ch_names,src.Tag));

if(isfield(etc_trace_obj,'trace_selected_idx'))
    if(~isempty(etc_trace_obj.trace_selected_idx))
        if(Index==etc_trace_obj.trace_selected_idx)
            etc_trace_obj.trace_selected_idx=[];
            
            %set scaling back to other channels
            etc_trace_obj.scaling=eye(size(etc_trace_obj.scaling));
        else
            etc_trace_obj.trace_selected_idx=Index;
            
            %set scaling of the new selected channel
            etc_trace_obj.scaling=eye(size(etc_trace_obj.scaling));
            s=diag(etc_trace_obj.scaling);
            s=s(1:end-1);
            s(etc_trace_obj.trace_selected_idx)=abs(diff(etc_trace_obj.ylim))./abs(diff(etc_trace_obj.ylim_single));
            s(end+1)=1;
            etc_trace_obj.scaling=diag(s);
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


function etc_trace_montage_listbox_callback(hObj,event)

global etc_trace_obj;

Index=get(hObj,'value');
fprintf('[%s] selected in the list box\n',etc_trace_obj.ch_names{Index});
etc_trace_obj.trace_selected_idx=Index;

redraw;

return;

