function [ok, sFifo]=ice_trapezoid_regrid(sFifo, Trapezoid)
ok=1;
%// Find the length of the vectors.
lLenX = sFifo.lDimXOp;

if(lLenX == Trapezoid.NxRegrid)
    ok=1;
else
    ok=0;
end;
if ( ~ok )
    fprintf('\nERROR: length of line for regridding does not match regrid function!\n');
    return;
end;

Trapezoid.regrid_workingSpace=sFifo.FCData;

for i=1:size(sFifo.FCData,1)
    jOrig=Trapezoid.regrid_neighbor(i,:)+1;
    sFifo.FCData(i,:)=Trapezoid.regrid_convolve(i,:)*(Trapezoid.regrid_workingSpace(jOrig,:)./repmat(Trapezoid.regrid_density(jOrig),[1,size(sFifo.FCData,2)]));
end;
return;

