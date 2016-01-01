
% DrawFormattedTextDemo
%
% Draws lots of formatted text, shows how to center text vertically and/or
% horizontally, how line-breaks are introduced, how to compute text
% bounding boxes.
%
% Press any key to cycle through different demo displays.
%
% see also: PsychDemos, Screen DrawText?, DrawSomeTextDemo

% 10/16/06    mk     Wrote it.

try
    % Choosing the display with the highest display number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);

    % Open window with default settings:
    w=Screen('OpenWindow', screenNumber);

    % Select specific text font, style and size:
    Screen('TextFont',w, 'Courier New');
    Screen('TextSize',w, 14);
    Screen('TextStyle', w, 1+2);

    % Read some text file:
    fd = fopen([PsychtoolboxRoot 'Contents.m'], 'rt');
    if fd==-1
        error('Could not open Contents.m file in PTB root folder!');
    end
    
    mytext = '';
    tl = fgets(fd);
    lcount = 0;
    while lcount < 48
        mytext = [mytext tl]; %#ok<*AGROW>
        tl = fgets(fd);
        lcount = lcount + 1;
    end
    fclose(fd);
    mytext = [mytext char(10)];


    Screen('TextSize',w, 22);    
    winHeight = RectHeight(Screen('Rect', w));
    longtext = ['\n\nTeleprompter test: Press any key to continue.\n\n' mytext];
    longtext = repmat(longtext, 1, 3);

    tp=zeros(1, 2*winHeight + 1);
    sc = 0;

    % Render once, requesting the 'bbox' bounding box of the whole text.
    % This will disable clipping and be very sloooow, so we do it only once
    % to get the bounding box, and later just recycle that box:
    [nx, ny, bbox] = DrawFormattedText(w, longtext, 10, 0, 0);
    textHeight = RectHeight(bbox);
    
    for yp = winHeight:-1:-textHeight
        % Draw text again, this time with unlimited line length:
        [nx, ny] = DrawFormattedText(w, longtext, 10, yp, 0);
        Screen('FrameRect', w, 0, bbox);

        sc = sc + 1;
        tp(sc) = Screen('Flip', w);

        if KbCheck(-3)
            break;
        end
    end
    
    tp = tp(1:sc);
    fprintf('Average redraw duration for scrolling in msecs: %f\n', 1000 * mean(diff(tp)));
    close all;
    plot(1000 * diff(tp));
    title('Redraw duration per scroll frame [msecs]:');
    
    % End of demo, close window:
    Screen('CloseAll');
catch %#ok<*CTCH>
    % This "catch" section executes in case of an error in the "try"
    % section []
    % above.  Importantly, it closes the onscreen window if it's open.
    Screen('CloseAll');
    fclose('all');
    psychrethrow(psychlasterror);
end
