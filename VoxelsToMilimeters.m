function [nowy_x, nowy_y] = VoxelsToMilimeters( szkieletyzacja, dx, dy, dz )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[x y] = find(szkieletyzacja==255 | szkieletyzacja ==1); %znaleŸæ indeksy gdzie szkieletyzacja =1
nowy_x=x*dx;
nowy_y=y*dy;
end

