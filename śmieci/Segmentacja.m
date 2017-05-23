function [ Im_progowanie, Im_szkieletyzacja ] = Segmentacja( obraz )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
prog1 = 150;
prog2 = 1500;
Im_progowanie = Progowanie(obraz, prog1, prog2);

%szkieletyzacja
Im_szkieletyzacja = bwmorph(Im_progowanie,'skel',Inf);

end

