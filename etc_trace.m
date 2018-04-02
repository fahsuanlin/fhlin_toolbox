function h=etc_trace(data,varargin)

fs=1; %sampling rate; Hz

ylim=[-100 100];
duration=5; %second
h=[];

trigger=[];

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
        case 'trigger'
            trigger=option_value;
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
 

etc_trace_obj.fs=fs;
etc_trace_obj.ylim=ylim;

etc_trace_obj.time_duration_idx=round(duration.*fs);
etc_trace_obj.time_begin_idx=1;
etc_trace_obj.time_end_idx=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx; 

etc_trace_obj.trigger=trigger;

etc_trace_obj.data=data;

etc_trace_obj.fig_trace=etc_trace_gui;

set(etc_trace_obj.fig_trace,'WindowButtonDownFcn','etc_trace_handle(''bd'')');
set(etc_trace_obj.fig_trace,'KeyPressFcn','etc_trace_handle(''kb'')');
set(etc_trace_obj.fig_trace,'invert','off');

etc_trace_handle('redraw');

return;
