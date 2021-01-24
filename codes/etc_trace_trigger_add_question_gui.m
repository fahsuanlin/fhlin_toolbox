function varargout = etc_trace_trigger_add_question_gui(varargin)
% ETC_TRACE_TRIGGER_ADD_QUESTION_GUI MATLAB code for etc_trace_trigger_add_question_gui.fig
%      ETC_TRACE_TRIGGER_ADD_QUESTION_GUI by itself, creates a new ETC_TRACE_TRIGGER_ADD_QUESTION_GUI or raises the
%      existing singleton*.
%
%      H = ETC_TRACE_TRIGGER_ADD_QUESTION_GUI returns the handle to a new ETC_TRACE_TRIGGER_ADD_QUESTION_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_TRIGGER_ADD_QUESTION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_TRIGGER_ADD_QUESTION_GUI.M with the given input arguments.
%
%      ETC_TRACE_TRIGGER_ADD_QUESTION_GUI('Property','Value',...) creates a new ETC_TRACE_TRIGGER_ADD_QUESTION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_trigger_add_question_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_trigger_add_question_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_trigger_add_question_gui

% Last Modified by GUIDE v2.5 19-Apr-2020 02:18:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_trigger_add_question_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_trigger_add_question_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before etc_trace_trigger_add_question_gui is made visible.
function etc_trace_trigger_add_question_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_trigger_add_question_gui (see VARARGIN)

% Choose default command line output for etc_trace_trigger_add_question_gui
handles.output = 'No';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:) = get(handles.figure_trigger_add_question, 'Color');
IconCMap=questIconMap;

% Img=image(IconData, 'Parent', handles.axes1);
% set(handles.figure_trigger_add_question, 'Colormap', IconCMap);
% 
% set(handles.axes1, ...
%     'Visible', 'off', ...
%     'YDir'   , 'reverse'       , ...
%     'XLim'   , get(Img,'XData'), ...
%     'YLim'   , get(Img,'YData')  ...
%     );

global etc_trace_obj;

set(handles.checkbox_trigger_ask_skip,'Value',0);




% Make the GUI modal
set(handles.figure_trigger_add_question,'WindowStyle','modal')

% UIWAIT makes etc_trace_trigger_add_question_gui wait for user response (see UIRESUME)
uiwait(handles.figure_trigger_add_question);

% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_trigger_add_question_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure_trigger_add_question);

% --- Executes on button press in pushbotton_trigger_ask_yes.
function pushbotton_trigger_ask_yes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbotton_trigger_ask_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure_trigger_add_question);

% --- Executes on button press in pushbotton_trigger_ask_no.
function pushbotton_trigger_ask_no_Callback(hObject, eventdata, handles)
% hObject    handle to pushbotton_trigger_ask_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure_trigger_add_question);


% --- Executes when user attempts to close figure_trigger_add_question.
function figure_trigger_add_question_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_trigger_add_question (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure_trigger_add_question with no controls selected.
function figure_trigger_add_question_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure_trigger_add_question (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure_trigger_add_question);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure_trigger_add_question);
end    


% --- Executes on button press in checkbox_trigger_ask_skip.
function checkbox_trigger_ask_skip_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_trigger_ask_skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_trigger_ask_skip

global etc_trace_obj;

etc_trace_obj.trigger_add_rightclick=get(hObject,'Value');
