function varargout = ZSPD_Projekt(varargin)
% ZSPD_PROJEKT MATLAB code for ZSPD_Projekt.fig
%      ZSPD_PROJEKT, by itself, creates a new ZSPD_PROJEKT or raises the existing
%      singleton*.
%
%      H = ZSPD_PROJEKT returns the handle to a new ZSPD_PROJEKT or the handle to
%      the existing singleton*.
%
%      ZSPD_PROJEKT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZSPD_PROJEKT.M with the given input arguments.
%
%      ZSPD_PROJEKT('Property','Value',...) creates a new ZSPD_PROJEKT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ZSPD_Projekt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ZSPD_Projekt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ZSPD_Projekt

% Last Modified by GUIDE v2.5 08-Feb-2017 08:57:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ZSPD_Projekt_OpeningFcn, ...
                   'gui_OutputFcn',  @ZSPD_Projekt_OutputFcn, ...
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


% --- Executes just before ZSPD_Projekt is made visible.
function ZSPD_Projekt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ZSPD_Projekt (see VARARGIN)

% Choose default command line output for ZSPD_Projekt
handles.output = hObject;

%set(handles.axes_segment,'visible','off'); %hide the current axes
%set(get(handles.axes_segment,'children'),'visible','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ZSPD_Projekt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ZSPD_Projekt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_wczytaj_obrazy.
function button_wczytaj_obrazy_Callback(hObject, eventdata, handles)
% hObject    handle to button_wczytaj_obrazy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% wczytanie obrazów
global images;
global voxelSpace;
images = [];
dirImages = uigetdir;

imagefiles = dir(dirImages);
% wyrzucenie dwóch ('..' i '.')
filesLength = length(imagefiles) - 2;

for i = 1 : filesLength
   fileName = strcat(dirImages, '\image_', num2str(i-1));
   images(:,:,i) = dicomread(fileName);
end

dcmInfo = dicominfo(fileName);
voxelSpace = dcmInfo.PixelSpacing(1) * dcmInfo.PixelSpacing(2) * dcmInfo.SliceThickness

imshow(mat2gray(images(:,:,1)),'Parent', handles.axes_obrazy);

set(handles.slider_obrazy, 'Min', 1);
set(handles.slider_obrazy, 'Max', filesLength);
set(handles.slider_obrazy, 'Value', 1);




% --- Executes on button press in button_wczytaj_maski.
function button_wczytaj_maski_Callback(hObject, eventdata, handles)
% hObject    handle to button_wczytaj_maski (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global images;
global masks;
global skeletons;
global liver;
masks = [];
liver = [];
dirMasks = uigetdir;

masksFiles = dir(dirMasks);
% wyrzucenie dwóch ('..' i '.')
masksLength = length(masksFiles) - 2;

for i = 1 : masksLength
   fileName = strcat(dirMasks, '\image_', num2str(i-1));
   masks(:,:,i) = logical(dicomread(fileName));
end

for i = 1 : masksLength
   liver(:,:,i) =  masks(:,:,i).*images(:,:,i); 
end

%imshow(masks(:,:,1),'Parent', handles.axes_maski);

set(handles.slider_obrazy, 'Min', 1);
set(handles.slider_obrazy, 'Max', masksLength);
set(handles.slider_obrazy, 'Value', 1);
%set(handles.checkbox_szkielet, 'Value', 0);

skeletons = [];



% --- Executes on button press in button_szkieletyzacja.
function button_szkieletyzacja_Callback(hObject, eventdata, handles)
% hObject    handle to button_szkieletyzacja (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global skeletons;
global masks;
skeletons = [];
%skeletons = bwmorph(logical(masks),'skel');

masksSize = size(masks);

for i = 1 : masksSize(3)
   skel =  bwmorph(logical(masks(:,:,i)), 'skel', 'Inf');
   skeletons(:,:,i) = skel;
end

%set(handles.checkbox_szkielet, 'Value', 1);

imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))
%imshow(skeletons(:,:,imageNumberSelected), 'Parent', handles.axes_maski);





% --- Executes on slider movement.
function slider_obrazy_Callback(hObject, eventdata, handles)
% hObject    handle to slider_obrazy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global images;
global masks;
global skeletons;
global liver;
global naczynia_watroba;
imageNumberSelected = int32(get(hObject, 'Value'))
%imshow(mat2gray(images(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);

%checkBoxValue = get(handles.checkbox_szkielet, 'Value');
checkBoxValueLiver = get(handles.checkbox_watroba, 'Value');
checkBoxValueVessels = get(handles.checkbox_naczynia, 'Value');

%if checkBoxValue == 0
%    imshow(masks(:,:,imageNumberSelected), 'Parent', handles.axes_maski);
%else
%    imshow(skeletons(:,:,imageNumberSelected), 'Parent', handles.axes_maski);
%end

if checkBoxValueLiver == 0
    imshow(mat2gray(images(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);
else
    imshow(mat2gray(liver(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);
end


if checkBoxValueVessels == 1
    [row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);
    %imshow(mat2gray(liver(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);
    hold(handles.axes_obrazy, 'on');
    %set(handles.checkbox_naczynia,'Value','1');
    %hold all;
    plot(col, row, 'r.', 'Parent', handles.axes_obrazy); 
end


% --- Executes during object creation, after setting all properties.
function slider_obrazy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_obrazy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_szkielet.
function checkbox_szkielet_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_szkielet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_szkielet
global masks;
global skeletons;

imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))

checkBoxValue = get(hObject, 'Value');

%if checkBoxValue == 0
%    imshow(masks(:,:,imageNumberSelected), 'Parent', handles.axes_maski);
%else
%    imshow(skeletons(:,:,imageNumberSelected), 'Parent', handles.axes_maski);
%end


% --- Executes on button press in checkbox_watroba.
function checkbox_watroba_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_watroba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_watroba
global liver;
global images;

imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))

checkBoxValue = get(hObject, 'Value');

if checkBoxValue == 0
    imshow(mat2gray(images(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);
else
    imshow(mat2gray(liver(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);
end


% --- Executes on button press in button_maski_naczyn.
function button_maski_naczyn_Callback(hObject, eventdata, handles)
% hObject    handle to button_maski_naczyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global naczynia;
global naczynia_watroba;
global liver;

dirMasks = uigetdir;
masksFiles = dir(dirMasks);
% wyrzucenie dwóch ('..' i '.')
masksLength = length(masksFiles) - 2;

for i = 1 : masksLength
   fileName = strcat(dirMasks, '\image_', num2str(i-1));
   naczynia(:,:,i) = logical(dicomread(fileName));
end

naczynia = Skeleton3D(naczynia);

for i = 1 : masksLength
   naczynia_watroba(:,:,i) = liver(:,:,i).*naczynia(:,:,i);
   % =  cat(3, obraz, obraz, obraz);
end

imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))
[row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);
imshow(mat2gray(liver(:,:,imageNumberSelected)), 'Parent', handles.axes_obrazy);
hold(handles.axes_obrazy, 'on');
set(handles.checkbox_naczynia,'Value',1);
%hold all;
plot(col, row, 'r.', 'Parent', handles.axes_obrazy);

uiwait(msgbox('Szkieletyzacja naczyñ zakoñczona'));



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global segmenty;
global voxelSpace;

listboxSelected = get(hObject,'Value');
list = get(hObject,'String');
itemSelected = list{listboxSelected};

maski = getfield(segmenty, itemSelected);

objetosc = sum(sum(sum(maski>0))) * voxelSpace;
set(handles.text_objetosc, 'String', ['Objêtoœæ: ', num2str(objetosc), ' mm^3']);

set(handles.slider_segment, 'Value', 1);




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


% --- Executes on button press in checkbox_naczynia.
function checkbox_naczynia_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_naczynia (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_naczynia


% --- Executes on button press in button_plaszczyzna1.
function button_plaszczyzna1_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plaszczyzna1;
imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))
plaszczyzna1 = imageNumberSelected;
set(handles.text_plaszczyzna1, 'String', ['P³aszczyzna pozioma I - przekrój numer: ' num2str(plaszczyzna1)]);



% --- Executes on button press in button_plaszczyzna2.
function button_plaszczyzna2_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plaszczyzna2;
imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))
plaszczyzna2 = imageNumberSelected;
set(handles.text_plaszczyzna2, 'String', ['P³aszczyzna pozioma II - przekrój numer: ' num2str(plaszczyzna2)]);


% --- Executes on button press in button_plaszczyzna_pionowa1.
function button_plaszczyzna_pionowa1_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maskaPlaszczyzna1;
%global naczynia_watroba;
%global liver;

%imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'))

obraz = getimage(handles.axes_obrazy);
uiwait(msgbox('Zaznacz segment'));

maskaPlaszczyzna1 = roipoly(obraz);

set(handles.text_pionowa1, 'String', 'P³aszczyzna pionowa I - ok');


% --- Executes on button press in button_plaszczyzna_pionowa2.
function button_plaszczyzna_pionowa2_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maskaPlaszczyzna2;
%global naczynia_watroba;
%global liver;

%imageNumberSelected = int32(get(handles.slider_obrazy, 'Value'));

%obraz = getimage(handles.axes_obrazy);
uiwait(msgbox('Zaznacz segment'));
obraz = getimage(handles.axes_obrazy);
maskaPlaszczyzna2 = roipoly(obraz);

set(handles.text_pionowa2, 'String', 'P³aszczyzna pionowa II - ok');

% --- Executes on button press in button_plaszczyzna_pionowa3.
function button_plaszczyzna_pionowa3_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%global xPlaszyczna3;
%global yPlaszczyzna3;
%uiwait(msgbox('Zaznacz 3 punkty na obrazie'));
%[xPlaszyczna3,yPlaszczyzna3] = ginput(3);
%hold(handles.axes_obrazy, 'on');
global maskaPlaszczyzna3;

uiwait(msgbox('Zaznacz segment'));
obraz = getimage(handles.axes_obrazy);
maskaPlaszczyzna3 = roipoly(obraz);

set(handles.text_pionowa3, 'String', 'P³aszczyzna pionowa III - ok');


% --- Executes on button press in button_generate.
function button_generate_Callback(hObject, eventdata, handles)
% hObject    handle to button_generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global liver;
global plaszczyzna1;
%global plaszczyzna2;
global maskaPlaszczyzna4;
global maskaPlaszczyzna3;
global maskaPlaszczyzna2;
global maskaPlaszczyzna1;
global segmenty;
global images;
global voxelSpace;

liverSize = size(liver);
liverLength = liverSize(3);

for i = 1 : liverLength
   %naczynia_watroba(:,:,i) = liver(:,:,i).*naczynia(:,:,i);
   % =  cat(3, obraz, obraz, obraz);
   if(i<plaszczyzna1)
       segment1(:,:,i) = liver(:,:,i).*maskaPlaszczyzna1;
       segment2(:,:,i) = liver(:,:,i).*maskaPlaszczyzna2;
       segment3(:,:,i) = liver(:,:,i).*maskaPlaszczyzna3;
       segment4(:,:,i) = liver(:,:,i).*maskaPlaszczyzna4;
   else
       segment1(:,:,i) = zeros(liverSize(1), liverSize(2));
       segment2(:,:,i) = zeros(liverSize(1), liverSize(2));
       segment3(:,:,i) = zeros(liverSize(1), liverSize(2));
       segment4(:,:,i) = zeros(liverSize(1), liverSize(2));
   end
   
   if(i>=plaszczyzna1)
       segment5(:,:,i) = liver(:,:,i).*maskaPlaszczyzna1;
       segment6(:,:,i) = liver(:,:,i).*maskaPlaszczyzna2;
       segment7(:,:,i) = liver(:,:,i).*maskaPlaszczyzna3;
       segment8(:,:,i) = liver(:,:,i).*maskaPlaszczyzna4;
   else
       segment5(:,:,i) = zeros(liverSize(1), liverSize(2));
       segment6(:,:,i) = zeros(liverSize(1), liverSize(2));
       segment7(:,:,i) = zeros(liverSize(1), liverSize(2));
       segment8(:,:,i) = zeros(liverSize(1), liverSize(2));

   end
   
%    if(i>=plaszczyzna2)
%        segment7(:,:,i) = liver(:,:,i).*maskaPlaszczyzna1;
%        segment8(:,:,i) = liver(:,:,i).*maskaPlaszczyzna2;
%        segment9(:,:,i) = liver(:,:,i).*maskaPlaszczyzna3;
%    else
%        segment7(:,:,i) = zeros(liverSize(1), liverSize(2));
%        segment8(:,:,i) = zeros(liverSize(1), liverSize(2));
%        segment9(:,:,i) = zeros(liverSize(1), liverSize(2));
%    end
%        
   
end

%seg = [segment1, segment2, segment3, segment4, segment5, segment6, segment7, segment8, segment9];

%for j=1:9
%   nazwa = strcat('segment', num2str(j));
%   segmenty.(nazwa) = seg(:,:,j);
%end
segmenty = struct();

segmenty.('segment1') = segment1;
segmenty.('segment2') = segment2;
segmenty.('segment3') = segment3;
segmenty.('segment4') = segment4;
segmenty.('segment5') = segment5;
segmenty.('segment6') = segment6;
segmenty.('segment7') = segment7;
segmenty.('segment8') = segment8;
%segmenty.('segment9') = segment9;

set(handles.slider_segment, 'Min', 1);
set(handles.slider_segment, 'Max', liverLength);
set(handles.slider_segment, 'Value', 1);

cla(handles.axes_segment);

obraz =  segment1(:,:,1).*images(:,:,1);
imshow(mat2gray(obraz), 'Parent', handles.axes_segment);

objetosc = sum(sum(sum(segment1>0))) * voxelSpace;
set(handles.text_objetosc, 'String', ['Objêtoœæ: ', num2str(objetosc), ' mm^3']);


set(handles.listbox1,'Visible','on');
set(handles.listbox1,'string',fieldnames(segmenty));


guidata(hObject, handles);





%a = plot(xPlaszyczna1, yPlaszczyzna3,'Color','b','LineWidth',2);
%dlugosc = xPlaszyczna3(3) - xPlaszyczna3(1);
%wektor = int32(xPlaszyczna1(1)):1:int32(xPlaszyczna1(3));
%interpolacja = interp1(xPlaszyczna1,yPlaszyczna1, wektor, 'spline');
%maska = 


% --- Executes on slider movement.
function slider_segment_Callback(hObject, eventdata, handles)
% hObject    handle to slider_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global segmenty;
global images;

listboxSelected = get(handles.listbox1,'Value');
list = get(handles.listbox1,'String');
itemSelected = list{listboxSelected};

imageNumberSelected = int32(get(handles.slider_segment, 'Value'));

maski = getfield(segmenty, itemSelected);

obraz = images(:,:,imageNumberSelected).*maski(:,:,imageNumberSelected);
imshow(mat2gray(obraz), 'Parent', handles.axes_segment);


% --- Executes during object creation, after setting all properties.
function slider_segment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_segment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in button_3d.
function button_3d_Callback(hObject, eventdata, handles)
% hObject    handle to button_3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global segmenty;
global images;

listboxSelected = get(handles.listbox1,'Value');
list = get(handles.listbox1,'String');
itemSelected = list{listboxSelected};

sekwencja = getfield(segmenty, itemSelected);

okno = figure;
p=patch(isosurface(sekwencja,9));
reducepatch(p, .5)
set(p,'facecolor',[1,1,1],'edgecolor','none');
set(handles.axes_segment,'projection','perspective')
box on
light('position',[1,1,1])
light('position',[-1,-1,-1])

%scale in the z direcion to compensate
%for slice thickness
zscale=.5
daspect([1,1,zscale])
axis on
set(gcf,'color',[1,1,1]*.8)
set(gcf,'xlim',[0 250], 'ylim',[0 250])

az=0;
el=0;
view(az,el)


% --- Executes on button press in button_plaszczyzna_pionowa_4.
function button_plaszczyzna_pionowa_4_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maskaPlaszczyzna4;

uiwait(msgbox('Zaznacz segment'));
obraz = getimage(handles.axes_obrazy);
maskaPlaszczyzna4 = roipoly(obraz);

set(handles.text_pionowa_4, 'String', 'P³aszczyzna pionowa IV - ok');
