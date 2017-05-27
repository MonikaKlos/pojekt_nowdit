function [Imedges]=Fun_Bin2DEdges(ImBW)

% Pawe³ Badura 2007
% Wyznaczenie krawêdzi obiektu binarnego na kolejnych przekrojach
% ImBW - obraz binarny zawieraj¹cy obiekt
% Imedges - obraz zawieraj¹cy krawêdzie obszaru

[w,k,g]=size(ImBW);     Imedges=false(w,k,g);
for i=1:g
 if (nnz(ImBW(:,:,i))~=0)
  Imedges(:,:,i)=bwperim(ImBW(:,:,i));
 end
end