function inverse_patch2dxf(v,f,fn)
% inverse_patch2dxf     Convert Matlab triangulated patch to DXF file format (AutoCAD or  MAX 3D)
%
% inverse_patch2dxf(v,f,fn)
%
% v: a vertex matrix of p*3 entries for (x,y,z) of p-vertices
% f: a face matrix of q*3 entries for q faces. Each row of matrix f specifies a triangle face.
%    The entries of each triangle face are the vertex number specified in vertex matrix v.
% fn: the output file name (.DXF is the default suffix)
%
% fhlin@mar 24,2002

fp=fopen(fn,'w');
fprintf(fp,'999\nDXF converted from matlab model\n');
fprintf(fp,'0\nSECTION\n');
fprintf(fp,'2\nENTITIES\n');

for i=1:size(f,1)
      fprintf(fp,'0\n3DFACE\n');
      fprintf(fp,'8\n1\n');
      fprintf(fp,'10\n%6.6f\n20\n%6.6f\n30\n%6.6f\n',v(f(i,1),1),v(f(i,1),2),v(f(i,1),3));
      fprintf(fp,'11\n%6.6f\n21\n%6.6f\n31\n%6.6f\n',v(f(i,2),1),v(f(i,2),2),v(f(i,2),3));
      fprintf(fp,'12\n%6.6f\n22\n%6.6f\n32\n%6.6f\n',v(f(i,3),1),v(f(i,3),2),v(f(i,3),3));
      fprintf(fp,'13\n%6.6f\n23\n%6.6f\n33\n%6.6f\n',v(f(i,3),1),v(f(i,3),2),v(f(i,3),3));

end;

fprintf(fp,'0\nENDSEC\n');
fprintf(fp,'0\nEOF\n');

fclose(fp);
fprintf('DONE!\n');
