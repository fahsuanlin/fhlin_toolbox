function [eloc]=inverse_read_eloc(eloc_file)

% inverse_read_eloc.m
%
% read electrode position into matlab
%
% [eloc]=inverse_read_eloc(eloc_file)
%
% nov. 7, 2000
%

fp=fopen(eloc_file,'r','ieee-be.l64');

n_electrode=fscanf(fp,'%f',1);

eloc=zeros(4,n_electrode);
for i=1:n_electrode
	eloc(:,i)=fscanf(fp,'%d %f %f %f',4);
end;

fclose(fp);

disp('read_eloc DONE!');

return;
