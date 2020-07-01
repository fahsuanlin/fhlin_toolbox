function []=etc_animgif(data,varargin)

filename=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'filename'
            filename=option_value;
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;    
end;

if(isempty(filename))
    filename = 'anim.gif';
end;

h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
for n = 1:size(data,3)
    imagesc(data(:,:,n));
    axis off image;
    etc_plotstyle;
    drawnow
    % Capture the plot as an image
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
end

return;