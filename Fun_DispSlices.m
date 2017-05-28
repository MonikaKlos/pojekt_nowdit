function [Im2disp] = Fun_DispSlices(Im, ImBin, mode, slice, info)

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
        colors = [0 0 1;  0 1 0;  0 0 1;  1 1 0;  1 0 1;  0 1 1; ...
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


if empty

else   
    return;
end