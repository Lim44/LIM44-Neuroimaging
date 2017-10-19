function varargout = guiStroop(varargin)
% GUISTROOP MATLAB code for guiStroop.fig
%      GUISTROOP, by itself, creates a new GUISTROOP or raises the existing
%      singleton*.
%
%      H = GUISTROOP returns the handle to a new GUISTROOP or the handle to
%      the existing singleton*.
%
%      GUISTROOP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUISTROOP.M with the given input arguments.
%
%      GUISTROOP('Property','Value',...) creates a new GUISTROOP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guiStroop_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guiStroop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guiStroop

% Last Modified by GUIDE v2.5 13-Oct-2017 20:31:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiStroop_OpeningFcn, ...
                   'gui_OutputFcn',  @guiStroop_OutputFcn, ...
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


% --- Executes just before guiStroop is made visible.
function guiStroop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guiStroop (see VARARGIN)

% Choose default command line output for guiStroop
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guiStroop wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guiStroop_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.participants_id,'String');

if get(handles.training,'value') == 1
    varargout{2} = 'training';
elseif get(handles.experiment,'value') == 1
    varargout{2} = 'experiment';
end

% The figure can be deleted now
delete(handles.figure1);


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes on button press in training.
function training_Callback(hObject, eventdata, handles)
% hObject    handle to training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of training

off = [handles.experiment];
mutual_exclude(off);


handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in experiment.
function experiment_Callback(hObject, eventdata, handles)
% hObject    handle to experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of experiment

off = [handles.training];
mutual_exclude(off);

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% ======== SUB FUNCTIONS ==============%
function mutual_exclude(off)
set(off,'Value',0)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end     


function participants_id_Callback(hObject, eventdata, handles)
% hObject    handle to participants_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of participants_id as text
%        str2double(get(hObject,'String')) returns contents of participants_id as a double


% --- Executes during object creation, after setting all properties.
function participants_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to participants_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
