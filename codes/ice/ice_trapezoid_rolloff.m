function [ok, sFifo]=ice_trapezoid_rolloff(sFifo,Trapezoid)

ok=1;
  %// Find the length of the vectors.
  lLenX = sFifo.lDimXOp;
  if ( lLenX ~= Trapezoid.NxRegrid )
      fprintf('\nERROR: length of line for regridding does not match regrid function!\n');
  end;

  denom=abs(Trapezoid.regrid_rolloff).^2;
  
  sFifo.FCData=sFifo.FCData.*conj(repmat(Trapezoid.regrid_rolloff,[1,size(sFifo.FCData,2)]))./(repmat(denom,[1,size(sFifo.FCData,2)]));
  
  return;