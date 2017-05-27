function [Imedges]=Fun_Bin2DEdges(ImBW)

% Pawe� Badura 2007
% Wyznaczenie kraw�dzi obiektu binarnego na kolejnych przekrojach
% ImBW - obraz binarny zawieraj�cy obiekt
% Imedges - obraz zawieraj�cy kraw�dzie obszaru

[w,k,g]=size(ImBW);     Imedges=false(w,k,g);
for i=1:g
 if (nnz(ImBW(:,:,i))~=0)
  Imedges(:,:,i)=bwperim(ImBW(:,:,i));
 end
end