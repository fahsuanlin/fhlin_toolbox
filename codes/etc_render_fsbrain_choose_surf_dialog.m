function choice = choosedialog

global etc_render_fsbrain;

Items={};
if(isfield(etc_render_fsbrain,'surf_obj'))
    for f_idx=1:length(etc_render_fsbrain.surf_obj)
        [pp,ff]=fileparts(etc_render_fsbrain.surf_obj(f_idx).filename);
        Items{f_idx,1}=ff;
    end;
end;

d = dialog('Position',[300 300 250 150],'Name','Select One');
txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 210 40],...
    'String','Select a surface');

popup = uicontrol('Parent',d,...
    'Style','popup',...
    'Position',[75 70 100 25],...
    'String',Items,...
    'Callback',@popup_callback);

btn = uicontrol('Parent',d,...
    'Position',[89 20 70 25],...
    'String','Close',...
    'Callback','delete(gcf)');

%choice = 'Red';
choice=[];

% Wait for d to close before running to completion
uiwait(d);

    function popup_callback(popup,event)
        idx = popup.Value;
        popup_items = popup.String;
        %choice = char(popup_items(idx,:));
        choice=idx;
    end
end