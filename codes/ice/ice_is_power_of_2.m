function [ok,lLastPower,lNextPower]=ice_is_power_of_2(lInput)

lFound=0;

lTest  = 1;

while(lTest<lInput)
    lTest=lTest*2;
    if(lTest==lInput)
        lFound=1;
    end;
end;

if ( lFound )
    lLastPower = lInput/2;
    lNextPower = 2*lInput;
    ok=1;
else
    lLastPower = lTest/2;
    lNextPower = lTest;
    ok=0;
end;


return;
