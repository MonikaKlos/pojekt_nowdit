function [button] = Fun_DispSlices(Im, ImBin, mode, slice, info)

% Pawe³ Badura 2011
% Wyswietlenie serii z na³o¿on¹ binarn¹ lub nie
% Im - obraz oryginalny
% ImBin - obraz binarny z rezultatami segmentacji
%       - lub obraz etykiet dla wielu obrazów; wówczas wyœwietlanie
%           wielokolorowe w wybranych trybach (a1, a2, a0)
% mode - tryb wyswietlania w formacie 'ab': 
%       a - liczba okien, 
%       b - tryb:
%           1 - ImBin bezposrednio na Im,
%           2 - krawêdzie ImBin na Im,
%           3 - ImBin bezposrednio na Im (kolor),
%           4 - krawêdzie ImBin na Im (kolor),
%           0 - tylko dla 2 okien, Im | ImBin
% slice - przekrój pocz¹tkowy
% info - informacja tekstowa do wyœwietlenia w oknie

f = figure( 'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'NumberTitle', 'off', ...
            'Name', 'Slice-by-slice volume display', ...
            'WindowStyle', 'modal');
set(f, 'Units', 'pixels', 'Position', get(0, 'ScreenSize'));
[w,k,g] = size(Im);

Im = Fun_ImNorm(Im, 2);

if (nargin < 2)     ImBin = false;      end
if (nargin < 3)     mode = 11;          end
if (nargin < 4)     slice = round(g/2); end
if (nargin < 5)     info = [];          end
ImBin = double(ImBin);
if (nnz(ImBin))     
    empty = false;
    Lmax = max(ImBin(:));
    if (Lmax > 1)   multiobject = true;
    else            multiobject = false;
    end
    if ~multiobject     % rezultat jest binarny
        switch mode
            case {11, 21}
                Im2disp = cat(4, max(Im, ImBin), Im, Im);
            case {12, 22}
                R = Im;     GB = Im;
                E = Fun_Bin2DEdges(ImBin);
                R(E) = 1;   GB(E) = 0;
%                 Im2disp = cat(4, max(Im, double(Fun_Bin2DEdges(ImBin))), Im, Im);
                Im2disp = cat(4, R, GB, GB);
            case {13, 23}
                Im2disp = cat(4, Im, ImBin, false(w,k,g));
            case {14, 24}
                Im2disp = cat(4, Im, Fun_Bin2DEdges(ImBin), false(w,k,g));
            case 20
                ImBin = Fun_ImNorm(ImBin, 2);
        end
    else                % wiele obiektów -> wiele kolorów
        colors = [1 0 0;  0 1 0;  0 0 1;  1 1 0;  1 0 1;  0 1 1; ...
                  0 0 0;  0 0 0;  0 0 0];   % r g b y m c k k k
        switch mode
            case {11, 21}
                R = Im;     G = Im;     B = Im;
                for lab = 1:Lmax
                    labidcs = find(ImBin == lab);
                    if (colors(lab,1))  R(labidcs) = colors(lab, 1);    end
                    if (colors(lab,2))  G(labidcs) = colors(lab, 2);    end
                    if (colors(lab,3))  B(labidcs) = colors(lab, 3);    end
%                     R(labidcs) = colors(lab, 1);
%                     G(labidcs) = colors(lab, 2);
%                     B(labidcs) = colors(lab, 3);
                end
                Im2disp = cat(4, R, G, B);
            case {12, 22}
                R = Im;     G = Im;     B = Im;
                ImBin = ImBin .* double(Fun_Bin2DEdges(logical(ImBin)));
                for lab = 1:Lmax
                    labidcs = find(ImBin == lab);
                    R(labidcs) = colors(lab, 1);
                    G(labidcs) = colors(lab, 2);
                    B(labidcs) = colors(lab, 3);
                end
                Im2disp = cat(4, R, G, B);
            case 20
                R = false(w,k,g);   G = R;  B = R;
                for lab = 1:Lmax
                    labidcs = find(ImBin == lab);
                    R(labidcs) = colors(lab, 1);
                    G(labidcs) = colors(lab, 2);
                    B(labidcs) = colors(lab, 3);
                end
                ImBin = cat(4, R, G, B);
        end
    end
else
    empty = true;
end

% informacja
if (~isempty(info))
    hinfo = uicontrol(  'Style', 'Text',...
                        'Units', 'normalized',...
                        'FontSize', 10,...
                        'HorizontalAlignment', 'left',...
                        'BackgroundColor', [0.2 0 0.2],...
                        'ForegroundColor', [0.8 1 0.8]);
    set(hinfo, 'String', info);
    hinfoSize = get(hinfo, 'Extent');
    hinfoPosition = hinfoSize * 1.0; 
    if (mode >= 20)
        hinfoPosition(1) = (1 - hinfoPosition(3)) / 2;
        hinfoPosition(2) = 0.98 - hinfoPosition(4);
    else
        hinfoPosition(1) = 0.02;
        hinfoPosition(2) = 0.98 - hinfoPosition(4);
    end
    set(hinfo, 'Position', hinfoPosition);
end


while (1)
    if empty
        subplot('Position', [0.2 0.2 0.6 0.6]),
        imshow(Im(:,:,slice), []);
    else
        switch mode
            case {11, 12, 13, 14}
                subplot('Position', [0.2 0.2 0.6 0.6]),
                imshow(squeeze(Im2disp(:,:,slice,:)));
            case {21, 22, 23, 24}
                subplot('Position', [0.1 0.2 0.3 0.6]),
                imshow(Im(:,:,slice));
                subplot('Position', [0.6 0.2 0.3 0.6]),
                imshow(squeeze(Im2disp(:,:,slice,:)));
            case 20
                subplot('Position', [0.1 0.2 0.3 0.6]),
                imshow(Im(:,:,slice));
                subplot('Position', [0.6 0.2 0.3 0.6]),
                imshow(ImBin(:,:,slice));
        end
    end
    
% numer przekroju
    text(round(1.02*k), round(0.9*w), [int2str(slice), '/' int2str(g)], 'FontSize', 16, 'FontWeight', 'Bold', 'Color', [0.2 0 0.6]);
% legenda
    text(round(0.0*k), round(1.04*w), 'Left - prev. slice', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.0*k), round(1.09*w), 'Right - next slice', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.0*k), round(1.14*w), '- - -10 slices', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.0*k), round(1.19*w), '+ - +10 slices', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.33*k), round(1.04*w), 'Up - first slice', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.33*k), round(1.09*w), 'Down - last slice', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.33*k), round(1.14*w), 'g - goto slice', 'FontSize', 10, 'Color', [0.6 0 0]);
    text(round(0.66*k), round(1.09*w), 'Esc / q - quit', 'FontSize', 10);
    
%     [x, y, button] = ginput(1);
%     switch button
%         case 28         % lewy: poprzedni przekroj
%             slice = max(slice-1, 1);
%         case 29         % prawy: nastêpny przekroj
%             slice = min(slice+1, g);
%         case 45         % minus: o 10 do ty³u
%             slice = max(slice-10, 1);
%         case 43         % plus: o 10 do przodu
%             slice = min(slice+10, g);
%         case 30         % gorny: pierwszy przekroj
%             slice = 1;
%         case 31         % dolny: ostatni przekroj
%             slice = g;
%         case {71, 103}  % 'g' (goto): wybierz przekrój
%             slice = str2num(cell2mat(inputdlg('Slice no.:', 'Go to slice', 1)));
%             slice = max(1, min(slice, g));
%         case {27, 81, 113}  % 'q', 'esc': koniec
%             break;
%         otherwise
%             continue;
%     end        
end
close(f);