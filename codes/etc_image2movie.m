function etc_image2movie(image_sequence,varargin)
% etc_image2movie   convert image sequences into AVI/quicktime movie
%
% etc_image2movie(image_sequence, [option, option_value,....]);
%
% images_sequence: a cell of file name strings for each frame of the movie. 
% options:
%   avi_output_file (string) : output file stem for AVI file
%   mov_output_file (string) : output file stem for MOV file
%   crop_rect ([1xx4]): cropping rectangle for the image; an empty entry
%   will disable cropping
%   text_pos ([1:2]) : the position of the text ouptut for each frame
%   text_unit (string) : the unit of the text output for each frame
%
% fhlin@nov 27 2006
%

%%fstem='ini_inverse_3d_mne-lh-med';

%%avi_output_file='ini_inverse_3d_mne-lh-med';
avi_output_file='avi_movie';

%mov_output_file='ini_inverse_3d_mne-lh-med';
mov_output_file='mov_movie';

frame_rate=8; %frame/second

%crop_rect=[112 87  381  223];
crop_rect=[];

%text_pos=[27 1];
%text_unit='s';
text_pos=[];
text_unit='ms';
text_color=[0 1 1];

% n_skip_frame=20;
% 
% time0=0;     %s
% time=[4 11.8]; %s
% step=0.2;    %s

for i=1:length(varargin/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'avi_output_file'
            avi_output_file=option_value;
        case 'mov_output_file'
            mov_output_file=option_value;
        case 'frame_rate'
            frame_rate=option_value;
        case 'text_pos'
            text_pos=option_value;
        case 'text_unit'
            text_unit=option_value;
        case 'text_color'
            text_color=option_value;
        otherwise
            fprintf('unknown option [%s]\nerror!\n',option);
            return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timeVec=[min(time):step:max(time)];

if(~isempty(avi_output_file))
    avi_mov = avifile(sprintf('%s.avi',avi_output_file));
    avi_mov.FPS=frame_rate;
    if(ispc)
        avi_mov.compression='Indeo3';
    else
        avi_mov.compression='none';
    end;
    avi_mov.Quality=100;
else
    avi_mov=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparation of Quicktime output file
%
if(~isempty(mov_output_file))
    makeqtmovie('start',sprintf('%s.mov',mov_output_file));
    makeqtmovie('framerate',frame_rate);
    quicktime_mov=1;
else
    quicktime_mov=[];
end;

for idx=1:length(image_squence)    
    %load image
    fprintf('loading [%s]...\n',image_sequence{idx});
    d=imread(image_sequence{idx},'JPEG');
    
    
    %crop image;
    %%%%%imagesc(d);
    %%%%%[dummy,rect]=imcrop;
    if(~isempty(crop_rect));
        d=imcrop(d,crop_rect);
    end;
    
    %display the image;
    imagesc(d); axis off image;
    
    set(gca,'position',[0 0 1 1]);
    set(gcf,'color','k');   

    %display comment
    tt=sprintf('%0.1f %s',timeVec(idx),text_unit);
    if(~isempty(text_pos))
        g=text(text_pos(1),text_pos(2),tt);
        set(g,'fontname','helveltica','fontsize',16,'color',text_color);
    end;
    
  
    % get frames into AVI file
    if(~isempty(avi_mov))
        set(gcf,'visible','on');
        F = getframe(gcf);
        set(gcf,'visible','off');
        avi_mov = addframe(avi_mov,F);
    end;
    
    % get frames into Quicktime file
    if(~isempty(quicktime_mov))
        set(gcf,'visible','on');
        F = getframe(gcf);
        makeqtmovie('addfigure');
    end;
    
    close(gcf);
    
end;


if(~isempty(avi_mov))
    fprintf('closing AVI file [%s]...\n',avi_output_file);
    avi_mov = close(avi_mov);
end;

if(~isempty(quicktime_mov))
    fprintf('closing QuickTime file [%s]...\n',mov_output_file);
    makeqtmovie('finish');
end;
