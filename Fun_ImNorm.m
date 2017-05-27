function [Imnorm]=Fun_ImNorm(Im,mode,R)

% Pawe� Badura 2006
% Normalizacja obrazu DICOM do przedzia�u [0,1]
% Im - obraz oryginalny
% mode - typ normalizacji; 1 - przyci�cie ujemnych, 2 - przeskalowanie pe�nego zakresu 
% R - [RI, RS, prog] - rescale
% Imnorm - obraz znormalizowany

if (nargin < 3)     R = [0, 1, 0];      end
Imnorm = double(Im);       % !!!!!!!
Imnorm = R(2)*Imnorm + R(1);
if (mode == 1)          % 1 - przyci�cie ujemnych
 Imnorm(Imnorm < R(3)) = R(3);
end                     % 2 - skalowanie w pe�nym zakresie
maks = double(max(Imnorm(:)));      mini=double(min(Imnorm(:)));   
Imnorm = (Imnorm-mini)/(maks-mini); Imnorm(Imnorm < 0) = 0; 