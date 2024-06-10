function fig_spectrum=etc_trace_spectrum(varargin)

fig_spectrum=[];
spec_scale=1e3; %a scaling factor for spectrum estimates

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'spec_scale'
            spec_scale=option_value;
        case 'fig_spectrum'
           fig_spectrum=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

global etc_trace_obj;

if(isempty(fig_spectrum))
    fig_spectrum=figure;
else
    try
        figure(fig_spectrum);
    catch
        fig_spectrum=figure;
    end;
end;

set(fig_spectrum,'menubar','none','NumberTitle', 'off');

pp0=get(fig_spectrum,'outerpos');
pp1=get(etc_trace_obj.fig_trace,'outerpos');
set(fig_spectrum,'outerpos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp1(4)]);
set(fig_spectrum,'Name','spectrum','color','w');
%set(fig_spectrum,'Resize','off');

axis_spec=axes;
set(axis_spec,'Position',etc_trace_obj.axis_trace.Position);

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
        return;
    case 'image'
        return;

end;

%spectrum estimation
Pxx=[];
for ch_idx=1:size(tmp,1)-1
    [Pxx(:,ch_idx),F] = pwelch(tmp(ch_idx,:),[],[],[],etc_trace_obj.fs);
end;
Pxx=Pxx.'.*spec_scale;
Pxx(end+1,:)=1;

%tmp=S*tmp;
tmp=S*Pxx;


tmp=tmp(1:end-1,:);
tmp=tmp';

    switch(etc_trace_obj.view_style)
        case {'trace','butterfly'}
            hh=[];
            hh=plot(F,tmp,'color',etc_trace_obj.config_trace_color);
            set(hh,'linewidth',etc_trace_obj.config_trace_width);
            
           
            %assign a tag for each trace
            etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names={};
            for idx=1:length(hh)
                m=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix(idx,:);
                %if(sum(abs(m))<eps) break; end;
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
    end;

%highlight selected trace
obj=findobj('Tag','edit_local_trigger_ch');
if(~isempty(obj))
    set(obj,'String','');
end;
if(isfield(etc_trace_obj,'trace_selected_idx'))
    if(~isempty(etc_trace_obj.trace_selected_idx))
        
        switch(etc_trace_obj.view_style)
            case {'trace','butterfly'}
                set(hh(etc_trace_obj.trace_selected_idx),'linewidth',4,'color','b');
        end;
        
    end;
end;



try
    switch(etc_trace_obj.view_style)
        case {'trace','butterfly'}
            set(axis_spec,'ylim',[min(etc_trace_obj.ylim)-0.5 max(etc_trace_obj.ylim)+0.5+(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-2)*diff(sort(etc_trace_obj.ylim))]);
        case 'image'
            %set(axis_spec,'ylim',[0.5 size(tmp,2)+0.5]);
    end;
    set(axis_spec,'xlim',[min(F) max(F)]);
    set(axis_spec,'xtick',F(1:10:end));
    set(axis_spec,'xscale','log')
    set(axis_spec,'ydir','reverse');
    %xx=(round([0:5]./5.*etc_trace_obj.time_duration_idx)+etc_trace_obj.time_window_begin_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin;
    set(axis_spec,'xticklabel',cellstr(num2str(F(1:10:end),'%1.0f')));
    set(axis_spec,'box','off');
catch ME
end;

try
    %plot electrode names
    switch(etc_trace_obj.view_style)
        case 'trace'
            if(~isempty(etc_trace_obj.montage_ch_name))
                set(axis_spec,'ytick',diff(sort(etc_trace_obj.ylim)).*[0:(size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix,1)-1)-1]);
                set(axis_spec,'yticklabels',etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names);
                %
                %set(axis_spec,'ButtonDownFcn',@etc_trace_callback);

            end;
%         case 'butterfly'
%             set(axis_spec,'ytick',(diff(sort(etc_trace_obj.ylim)).*round(size(tmp,2)/2)));
%             set(axis_spec,'yticklabels','all');
%         case 'image'
%             if(~isempty(etc_trace_obj.montage_ch_name))
%                 set(axis_spec,'ytick',[1:size(tmp,2)]);
%                 set(axis_spec,'yticklabels',etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names);
%             end;
    end;
    
catch ME
end;


%font style
set(axis_spec,'fontname','helvetica','fontsize',12);
set(etc_trace_obj.fig_trace,'color','w')
set(axis_spec,'Clipping','off');

return;
