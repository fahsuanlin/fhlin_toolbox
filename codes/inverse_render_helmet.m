function inverse_render_helmet(stc,varargin)


avi_output_file='';
quicktime_output_file='';
flag_interpolation=1;
flag_grid=1;	
flag_axis_label=0;
flag_sample_time=1;
sample_time=[1:size(stc,2)];
bg_weight=1;
sample_unit=[];
view_angle=[-90 0];
show_sample_time='on';
threshold=[];
stc_threshold=[0.90, 0.99]; % render the most active 10% of dipoles and make the most active 1% dioples as maximals.

render_window=1;
render_interval=[];

if(nargin>1)
    for i=1:length(varargin)/2
        option_name=varargin{(i-1)*2+1};	
        option_value=varargin{i*2};
        
        switch lower(option_name)
        case 'avi_output_file'
            avi_output_file=option_value;
        case 'quicktime_output_file'
            quicktime_output_file=option_value;
        case 'sample_time'
            sample_time=option_value;
        case 'sample_unit'
            sample_unit=option_value;
        case 'grid'
            if(strcmp(lower(option_value),'on'))
                flag_grid=1;
            else
                flag_grid=0;
            end;
        case 'show_sample_time'
            if(strcmp(lower(option_value),'on'))
                flag_sample_time=1;
            else
                flag_sample_time=0;
            end;
        case 'axis_label'
            if(strcmp(lower(option_value),'on'))
                flag_axis_label=1;
            else
                flag_axis_label=0;
            end;
        case 'render_interval'
            render_interval=option_value;
        case 'render_window'
            render_window=option_value;
        case 'view_angle'
            view_angle=option_value; 
        case 'threshold'
            threshold=option_value;
        case 'bg_weight'
            bg_weight=option_value;
        otherwise
            fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
            return;
        end;
    end;
end;

%automatic thresholding
if(isempty(threshold))
    ff=sort(reshape(stc,[1,prod(size(stc))]));
    threshold(1)=ff(floor(length(ff).*min(stc_threshold)));
    threshold(2)=ff(floor(length(ff).*max(stc_threshold)));
    fprintf('automatic thesholding between [%2.2f] and [%2.2f]\n',min(threshold),max(threshold));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparation of AVI output file
%
if(~isempty(avi_output_file))
    avi_mov = avifile(avi_output_file);
    avi_mov.FPS=4;
    avi_mov.Compression='none';
    avi_mov.Quality=100;
else
    avi_mov=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparation of AVI/Quicktime output file
%
if(~isempty(quicktime_output_file))
    makeqtmovie('start',quicktime_output_file);
    makeqtmovie('framerate',4);
    quicktime_mov=1;
else
    quicktime_mov=[];
end;




if(render_window~=1)
    if(render_window<1) %collapsing in seconds
        render_window=round(render_window./mean(diff(sample_time./1000.0)));
    end;
    
    if(isempty(render_interval))
        render_interval=[1:size(stc,2)];
    end;
    
    ss=[];
    for j=1:ceil(length(render_interval)/render_window)
        if(j*render_window<size(stc,2))
            ss(:,j)=mean(stc(:,(j-1)*render_window+1:j*render_window),2);
            sample_time(j)=mean(sample_time((j-1)*render_window+1:j*render_window));
        else
            ss(:,j)=mean(stc(:,(j-1)*render_window+1:end),2);
            sample_time(j)=mean(sample_time((j-1)*render_window+1:end));
        end;
    end;
    
else
    ss=stc;
end;
stc=ss;

for i=1:size(stc,2)
    fprintf('[%d/%d]...[%2.2f%%] completed!\n', i,size(stc,2),i./size(stc,2).*100.0);
    
    fg_data=stc(:,i);
    
    %	set(gcf,'DoubleBuffer','on');
    set(gcf,'DoubleBuffer','off');
    
    if(flag_grid)
        set(gca,'NextPlot','replace');
    else
        set(gca,'NextPlot','replace');
        set(gca,'Visible','off');
    end;
    
    set(gca,'NextPlot','replace');
    
    
    %render brain
    delete(gca);
    
    
    fprintf('max=[%3.3f] min=[%3.3f] threshold=[%3.3f, %3.3f]\n',max(fg_data),min(fg_data),min(threshold),max(threshold));
    

    if(iscell(view_angle))
        for v=1:length(view_angle)
            topohelmet(stc(:,i));
        
        
            % set view angle
            view(view_angle{v});
        end;
    else
        topohelmet(stc(:,i));
        view(view_angle);
    end;
    
    
    
    set(gcf,'visible','off');
    
    if(~flag_grid)
        set(gca,'Visible','off');
    end;
    
    %control the display of axis label
    if(~flag_axis_label)
        set(gca,'xticklabel',[]);
        set(gca,'yticklabel',[]);
        set(gca,'zticklabel',[]);
    end;		
    
    
    pos=get(gca,'pos');
    
    hax=axes('pos',pos);
    set(hax,'visible','off');
    
    % show timing
    if(flag_sample_time)
        %h=title(sprintf('%2.0f %s',sample_time(i),sample_unit));
        h=text(0,0.2,sprintf('%2.0f %s',sample_time(i),sample_unit));
        set(h,'color',[1 1 1]);
        set(h,'fontsize',12);
        set(h,'fontname','helvetica')
    end;
    
    
    
    % get frames into AVI file
    if(~isempty(avi_mov))
        set(gcf,'visible','on');
        F = getframe(gcf);
        set(gcf,'visible','off');
        avi_mov = addframe(avi_mov,F);
        
        file_image_output=sprintf('inverse_render_%s_%03d.tif',date,i);
        print('-dtiff',file_image_output);
    end;
    
    % get frames into Quicktime file
    if(~isempty(quicktime_mov))
        set(gcf,'visible','on');
        F = getframe(gcf);
        makeqtmovie('addfigure');
        
        file_image_output=sprintf('inverse_render_%s_%03d.tif',date,i);
        print('-dtiff',file_image_output);
    end;
    
    close(gcf);
end;


if(~isempty(avi_mov))
    fprintf('closing AVI file [%s]...\n',avi_output_file);
    avi_mov = close(avi_mov);
end;

if(~isempty(quicktime_mov))
    fprintf('closing QuickTime file [%s]...\n',quicktime_output_file);
    makeqtmovie('finish');
end;

return;
