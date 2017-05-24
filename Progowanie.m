function [ Im_progowanie ] = Progowanie( obraz, prog1, prog2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for i=1:size(obraz,1)
    for j=1:size(obraz,2)
        if(obraz(i,j)<prog1 || obraz(i,j)>prog2)
            Im_progowanie(i,j) =0;
        else
            Im_progowanie(i,j)=255;
        end
    end
end
end

