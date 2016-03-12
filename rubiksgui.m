function varargout = rubiksgui(varargin)
% RUBIKSGUI MATLAB code for rubiksgui.fig
%      RUBIKSGUI, by itself, creates a new RUBIKSGUI or raises the existing
%      singleton*.
%
%      H = RUBIKSGUI returns the handle to a new RUBIKSGUI or the handle to
%      the existing singleton*.
%
%      RUBIKSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUBIKSGUI.M with the given input arguments.
%
%      RUBIKSGUI('Property','Value',...) creates a new RUBIKSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rubiksgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rubiksgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rubiksgui

% Last Modified by GUIDE v2.5 24-Nov-2015 00:11:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rubiksgui_OpeningFcn, ...
                   'gui_OutputFcn',  @rubiksgui_OutputFcn, ...
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


% --- Executes just before rubiksgui is made visible.
function rubiksgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rubiksgui (see VARARGIN)

% Choose default command line output for rubiksgui
rc = RubiksCube;
rc.randomize();
handles.mainCube = rc;
handles.counter = 1;
handles.stop = false;

axes(handles.cube1), rotate3d on;
handles.mainCube.plotRubiksCube();

axes(handles.cube2), rotate3d on;
handles.mainCube.plotRubiksCube();

handles.rcs = RubiksCubeSolver(rc, handles);
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes rubiksgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rubiksgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on stop press in stop.
function stop_Callback(hObject, eventdata, handles)
% hObject    handle to stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   handles.stop = true;
   guidata(hObject, handles);

% --- Executes on stop press in rand.
function rand_Callback(hObject, eventdata, handles)
% hObject    handle to rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.mainCube.randomize();
    
    axes(handles.cube1), handles.mainCube.plotRubiksCube();
    axes(handles.cube2), handles.mainCube.plotRubiksCube();
    
function guiLog(string, handles)
    data = get(handles.listbox1,'String');
    data = [data; cellstr(string)];
    set(handles.listbox1,'String',data);
    set(handles.listbox1,'Value', length(data));


% --- Executes on button press in solve.
function solve_Callback(hObject, eventdata, handles)
% hObject    handle to solve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input = str2double(get(handles.edit,'String'));
if ~isempty(input)
    guiLog('Solving... ', handles);
    for i = 1:input
        if handles.stop, break, end
        guiLog(['Generation ' num2str(handles.counter)], handles);
        [population, cube1, cube2] = handles.rcs.simulateGeneration();
        handles.rcs.population = population;
        axes(handles.cube1), cube1.plotRubiksCube();
        axes(handles.cube2), cube2.plotRubiksCube();
        handles.counter = handles.counter + 1;
        guidata(hObject, handles);
        drawnow;
    end
end

% --- Executes on button press in rotate.
function rotate_Callback(hObject, eventdata, handles)
% hObject    handle to rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    for i = 1:89
        axes(handles.cube1), view(45+i, 20);
        axes(handles.cube2), view(45+i, 20);
        pause(0.1);
    end


function edit_Callback(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit as text
%        str2double(get(hObject,'String')) returns contents of edit as a double


% --- Executes during object creation, after setting all properties.
function edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
