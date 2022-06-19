function h=etc_trace(data,varargin)

global etc_trace_obj;

etc_trace_obj=[];

fs=1; %sampling rate; Hz

ylim=[-50 50];
duration=10; %second
all_duration=[0.1 0.5 1 2 5 10 30]; %seconds

time_begin=0; %second;
time_select_idx=[];
h=[];

trace_selected_idx=[];

trigger=[];
aux_data={};
aux_data_name={};
aux_data_idx=[];
ch_names={};

data_name='';
all_data={};
all_data_name={};
all_data_main_idx=[];
all_data_aux_idx=[];

topo=[]; %topology structure; with "vertex", "face", "ch_names", "electrode_idx" 4 fields.
flag_mark=0;

select=[];
montage=[];
scaling=[];

config_trace_center_frac=0.5;
config_trace_width=1;
config_trace_color=[0    0.4470    0.7410];
config_trace_flag=1;
config_aux_trace_width=1;
config_aux_trace_color=[0.8500    0.3250    0.0980];
config_aux_trace_flag=1;
config_current_time_color=[1 0 1]; %magenta
config_current_trigger_color=[1 1 1].*0.6; %gray
config_current_trigger_flag=1;
config_current_time_flag=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'fs'
            fs=option_value;
        case 'ylim'
            ylim=option_value;
        case 'duration'
            duration=option_value;
        case 'time_begin'
            time_begin=option_value;
        case 'time_select_idx'
            time_select_idx=option_value;
        case 'trigger'
            trigger=option_value;
        case 'trace_selected_idx'
            trace_selected_idx=option_value;
        case 'ch_names'
            ch_names=option_value;
        case 'data_name'
            data_name=option_value;
        case 'aux_data'
            aux_data=option_value;
        case 'flag_mark'
            flag_mark=option_value;
        case 'select'
            select=option_value;
        case 'select_name'
            select_name=option_value;
        case 'montage'
            montage=option_value;
        case 'montage_name'
            montage_name=option_value;
        case 'scaling'
            scaling=option_value;
        case 'topo'
            topo=option_value;
        case 'config_trace_center_frac'
            config_trace_center_frac=option_value;
        case 'config_trace_width'
            config_trace_width=option_value;
        case 'config_trace_color'
            config_trace_color=option_value;
        case 'config_trace_flag'
            config_trace_flag=option_value;
        case 'config_aux_trace_width'
            config_aux_trace_width=option_value;
        case 'config_aux_trace_color'
            config_aux_trace_color=option_value;
        case 'config_aux_trace_flag'
            config_aux_trace_flag=option_value;
        case 'config_current_time_color'
            config_current_time_color=option_value;
        case 'config_current_trigger_color'
            config_current_trigger_color=option_value;
        case 'config_current_trigger_flag'
            config_current_trigger_flag=option_value;
        case 'config_current_time_flag'
            config_current_time_flag=option_value;
        otherwise
            fprintf('unkown option [%s]!\nerror!\n',option);
            return;
    end;
    
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%

%global etc_trace_obj;

%etc_trace_obj=[];

try
    delete(etc_trace_obj.fig_trace);
catch ME
end;

if(isempty(ch_names))
    for idx=1:size(data,1)
        ch_names{idx}=sprintf('%03d',idx);
    end;
end;

if(size(data,2)/fs<duration)
    %   duration=size(data,2)/fs/2;
end;

etc_trace_obj.fs=fs;
etc_trace_obj.ylim=ylim;

idx=find(all_duration<size(data,2)/etc_trace_obj.fs);
if(isempty(idx))
    %fprintf('not enough data points; must be longer than 0.1 s. error!\n');
    %return;
    duration=all_duration(1);
else
    duration=all_duration(idx(end));
end;
etc_trace_obj.time_begin=time_begin;
if(isempty(time_select_idx)) time_select_idx=1; end;
etc_trace_obj.time_select_idx=time_select_idx;
etc_trace_obj.time_duration_idx=round(duration.*fs);
etc_trace_obj.time_window_begin_idx=1;
etc_trace_obj.flag_time_window_auto_adjust=1;


if(~isempty(trigger))
    if(isfield(trigger,'event'))
        if(~iscell(trigger.event))
            str={};
            for idx=1:length(trigger.event)
                str{idx}=sprintf('%d',trigger.event(idx));
            end;
            trigger.event=str;
        end;
    end;
end;
etc_trace_obj.trigger=trigger;

etc_trace_obj.ch_names=ch_names;

%if(isempty(montage))
mm=eye(size(data,1));
montage_name='original';

config={};
for idx=1:length(etc_trace_obj.ch_names);
    config{end+1,1}=etc_trace_obj.ch_names{idx};
    config{end,2}='';
end;
%end;
etc_trace_obj.montage{1}.config_matrix=[mm, zeros(size(mm,1),1)
    zeros(1,size(mm,2)), 1];
etc_trace_obj.montage{1}.config=config;
etc_trace_obj.montage{1}.name=montage_name;
etc_trace_obj.montage_idx=1;



if(~isempty(montage))
    for m_idx=1:length(montage)
        
        M=[];
        ecg_idx=[];
        for idx=1:size(montage{m_idx}.config,1)
            m=zeros(1,length(etc_trace_obj.ch_names));
            if(~isempty(montage{m_idx}.config{idx,1}))
                m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,1}))))=1;
                if((strcmp(lower(montage{m_idx}.config{idx,1}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,1}),'ekg')))
                    ecg_idx=union(ecg_idx,idx);
                end;
            end;
            if(~isempty(montage{m_idx}.config{idx,2}))
                m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,2}))))=-1;;
                if((strcmp(lower(montage{m_idx}.config{idx,2}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,2}),'ekg')))
                    ecg_idx=union(ecg_idx,idx);
                end;
            end;
            M=cat(1,M,m);
        end;
        M(end+1,end+1)=1;
        
        etc_trace_obj.montage{m_idx+1}.config_matrix=M;
        etc_trace_obj.montage{m_idx+1}.config=montage{m_idx}.config;
        etc_trace_obj.montage{m_idx+1}.name=montage{m_idx}.name;
        
        S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
        S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
        etc_trace_obj.scaling{m_idx+1}=S;
        
        
    end;
    etc_trace_obj.montage_idx=m_idx+1;
end;




if(isempty(select))
    select=eye(size(data,1));
    select_name='all';
end;
etc_trace_obj.select{1}=[select, zeros(size(select,1),1)
    zeros(1,size(select,2)), 1];
etc_trace_obj.select_name{1}=select_name;
etc_trace_obj.select_idx=1;

if(isempty(scaling))
    scaling{1}=eye(size(data,1));
else
    scaling{1}=scaling;
end;
ecg_idx=find(strcmp(lower(etc_trace_obj.ch_names),'ecg')|strcmp(lower(etc_trace_obj.ch_names),'ekg'));
scaling{1}(ecg_idx,ecg_idx)=scaling{1}(ecg_idx,ecg_idx)./10;
etc_trace_obj.scaling{1}=[scaling{1}, zeros(size(scaling{1},1),1)
    zeros(1,size(scaling{1},2)), 1];
etc_trace_obj.scaling_idx=1;


etc_trace_obj.data=data;
etc_trace_obj.data_name=data_name;
etc_trace_obj.aux_data=aux_data;

etc_trace_obj.aux_data_name=aux_data_name;
etc_trace_obj.aux_data_idx=aux_data_idx;

etc_trace_obj.all_data=all_data;
etc_trace_obj.all_data_name=all_data_name;
etc_trace_obj.all_data_main_idx=all_data_main_idx;
etc_trace_obj.all_data_aux_idx=all_data_aux_idx;


if(~isempty(aux_data))
    if(length(aux_data)~=length(aux_data_name))
       
        for ii=1:length(aux_data)
            etc_trace_obj.aux_data_name{ii}=sprintf('aux%03d',ii);
            
            
            %etc_trace_obj.all_data{ii+1}=etc_trace_obj.aux_data{ii};
            %
            %etc_trace_obj.all_data_name{ii+1}=aux_data_name{ii};
            %etc_trace_obj.all_data_aux_idx=cat(2,etc_trace_obj.all_data_aux_idx,1);
        end;
    end;
end;

init_data;

etc_trace_obj.topo=topo;

etc_trace_obj.flag_mark=flag_mark;

etc_trace_obj.trace_selected_idx=trace_selected_idx;

etc_trace_obj.config_trace_center_frac=config_trace_center_frac;
etc_trace_obj.config_trace_width=config_trace_width;
etc_trace_obj.config_trace_color=config_trace_color;
etc_trace_obj.config_trace_flag=config_trace_flag;
etc_trace_obj.config_aux_trace_width=config_trace_width;
etc_trace_obj.config_aux_trace_color=config_aux_trace_color;
etc_trace_obj.config_aux_trace_flag=config_aux_trace_flag;
etc_trace_obj.config_current_time_color=config_current_time_color;
etc_trace_obj.config_current_trigger_color=config_current_trigger_color;
etc_trace_obj.config_current_trigger_flag=config_current_trigger_flag;
etc_trace_obj.config_current_time_flag=config_current_time_flag;


etc_trace_obj.montage_ch_name={};

etc_trace_obj.fig_topology=figure('visible','off');
delete(etc_trace_obj.fig_topology); %make it invalid
etc_trace_obj.fig_trigger=figure('visible','off');
delete(etc_trace_obj.fig_trigger); %make it invalid
etc_trace_obj.fig_montage=figure('visible','off');
delete(etc_trace_obj.fig_montage); %make it invalid
etc_trace_obj.fig_avg=figure('visible','off');
delete(etc_trace_obj.fig_avg); %make it invalid
etc_trace_obj.fig_info=figure('visible','off');
delete(etc_trace_obj.fig_info); %make it invalid
etc_trace_obj.fig_config=figure('visible','off');
delete(etc_trace_obj.fig_config); %make it invalid

etc_trace_obj.fig_trace=etc_trace_gui;

set(etc_trace_obj.fig_trace,'WindowButtonDownFcn','etc_trace_handle(''bd'')');
set(etc_trace_obj.fig_trace,'WindowButtonUpFcn','etc_trace_handle(''bu'')');
%f = figure('WindowButtonUpFcn',@dropObject,'units','normalized','WindowButtonMotionFcn',@moveObject);
set(etc_trace_obj.fig_trace,'KeyPressFcn','etc_trace_handle(''kb'')');
set(etc_trace_obj.fig_trace,'HandleVisibility','on')
set(etc_trace_obj.fig_trace,'invert','off');
set(etc_trace_obj.fig_trace,'Name','');
set(etc_trace_obj.fig_trace,'DeleteFcn','etc_trace_handle(''del'')');
set(etc_trace_obj.fig_trace,'CloseRequestFcn','etc_trace_handle(''del'')');

%drag-drop setting
etc_trace_obj.dragging = [];
etc_trace_obj.orPos = [];

etc_trace_handle('redraw');

drawnow;

etc_trace_obj.fig_control=etc_trace_control_gui;
set(etc_trace_obj.fig_trace,'units','normalized','outerposition',[0.1 0.5 0.8 0.5]);
drawnow;
set(etc_trace_obj.fig_trace,'units','pixel');
set(etc_trace_obj.fig_control,'units','pixel');
pp0=get(etc_trace_obj.fig_control,'outerpos');
pp1=get(etc_trace_obj.fig_trace,'outerpos');
set(etc_trace_obj.fig_control,'outerpos',[pp1(1)+(pp1(3))/2-pp0(3)/2, pp1(2)-pp0(4),pp0(3), pp0(4)]);
set(etc_trace_obj.fig_control,'Name','events');
set(etc_trace_obj.fig_control,'Resize','off');



return;

%call this function to update the variable etc_trace_obj.all_data and its
%related variables based on etc_trace_obj.data and etc_trace_obj.aux_data
function init_data()

global etc_trace_obj;

cc=[
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0    0.4470    0.7410
    ]; %color order


if(isempty(etc_trace_obj.data))
    for idx=1:length(etc_trace_obj.aux_data)
        etc_trace_obj.all_data{idx}=etc_trace_obj.aux_data{idx};
        etc_trace_obj.all_data_name{idx}=etc_trace_obj.aux_data_name{idx};
    end;
    etc_trace_obj.all_data_main_idx=[];
    etc_trace_obj.all_data_aux_idx=ones(1,length(etc_trace_obj.aux_data));
    
else
    etc_trace_obj.all_data{1}=etc_trace_obj.data;
    if(isempty(etc_trace_obj.data_name))
        etc_trace_obj.all_data_name{1}='main';
    else
        etc_trace_obj.all_data_name{1}=etc_trace_obj.data_name;
    end;
    etc_trace_obj.all_data_main_idx=1;
    etc_trace_obj.all_data_color(1,:)=cc(1,:);
    
    for idx=1:length(etc_trace_obj.aux_data)
        etc_trace_obj.all_data{idx+1}=etc_trace_obj.aux_data{idx};
        if(~isempty(etc_trace_obj.aux_data_name{idx}))
            etc_trace_obj.all_data_name{idx+1}=etc_trace_obj.aux_data_name{idx};
        end;
        %etc_trace_obj.all_data_color(idx+1,:)=cc(mod(length(etc_trace_obj.all_data)-1,7)+1,:);
        etc_trace_obj.all_data_color(idx+1,:)=cc(mod(idx-1,7)+1,:);
        etc_trace_obj.aux_data_color(idx,:)=etc_trace_obj.all_data_color(idx+1,:);
    end;    
    etc_trace_obj.all_data_aux_idx=cat(2,0,ones(1,length(etc_trace_obj.aux_data)));
    etc_trace_obj.aux_data_idx=find(etc_trace_obj.all_data_aux_idx);

end;

return;
