function fmri_svpara(para,parafile)
% fmri_svpara Saving paradigm in file
% 
% fmri_svpara(para,parafile)
% para: the row vector containing paradigm. conventionally it is a vector of 1, -1 and/or 0.
% parafile: the paradigm file name. conventionally its suffix is '.para'.
%
% written by fhlin@jan. 16 00

fp=fopen(parafile,'w');
fprintf(fp,'%d\n',para);
fclose(fp);
disp('paradigm written ok!');
