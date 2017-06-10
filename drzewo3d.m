function varargout = drzewo3d(varargin)
% DRZEWO3D MATLAB code for drzewo3d.fig
%      DRZEWO3D, by itself, creates a new DRZEWO3D or raises the existing
%      singleton*.
%
%      H = DRZEWO3D returns the handle to a new DRZEWO3D or the handle to
%      the existing singleton*.
%
%      DRZEWO3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRZEWO3D.M with the given input arguments.
%
%      DRZEWO3D('Property','Value',...) creates a new DRZEWO3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before drzewo3d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to drzewo3d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help drzewo3d

% Last Modified by GUIDE v2.5 10-Jun-2017 12:35:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @drzewo3d_OpeningFcn, ...
                   'gui_OutputFcn',  @drzewo3d_OutputFcn, ...
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


% --- Executes just before drzewo3d is made visible.
function drzewo3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to drzewo3d (see VARARGIN)

% Choose default command line output for drzewo3d
handles.output = hObject;
handles.amountOfPoints=1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes drzewo3d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = drzewo3d_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in btn_savePoint.
function btn_savePoint_Callback(hObject, eventdata, handles)
point = getappdata(0,'point');
handles.selectedPoints(:,handles.amountOfPoints) = point;
handles.amountOfPoints = handles.amountOfPoints +1;
cameratoolbar('Close');

scatter3(handles.model3d(:,1),handles.model3d(:,2),handles.model3d(:,3),'.', 'b');
hold on
scatter3(handles.selectedPoints(1,:), handles.selectedPoints(2,:), handles.selectedPoints(3,:), '*', 'r')
guidata(hObject, handles);

% --- Executes on button press in btn_CheckPoint.
function btn_CheckPoint_Callback(hObject, eventdata, handles)
handles.model3d = getappdata(0,'evalue');
h = clickA3DPoint(handles.model3d');
guidata(hObject, handles);

% --- Executes on button press in btn_Path.
function btn_Path_Callback(hObject, eventdata, handles)
% DT = delaunayTriangulation(x,y,z);

% --- Executes on button press in btn_SavePath.
function btn_SavePath_Callback(hObject, eventdata, handles)
% k = boundary(handles.selectedPoints(:,1), handles.selectedPoints(:,2));
% hold on;
% plot(handles.model3d(k,1),handles.model3d(k,2));
P = handles.model3d;
k = boundary(P,0);
j = boundary(P,1);
subplot(1,2,1);
plot3(P(:,1),P(:,2),P(:,3),'.','MarkerSize',10)
hold on
trisurf(k,P(:,1),P(:,2),P(:,3),'Facecolor','red','FaceAlpha',0.1)
axis equal