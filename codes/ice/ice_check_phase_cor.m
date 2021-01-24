function status=ice_check_phase_cor(sMdh,ice_obj)

if(strcmp(ice_obj.idea_ver,'VA21'))
    ice_va21_def;
    status=bitand(sMdh.aulEvalInfoMask(1),MDH_PHASCOR);
end;

if(strcmp(ice_obj.idea_ver,'VA15'))
    ice_va15_def;
    status=bitand(sMdh.ulEvalInfoMask, MDH_PHASCOR);
end;


