function Object=ice_createima(lDimX, lDimY)

Object.lDimX = lDimX;
Object.lDimY = lDimY;
Object.lLength = lDimX * lDimY;
Object.sData = zeros(Object.lLength,1);

return;

