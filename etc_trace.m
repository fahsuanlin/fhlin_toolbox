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
        case 'montage'
            montage=option_value;
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
end;
etc_trace_obj.montage=[montage, zeros(size(montage,1),1)
                       zeros(1,size(montage,2)), 1];
                   
if(isempty(scaling))
    scaling=eye(size(data,1));
end;                   
etc_trace_obj.scaling=[scaling, zeros(size(scaling,1),1)
                       zeros(1,size(scaling,2)), 1];
etc_trace_obj.data=data;
etc_trace_obj.aux_data=aux_data;

etc_trace_obj.fig_trace=etc_trace_gui;

etc_trace_obj.topo=topo;

etc_trace_obj.flag_mark=flag_mark;

set(etc_trace_obj.fig_trace,'WindowButtonDownFcn','etc_trace_handle(''bd'')');
set(etc_trace_obj.fig_trace,'KeyPressFcn','etc_trace_handle(''kb'')');
set(etc_trace_obj.fig_trace,'invert','off');

etc_trace_handle('redraw');

return;
