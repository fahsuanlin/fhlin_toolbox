function Object=ice_createraw(lDimX,lDimY,lDimZ,lDimC);

Object.lDimX = lDimX;
Object.lDimY = lDimY;
Object.lDimZ = lDimZ;
Object.lDimC = lDimC;
Object.lLength = lDimX * lDimY * lDimZ * lDimC;

Object.FCData =zeros(Object.lLength,1)+sqrt(-1).*zeros(Object.lLength,1);

return;