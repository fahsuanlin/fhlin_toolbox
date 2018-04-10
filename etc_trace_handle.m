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
                fprintf('l: open label GUI\n');
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
            case 'w' %coordinate GUI
                %                 %fprintf('\nCoordinate GUI...\n');
                %                 if(isfield(etc_render_fsbrain,'fig_coord_gui'))
                %                     etc_trace_obj.fig_coord_gui=[];
                %                 end;
                %                 etc_trace_obj.fig_coord_gui=etc_render_fsbrain_coord_gui;
                %                 set(etc_trace_obj.fig_coord_gui,'unit','pixel');
                %                 pos=get(etc_trace_obj.fig_coord_gui,'pos');
                %                 pos_brain=get(etc_trace_obj.fig_brain,'pos');
                %                 set(etc_trace_obj.fig_coord_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                
            case 'c' %colorbar;
                %                 figure(etc_trace_obj.fig_brain);
                %                 if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
                %                     if(isempty(etc_trace_obj.h_colorbar_pos))
                %                         etc_trace_obj.brain_axis_pos=get(etc_trace_obj.brain_axis,'pos');
                %                         set(etc_trace_obj.brain_axis,'pos',[etc_trace_obj.brain_axis_pos(1) 0.2 etc_trace_obj.brain_axis_pos(3) 0.8]);
                %                         etc_trace_obj.h_colorbar=subplot('position',[etc_trace_obj.brain_axis_pos(1) 0.0 etc_trace_obj.brain_axis_pos(3) 0.2]);
                %
                %                         cmap=[etc_trace_obj.overlay_cmap; etc_trace_obj.overlay_cmap_neg];
                %                         hold on;
                %
                %                         if(etc_trace_obj.overlay_value_flag_pos)
                %                             etc_trace_obj.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                %                             image([1:size(etc_trace_obj.overlay_cmap,1)]); axis off; colormap(cmap);
                %                             h=text(-3,1,sprintf('%1.3f',min(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_trace_obj.bg_color);
                %                             h=text(size(etc_trace_obj.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_trace_obj.bg_color);
                %                         else
                %                             etc_trace_obj.h_colorbar_pos=[];
                %                         end;
                %                         if(etc_trace_obj.overlay_value_flag_neg)
                %                             etc_trace_obj.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                %                             image([size(etc_trace_obj.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                %                             h=text(-3,1,sprintf('-%1.3f',min(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_trace_obj.bg_color);
                %                             h=text(size(etc_trace_obj.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_trace_obj.bg_color);
                %                         else
                %                             etc_trace_obj.h_colorbar_neg=[];
                %                         end;
                %
                %                         if(ishandle(etc_trace_obj.fig_gui))
                %                             set(findobj(etc_trace_obj.fig_gui,'tag','checkbox_show_colorbar'),'value',1);
                %                         end;
                %                     else
                %                         delete(etc_trace_obj.h_colorbar_pos);
                %                         etc_trace_obj.h_colorbar_pos=[];
                %                         delete(etc_trace_obj.h_colorbar_neg);
                %                         etc_trace_obj.h_colorbar_neg=[];
                %                         set(etc_trace_obj.brain_axis,'pos',etc_trace_obj.brain_axis_pos);
                %
                %                         if(ishandle(etc_trace_obj.fig_gui))
                %                             set(findobj(etc_trace_obj.fig_gui,'tag','checkbox_show_colorbar'),'value',0);
                %                         end;
                %                     end;
                %                 else
                %                     etc_trace_obj.brain_axis=gca;
                %                     etc_trace_obj.brain_axis_pos=get(gca,'pos');
                %                     set(etc_trace_obj.brain_axis,'pos',[etc_trace_obj.brain_axis_pos(1) 0.2 etc_trace_obj.brain_axis_pos(3) 0.8]);
                %                     etc_trace_obj.h_colorbar=subplot('position',[etc_trace_obj.brain_axis_pos(1) 0.0 etc_trace_obj.brain_axis_pos(3) 0.2]);
                %
                %                     cmap=[etc_trace_obj.overlay_cmap; etc_trace_obj.overlay_cmap_neg];
                %
                %                     if(etc_trace_obj.overlay_value_flag_pos)
                %                         etc_trace_obj.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                %                         image([1:size(etc_trace_obj.overlay_cmap,1)]); axis off; colormap(cmap);
                %                         h=text(-3,1,sprintf('%1.3f',min(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_trace_obj.bg_color);
                %                         h=text(size(etc_trace_obj.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_trace_obj.bg_color);
                %                     else
                %                         etc_trace_obj.h_colorbar_pos=[];
                %                     end;
                %
                %                     if(etc_trace_obj.overlay_value_flag_neg)
                %                         etc_trace_obj.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                %                         image([size(etc_trace_obj.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                %                         h=text(-3,1,sprintf('-%1.3f',min(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_trace_obj.bg_color);
                %                         h=text(size(etc_trace_obj.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_trace_obj.bg_color);
                %                     else
                %                         etc_trace_obj.h_colorbar_neg=[];
                %                     end;
                %                 end;
            case 'c0' %enforce showing colorbar
                %                 figure(etc_trace_obj.fig_brain);
                %
                %                 etc_trace_obj.brain_axis_pos=get(etc_trace_obj.brain_axis,'pos');
                %                 set(etc_trace_obj.brain_axis,'pos',[etc_trace_obj.brain_axis_pos(1) 0.2 etc_trace_obj.brain_axis_pos(3) 0.8]);
                %                 etc_trace_obj.h_colorbar=subplot('position',[etc_trace_obj.brain_axis_pos(1) 0.0 etc_trace_obj.brain_axis_pos(3) 0.2]);
                %
                %                 cmap=[etc_trace_obj.overlay_cmap; etc_trace_obj.overlay_cmap_neg];
                %                 hold on;
                %
                %                 if(etc_trace_obj.overlay_value_flag_pos)
                %                     etc_trace_obj.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                %                     image([1:size(etc_trace_obj.overlay_cmap,1)]); axis off; colormap(cmap);
                %                     h=text(-3,1,sprintf('%1.3f',min(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_trace_obj.bg_color);
                %                     h=text(size(etc_trace_obj.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_trace_obj.bg_color);
                %                 else
                %                     etc_trace_obj.h_colorbar_pos=[];
                %                 end;
                %                 if(etc_trace_obj.overlay_value_flag_neg)
                %                     etc_trace_obj.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                %                     image([size(etc_trace_obj.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                %                     h=text(-3,1,sprintf('-%1.3f',min(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_trace_obj.bg_color);
                %                     h=text(size(etc_trace_obj.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_trace_obj.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_trace_obj.bg_color);
                %                 else
                %                     etc_trace_obj.h_colorbar_neg=[];
                %                 end;
                
                
            case 'd' %change overlay threshold or time course limits
                
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
                

            otherwise
        end;
    case 'bd'
        
        if(gcf==etc_trace_obj.fig_trace)
            
            xx=get(gca,'currentpoint');
            xx=xx(1);
            %if(isempty(etc_trace_obj.overlay_stc_timeVec))
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
            etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'m','linewidth',2);
            
            %else
            %                             [dummy,etc_trace_obj.overlay_stc_timeVec_idx]=min(abs(etc_trace_obj.overlay_stc_timeVec-xx));
            %                             if(isempty(etc_trace_obj.overlay_stc_timeVec_unit))
            %                                 unt='sample';
            %                             else
            %                                 unt=etc_trace_obj.overlay_stc_timeVec_unit;
            %                             end;
            %                             fprintf('showing STC at time [%2.2f] %s\n',etc_trace_obj.overlay_stc_timeVec(etc_trace_obj.overlay_stc_timeVec_idx),unt);
            %                         end;
            
            %             if(~iscell(etc_trace_obj.overlay_value))
            %                 etc_trace_obj.overlay_value=etc_trace_obj.overlay_stc(:,etc_trace_obj.overlay_stc_timeVec_idx);
            %             else
            %                 for h_idx=1:length(etc_trace_obj.overlay_value)
            %                     etc_trace_obj.overlay_value{h_idx}=etc_trace_obj.overlay_stc_hemi{h_idx}(:,etc_trace_obj.overlay_stc_timeVec_idx);
            %                 end;
            %             end;
            %
            %             if(~isempty(etc_trace_obj.overlay_stc))
            %                 draw_stc;
            %             end;
            %
            %             if(ishandle(etc_trace_obj.fig_gui))
            %                 set(findobj(etc_trace_obj.fig_gui,'tag','slider_timeVec'),'value',etc_trace_obj.overlay_stc_timeVec(etc_trace_obj.overlay_stc_timeVec_idx));
            %
            %                 set(findobj(etc_trace_obj.fig_gui,'tag','edit_timeVec'),'value',etc_trace_obj.overlay_stc_timeVec(etc_trace_obj.overlay_stc_timeVec_idx));
            %                 set(findobj(etc_trace_obj.fig_gui,'tag','edit_timeVec'),'string',sprintf('%1.0f',etc_trace_obj.overlay_stc_timeVec(etc_trace_obj.overlay_stc_timeVec_idx)));
            %             end;
            %
            %             figure(etc_trace_obj.fig_brain);
            %             redraw;
            %             figure(etc_trace_obj.fig_stc);
            
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
tmp=bsxfun(@plus, etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.data,1)-1]);
plot(etc_trace_obj.axis_trace, tmp,'color',[0    0.4470    0.7410]);

if(isfield(etc_trace_obj,'aux_data'))
    if(~isempty(etc_trace_obj.aux_data))
        for ii=1:length(etc_trace_obj.aux_data)
            tmp=bsxfun(@plus, etc_trace_obj.aux_data{ii}(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.aux_data{ii},1)-1]);
            hold(etc_trace_obj.axis_trace,'on');
            plot(etc_trace_obj.axis_trace, tmp);
        end;
    end;
end;

tmp=bsxfun(@plus, etc_trace_obj.data(:,etc_trace_obj.time_begin_idx:etc_trace_obj.time_end_idx)', diff(sort(etc_trace_obj.ylim)).*[0:size(etc_trace_obj.data,1)-1]);
plot(etc_trace_obj.axis_trace, tmp,'color',[0    0.4470    0.7410]);

set(etc_trace_obj.axis_trace,'ylim',[min(etc_trace_obj.ylim) min(etc_trace_obj.ylim)+size(etc_trace_obj.data,1)*diff(sort(etc_trace_obj.ylim))]);
set(etc_trace_obj.axis_trace,'xlim',[1 etc_trace_obj.time_duration_idx]);
set(etc_trace_obj.axis_trace,'xtick',round([0:5]./5.*etc_trace_obj.time_duration_idx));
xx=(etc_trace_obj.time_begin_idx+round([0:5]./5.*etc_trace_obj.time_duration_idx))-1;
set(etc_trace_obj.axis_trace,'xticklabel',cellstr(num2str((xx./etc_trace_obj.fs)')));

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
    hold on;
    etc_trace_obj.time_select_line=plot([etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1 etc_trace_obj.time_select_idx-etc_trace_obj.time_begin_idx+1],ylim,'m','linewidth',2);
    
catch ME
end;

%font style
set(etc_trace_obj.axis_trace,'fontname','helvetica','fontsize',12);
set(etc_trace_obj.fig_trace,'color','w')


return;




