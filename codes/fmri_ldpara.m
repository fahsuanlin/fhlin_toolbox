function para=fmri_ldpara(file)
%fmri_ldpara	loading parameter file
%
%para=fmri_ldpara(file)
%
%file:	the file name with full path of the parameter file
%para:	the N by 1 vector of the parameter file
%
% 
%written by fhlin@aug. 16, 1999
% 
%
fp=fopen(file,'r');
para=fscanf(fp,'%f');
fclose(fp);