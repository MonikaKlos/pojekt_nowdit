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
[nazwa_pliku, sciezka, indeks] = uigetfile('*.mhd');
if(length(nazwa_pliku)> 1 && length(sciezka)>1)
    [img info] = read_mhd(strcat(sciezka, nazwa_pliku));
    handles.img_mhd = img;
    handles.Im = img.data;
    handles.Info = info;
    guidata(hObject, handles);
%ustawienie wielkoœci slidera
    set(handles.slider, 'MAX',size(handles.Im,3));
    handles.segm = 0;
%wyœwietlenie
    axes(handles.axObraz);
    handles.ktory_obraz = 1;
    guidata(hObject, handles);
    imshow(handles.Im(:,:,handles.ktory_obraz), []);
end
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
handles.prog =1;
%wyœwietlenie
axes(handles.axObraz);
imshow(handles.Progowanie3D(:,:,handles.ktory_obraz));
guidata(hObject, handles);

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
ktory = round(get(hObject,'Value'));
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
    end
    if(handles.prog == 1)
        axes(handles.axObraz);
        imshow(handles.Progowanie3D(:,:,handles.ktory_obraz));
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
[nazwa_pliku, sciezka, indeks] = uigetfile('*.mhd');
if(length(nazwa_pliku)> 1 && length(sciezka)>1)
    [img info] = read_mhd(nazwa_pliku);
    handles.maska = img.data;
    handles.InfoMaski = info;
    guidata(hObject, handles);

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
end
% --- Executes on button press in btnSzkieletyzacja1.
function btnSzkieletyzacja1_Callback(hObject, eventdata, handles)
%% gotowa (z internetu) szkieletyzacja
szkielet = Skeleton3D(logical(handles.Progowanie3D)); %szkieletyzacja

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