function [dice] = DICE(maska1, maska2)
    licznik =0;%cz wsp�lna
    mianownik=0;%suma
    
    for k=1:size(maska1,3) %p�tla po przekrojach
        for j=1:size(maska1,1) %p�tla po pikselach
            for i=1:size(maska1,2)
                if(maska1(j,i,k)==0 && maska2(j,i,k)==0)
                    %nic
                end
                if (maska1(j,i,k)==0 && maska2(j,i,k)==1 || maska1(j,i,k)==1 && maska2(j,i,k)==0)
                    mianownik = mianownik +1;
                end
                if(maska1(j,i,k)==1 && maska2(j,i,k)==1)
                    mianownik = mianownik +1;
                    licznik = licznik +1;
                end
            end
        end
    end
    dice = licznik/mianownik;
end