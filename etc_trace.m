function h=etc_trace(data,varargin)

fs=1; %sampling rate; Hz

ylim=[-100 100];
ylim_single=[-100 100];
duration=5; %second
h=[];

trigger=[];
aux_data={};
ch_names={};

topo=[]; %topology structure; with "vertex", "face", "ch_names", "electrode_idx" 4 fields.
flag_mark=0;

select=[];
montage=[];
scaling=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'fs'
            fs=option_value;
        case 'ylim'
            ylim=option_value;
        case 'ylim_single'
            ylim_single=option_value;
        case 'duration'
            duration=option_value;
        case 'trigger'
            trigger=option_value;
        case 'ch_names'
            ch_names=option_value;
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
        otherwise
            fprintf('unkown option [%s]!\nerror!\n',option);
            return;
    end;
    
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%

global etc_trace_obj;

 try
    delete(etc_trace_obj.fig_trace);
 catch ME
 end;
 
 if(isempty(ch_names))
     for idx=1:size(data,1)
         ch_names{idx}=sprintf('%03d',idx);
     end;
 end;

etc_trace_obj.fs=fs;
etc_trace_obj.ylim=ylim;
etc_trace_obj.ylim_single=ylim_single;

etc_trace_obj.time_duration_idx=round(duration.*fs);
etc_trace_obj.time_begin_idx=1;
etc_trace_obj.time_end_idx=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx; 

etc_trace_obj.trigger=trigger;

etc_trace_obj.ch_names=ch_names;

if(isempty(montage))
    montage=eye(size(data,1));
    montage_name='orig';
    
    config={};
    for idx=1:length(etc_trace_obj.ch_names);
        %if(strcmp(lower(etc_trace_obj.ch_names{idx}),'ecg')|strcmp(lower(etc_trace_obj.ch_names{idx}),'ekg'))
        %else
            config{end+1,1}=etc_trace_obj.ch_names{idx};
            config{end,2}='';
        %end;
    end;
end;
etc_trace_obj.montage{1}.config_matrix=[montage, zeros(size(montage,1),1)
                       zeros(1,size(montage,2)), 1];
 etc_trace_obj.montage{1}.config=config;                  
etc_trace_obj.montage{1}.name=montage_name;        
etc_trace_obj.montage_idx=1;

if(isempty(select))
    select=eye(size(data,1));
    select_name='all';
end;
etc_trace_obj.select=[select, zeros(size(select,1),1)
                       zeros(1,size(select,2)), 1];
etc_trace_obj.select_name=select_name;        
                   
if(isempty(scaling))
    scaling{1}=eye(size(data,1));
else
    scaling{1}=scaling;
end;       
ecg_idx=find(strcmp(lower(etc_trace_obj.ch_names),'ecg')|strcmp(lower(etc_trace_obj.ch_names),'ekg'));
scaling{1}(ecg_idx,ecg_idx)=scaling{1}(ecg_idx,ecg_idx)./10;
etc_trace_obj.scaling{1}=[scaling{1}, zeros(size(scaling{1},1),1)
                       zeros(1,size(scaling{1},2)), 1];
                   
                   
etc_trace_obj.data=data;
etc_trace_obj.aux_data=aux_data;

etc_trace_obj.fig_trace=etc_trace_gui;

etc_trace_obj.topo=topo;

etc_trace_obj.flag_mark=flag_mark;

set(etc_trace_obj.fig_trace,'WindowButtonDownFcn','etc_trace_handle(''bd'')');
set(etc_trace_obj.fig_trace,'KeyPressFcn','etc_trace_handle(''kb'')');
set(etc_trace_obj.fig_trace,'invert','off');
set(etc_trace_obj.fig_trace,'Name','');
set(etc_trace_obj.fig_trace,'DeleteFcn','etc_trace_handle(''del'')');

etc_trace_obj.fig_topology=figure('visible','off');
delete(etc_trace_obj.fig_topology); %make it invalid
etc_trace_obj.fig_trigger=figure('visible','off');
delete(etc_trace_obj.fig_trigger); %make it invalid
etc_trace_obj.fig_montage=figure('visible','off');
delete(etc_trace_obj.fig_montage); %make it invalid

etc_trace_handle('redraw');

return;
