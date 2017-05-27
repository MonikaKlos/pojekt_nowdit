function varargout = tetniaki(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tetniaki_OpeningFcn, ...
                   'gui_OutputFcn',  @tetniaki_OutputFcn, ...
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

function tetniaki_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for tetniaki
handles.output = hObject;
handles.segm = 0;
handles.prog = 0;
% Update handles structure
guidata(hObject, handles);

function varargout = tetniaki_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function btnWczytaj_Callback(hObject, eventdata, handles)
%wczytanie
nazwa_pliku = uigetfile('*.mhd');
[img info] = read_mhd(nazwa_pliku);
handles.img_mhd = img;
handles.Im = img.data;
handles.Info = info;
guidata(hObject, handles);
%ustawienie wielkoœci slidera
set(handles.slider, 'MAX',size(handles.Im,3));
%set(handles.slide_slider, 'MIN',1);
handles.segm = 0;
%wyœwietlenie
axes(handles.axObraz);
handles.ktory_obraz = 1;
guidata(hObject, handles);
imshow(handles.Im(:,:,handles.ktory_obraz), []);
guidata(hObject, handles);

% --- Executes on button press in btnProgowanie.
function btnProgowanie_Callback(hObject, eventdata, handles)
prog1 = str2num(get(handles.etLow, 'String'));
prog2 = str2num(get(handles.etHigh, 'String'));
progowanie3D = zeros(size(handles.Im));
for i=1:size(handles.Im,3)
    im = handles.Im(:,:,i);
    prog = Progowanie(im, prog1, prog2);
    progowanie3D(:,:,i) =prog;
end
handles.Progowanie3D = progowanie3D;
guidata(hObject, handles);
handles.prog =1;
%wyœwietlenie
axes(handles.axObraz);
imshow(handles.Progowanie3D(:,:,handles.ktory_obraz));


function etLow_Callback(hObject, eventdata, handles)
function etLow_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function etHigh_Callback(hObject, eventdata, handles)
function etHigh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function btnLupa_Callback(hObject, eventdata, handles)
figure();
I = handles.Im(:,:,handles.ktory_obraz);
I2 = imcrop(I,[]);
imshow(I2,[]);

% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)

global images;
global masks;
global skeletons;
global liver;
global naczynia_watroba;

ktory = round(get(hObject,'Value'));

checkBoxValueLiver = get(handles.checkbox_watroba, 'Value');

if checkBoxValueLiver == 0

if(ktory~=0)
    handles.ktory_obraz = ktory;
    guidata(hObject, handles);
    set(handles.tNumer, 'String', handles.ktory_obraz);
    axes(handles.axObraz);
    imshow(handles.Im(:,:,handles.ktory_obraz),[]);
    
    %wyœwietlenie wyniku
    if(handles.segm ==1)
        axes(handles.axObraz);
        imshow(handles.Szkieletyzacja3D(:,:,handles.ktory_obraz));
        %imshow(handles.skiel(:,:,ktory));
    
    else(handles.prog == 1)
        axes(handles.axObraz);
        imshow(handles.Progowanie3D(:,:,handles.ktory_obraz));
    end
end

else
    axes(handles.axObraz);
    imshow(mat2gray(images(:,:,ktory)));
    
    if ~isempty(naczynia_watroba)
        [row,col] = find(naczynia_watroba(:,:,ktory)>0);

        watroba = liver(:,:,ktory);
        for i = 1:numel(row)
            watroba(row(i), col(i)) = 1024;
        end

        %imshow(mat2gray(liver(:,:,imageNumberSelected)), 'Parent', handles.axObraz);
        %hold(handles.axObraz, 'on');
        %set(handles.checkbox_naczynia,'Value',1);
        %hold all;
        %plot(col, row, 'r.', 'Parent', handles.axObraz);
        %hold of;

        imshow(mat2gray(watroba), 'Parent', handles.axObraz);
    end
end

guidata(hObject, handles);
function slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in btnMaski.
function btnMaski_Callback(hObject, eventdata, handles)
%% TODO
%wczytaj maske
% nazwa_pliku = uigetfile('*.mhd');
% [img info] = read_mhd(nazwa_pliku);
% handles.maska = img.data;
% handles.InfoMaski = info;
% guidata(hObject, handles);

maska1 = handles.Szkieletyzacja3D;
maska2 = handles.Szkieletyzacja3D;
%maska2 = handles.maska;
if(size(maska1,1) == size(maska2,1) && size(maska1,2) == size(maska2,2) && size(maska1,3) == size(maska2,3))
   %policz dice
   dice = DICE(maska1, maska2);
   set(handles.tDice, 'String', strcat('Wspó³czynnik DICE wynosi: ', int2str(dice)));
else
     set(handles.tDice, 'String', 'Maski musz¹ mieæ te same wymiary');
end

% --- Executes on button press in btnSzkieletyzacja1.
function btnSzkieletyzacja1_Callback(hObject, eventdata, handles)
%% gotowa (z internetu) szkieletyzacja
szkielet = Skeleton3D(logical(handles.Progowanie3D)); %szkieletyzacja

%[A,node,link] = Skel2Graph3D(handles.Progowanie3D,300);
% szkieletyzacja3D = zeros(size(handles.Im));
% for i=1:size(handles.Im,3)
%     im = handles.Im(:,:,i);
%     [prog, skel] = Segmentacja(im);
%     szkieletyzacja3D(:,:,i) =skel;
% end
handles.Szkieletyzacja3D = szkielet;
handles.segm = 1;
guidata(hObject, handles);
axes(handles.axObraz);
imshow(handles.Szkieletyzacja3D(:,:,handles.ktory_obraz));

% --- Executes on button press in btn3Dmodel.
function btn3Dmodel_Callback(hObject, eventdata, handles)
% przeliczenie wolksela na milimetry
dx = handles.Info.PixelDimensions(1);
dy = handles.Info.PixelDimensions(2);
dz = handles.Info.PixelDimensions(3);
%stworzenie modelu 3D
model3D = [0 0 0];
for i=1:size(handles.Szkieletyzacja3D,3)
    [nowy_x, nowy_y] = VoxelsToMilimeters(handles.Szkieletyzacja3D(:,:,i), dx, dy, dz); %znalezienie x y dla danego przekroju
    zi = 1:size(nowy_x,1);
    zi(:) = i;
    zi=zi';
    macierz = [nowy_x, nowy_y, zi*dz]; %dodanie kolumny z numerem przekroju
    model3D = [model3D; macierz];
end
model3D(1,:)=[]; %usuniecie pierwszego wiersza (samych zer)
handles.model3d = model3D;
guidata(hObject, handles);
%wyœwietlenie
figure
hold on
ptCloud = pointCloud(handles.model3d);
pcshow(ptCloud); %wyrysowanie chmury punktów
xlabel('X'); ylabel('Y'); zlabel('Z');

% --- Executes on button press in button_wczytaj_dane.
function button_wczytaj_dane_Callback(hObject, eventdata, handles)
% hObject    handle to button_wczytaj_dane (see GCBO)
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

checkBoxValueLiver = get(handles.checkbox_watroba, 'Value');

if checkBoxValueLiver == 1
    imshow(mat2gray(images(:,:,1)),'Parent', handles.axObraz);

    set(handles.slider, 'Min', 1);
    set(handles.slider, 'Max', filesLength);
    set(handles.slider, 'Value', 1);

end

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

set(handles.slider, 'Min', 1);
set(handles.slider, 'Max', masksLength);
set(handles.slider, 'Value', 1);
%set(handles.checkbox_szkielet, 'Value', 0);

skeletons = [];

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
%naczynia = Skeleton3D(naczynia);

for i = 1 : masksLength
   naczynia_watroba(:,:,i) = liver(:,:,i).*naczynia(:,:,i);
   % =  cat(3, obraz, obraz, obraz);
end

imageNumberSelected = int32(get(handles.slider, 'Value'))
[row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);

watroba = liver(:,:,imageNumberSelected);
for i = 1:numel(row)
    watroba(row(i), col(i)) = 255;
end

%imshow(mat2gray(liver(:,:,imageNumberSelected)), 'Parent', handles.axObraz);
%hold(handles.axObraz, 'on');
%set(handles.checkbox_naczynia,'Value',1);
%hold all;
%plot(col, row, 'r.', 'Parent', handles.axObraz);
%hold of;

imshow(mat2gray(watroba), 'Parent', handles.axObraz);

uiwait(msgbox('Szkieletyzacja naczyñ zakoñczona'));

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
        
   
end

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

%set(handles.slider_segment, 'Min', 1);
%set(handles.slider_segment, 'Max', liverLength);
%set(handles.slider_segment, 'Value', 1);

%cla(handles.axes_segment);

%obraz =  segment1(:,:,1).*images(:,:,1);
%imshow(mat2gray(obraz), 'Parent', handles.axes_segment);

objetosc = sum(sum(sum(segment1>0))) * voxelSpace;
set(handles.text_objetosc, 'String', ['Objêtoœæ: ', num2str(objetosc), ' mm^3']);

objetoscWatroba = sum(sum(sum(liver>0)));
set(handles.text_objetosc_watroby, 'String', ['Objêtoœæ w¹troby: ', num2str(objetoscWatroba), ' mm^3']);


set(handles.listbox1,'Visible','on');
set(handles.listbox1,'string',fieldnames(segmenty));


guidata(hObject, handles);

% --- Executes on button press in checkbox_watroba.
function checkbox_watroba_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_watroba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_watroba

% --- Executes on button press in button_plaszczyzna1.
function button_plaszczyzna1_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plaszczyzna1;
imageNumberSelected = int32(get(handles.slider, 'Value'))
plaszczyzna1 = imageNumberSelected;
set(handles.text_pozioma, 'String', ['nr ' num2str(plaszczyzna1)]);

% --- Executes on button press in button_plaszczyzna_pionowa1.
function button_plaszczyzna_pionowa1_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maskaPlaszczyzna1;
%[row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);

obraz = getImage(handles.axObraz);
uiwait(msgbox('Zaznacz segment'));

maskaPlaszczyzna1 = roipoly(obraz);

set(handles.text_pionowa1, 'String', 'ok');

% --- Executes on button press in button_plaszczyzna_pionowa2.
function button_plaszczyzna_pionowa2_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maskaPlaszczyzna2;
%[row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);

obraz = getImage(handles.axObraz);
uiwait(msgbox('Zaznacz segment'));

maskaPlaszczyzna2 = roipoly(obraz);

set(handles.text_pionowa2, 'String', 'ok');

% --- Executes on button press in button_plaszczyzna_pionowa3.
function button_plaszczyzna_pionowa3_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maskaPlaszczyzna3;
%[row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);

obraz = getImage(handles.axObraz);
uiwait(msgbox('Zaznacz segment'));

maskaPlaszczyzna3 = roipoly(obraz);

set(handles.text_pionowa3, 'String', 'ok');

% --- Executes on button press in button_plaszczyzna_pionowa4.
function button_plaszczyzna_pionowa4_Callback(hObject, eventdata, handles)
% hObject    handle to button_plaszczyzna_pionowa4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global maskaPlaszczyzna4;
%[row,col] = find(naczynia_watroba(:,:,imageNumberSelected)>0);

obraz = getImage(handles.axObraz);
uiwait(msgbox('Zaznacz segment'));

maskaPlaszczyzna4 = roipoly(obraz);

set(handles.text_pionowa4, 'String', 'ok');

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

%set(handles.slider_segment, 'Value', 1);

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

colors = ['y', 'm', 'c', 'r', 'g', 'b', [1,1,1], 'k'];

sekwencja = getfield(segmenty, itemSelected);
kolor = colors(listboxSelected);


okno = figure;
p=patch(isosurface(sekwencja,9));
reducepatch(p, .5)
if listboxSelected == 7
    set(p,'facecolor',[1,1,1],'edgecolor','none');
elseif listboxSelected == 8
    set(p,'facecolor',[0.8,0.8,0.8],'edgecolor','none');
else
    set(p,'facecolor',kolor,'edgecolor','none');
end
set(handles.axObraz,'projection','perspective')
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

% --- Executes on button press in button_3d_watroba.
function button_3d_watroba_Callback(hObject, eventdata, handles)
% hObject    handle to button_3d_watroba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global liver;
okno = figure;

p=patch(isosurface(liver,9));
reducepatch(p, .5)
set(p,'facecolor',[1,1,1],'edgecolor','none');
set(handles.axObraz,'projection','perspective')
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

% --- Executes on button press in button_3d_segmenty.
function button_3d_segmenty_Callback(hObject, eventdata, handles)
% hObject    handle to button_3d_segmenty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global segmenty;

colors = ['y', 'm', 'c', 'r', 'g', 'b', [1,1,1], 'k'];

%sekwencja = getfield(segmenty, itemSelected);
%kolor = colors(listboxSelected);


okno = figure;
for i =1:8
    listboxSelected = i;
    list = get(handles.listbox1,'String');
    itemSelected = list{listboxSelected};
    sekwencja = getfield(segmenty, itemSelected);
    p=patch(isosurface(sekwencja,9));
    reducepatch(p, .5)
    if i == 7
        set(p,'facecolor',[1,1,1],'edgecolor','none');
    elseif i == 8
        set(p,'facecolor',[0.8,0.8,0.8],'edgecolor','none');
    else
        set(p,'facecolor',colors(i),'edgecolor','none');
    end
    set(handles.axObraz,'projection','perspective')
    box on
    light('position',[1,1,1])
    light('position',[-1,-1,-1])

end

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