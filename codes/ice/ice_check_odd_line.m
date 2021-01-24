function status=ice_odd_line(sMdh, ice_obj)

if(strcmp(ice_obj.idea_ver,'VA21'))
    ice_va21_def;
    status=bitand(sMdh.aulEvalInfoMask(1) , MDH_REFLECT);
end;

if(strcmp(ice_obj.idea_ver,'VA15'))
    ice_va15_def;
    status=bitand(sMdh.ulEvalInfoMask, MDH_PHASCOR);
end;

