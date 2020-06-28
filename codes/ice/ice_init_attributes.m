function [ice_obj]=ice_init_attributes(MrProt, ice_obj)

[ok,lTest,lNext]=ice_is_power_of_2(ice_obj.m_NyFT);

if ( ~ok) ice_obj.m_NyFT = lNext; end;

%// The mosaic image will satisfy
%// 1) each panel will be square   and satisfy # pixels = 2^n in x and y
%// 2) the # panels will be square (e.g., total panels =1,2,4,9,16,25,36,...)
%//
%// CHOOSE THE SIZE OF THE PANELS:
%//
%// Find the larger of the 2 image dimensions.
ice_obj.m_DimPanel = ice_obj.m_NxImage;
if (ice_obj.m_DimPanel < ice_obj.m_NyImage) ice_obj.m_DimPanel = ice_obj.m_NyImage; end;
%// Increase this dimension (if necessary) to satisy 2^n.
lTest=1;
while (lTest < ice_obj.m_DimPanel)
    lTest=lTest*2;            
end;
ice_obj.m_DimPanel = lTest;

%//
%// CHOOSE THE NUMBER OF PANELS
%//
lTest = 1;
while (lTest*lTest < ice_obj.m_Nz ) 
    lTest=lTest+1;
end;
ice_obj.m_1dPanels = lTest;

return;
