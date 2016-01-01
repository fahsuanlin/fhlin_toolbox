function [ok, sFifo]=ice_reflectline( sFifo, sMdh, ver_idea)
ok=0;

if(strcmp(ver_idea,'VA15'))    %VA15
    ice_va15_def;
    rr=bitand(sMdh.ulEvalInfoMask, MDH_REFLECT);
end;
if(strcmp(ver_idea,'VA21'))    %VA21
    ice_va21_def;
    rr=bitand(sMdh.aulEvalInfoMask(1), MDH_REFLECT);
end;

if(rr)
    sFifo.FCData=flipud(sFifo.FCData);
end;
ok=1;
return;
