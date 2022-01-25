function varargout = ssuat(varargin)
% SSUAT MATLAB code for ssuat.fig
%      SSUAT, by itself, creates a new SSUAT or raises the existing
%      singleton*.
%
%      H = SSUAT returns the handle to a new SSUAT or the handle to
%      the existing singleton*.
%
%      SSUAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SSUAT.M with the given input arguments.
%
%      SSUAT('Property','Value',...) creates a new SSUAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ssuat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ssuat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ssuat

% Last Modified by GUIDE v2.5 25-Jan-2022 10:23:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ssuat_OpeningFcn, ...
                   'gui_OutputFcn',  @ssuat_OutputFcn, ...
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


% --- Executes just before ssuat is made visible.
function ssuat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ssuat (see VARARGIN)

% Choose default command line output for ssuat
handles.output = hObject;
handles.txt_info.FontName='FreeMono';

mn = get(handles.sl_coarse, 'Min');
mx = get(handles.sl_coarse, 'Max');
set(handles.sl_coarse, 'SliderStep', [.01 .1] / (mx - mn));

mn = get(handles.sl_fine, 'Min');
mx = get(handles.sl_fine, 'Max');
set(handles.sl_fine, 'SliderStep', [ .005 .1] / (mx - mn));

mn = get(handles.sl_phase, 'Min');
mx = get(handles.sl_phase, 'Max');
set(handles.sl_phase, 'SliderStep', [1 10] / (mx - mn));

vars = evalin('base','who');
set(handles.pm_data,'String',vars);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ssuat wait for user response (see UIRESUME)
% uiwait(handles.ssuat);


% --- Outputs from this function are returned to the command line.
function varargout = ssuat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function myplot(handles)

data = handles.data;
data = data(:);
if min(size(data)) > 1
    return
end

fs = 8.333333333;
p = get(handles.sl_phase, 'Value' );
c = exp(1j*pi/180*p);
%f = -1;
f = get(handles.sl_coarse, 'Value' ) + .01*get(handles.sl_fine, 'Value' );
lo = cexp(f/fs, size(data));
bb = c * lo .* data;

[p_rf,f_rf] = spec(data, fs);
[p_bb,f_bb] = spec(bb, fs);

plot(handles.axes1, real(data));
plot(handles.axes2, f_rf, db(p_rf));
handles.axes2.XLim = [-fs fs]*.5; 

%cla(handles.axes3);
%hold(handles.axes3, 'on');
plot(handles.axes3, real(bb),'b*-');
plot(handles.axes5, imag(bb),'r*-');

plot(handles.axes4, f_bb, db(p_bb));
handles.axes4.XLim = [-fs fs]*.5; 

% FFT
N_s = floor(numel(bb)/8);
specgram = zeros(8,N_s);
for s = 1:N_s
    st = (s-1)*8+1;
    ed = st + 7;
    specgram(:,s) = db(abs(spec(bb(st:ed))));
end

image(handles.axes6, specgram);


s = get(handles.txt_info, 'String');
s{1} = ['f  : '  num2str(f) ];
s{2} = ['c  : '  num2str(p) ];

idx_lo = floor(numel(p_bb)/2);
e_lo = db(sum(p_bb(1:idx_lo)));
e_hi = db(sum(p_bb(idx_lo+1:end)));
s{3} = ['e_lo  : '  num2str(e_lo) ];
s{4} = ['e_hi  : '  num2str(e_hi) ];

set(handles.txt_info, 'String', s );



% --- Executes on selection change in pm_data.
function pm_data_Callback(hObject, eventdata, handles)
% hObject    handle to pm_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_data
contents = cellstr(get(hObject,'String'));
name = contents{get(hObject,'Value')};
handles.data = evalin('base', name);
guidata(hObject, handles);

vars = evalin('base','who');
set(handles.pm_data,'String',vars);

myplot(handles);

% --- Executes during object creation, after setting all properties.
function pm_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sl_coarse_Callback(hObject, eventdata, handles)
% hObject    handle to sl_coarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_coarse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_coarse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sl_fine_Callback(hObject, eventdata, handles)
% hObject    handle to sl_fine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_fine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_fine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sl_phase_Callback(hObject, eventdata, handles)
% hObject    handle to sl_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
myplot(handles);


% --- Executes during object creation, after setting all properties.
function sl_phase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sl_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
