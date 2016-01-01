function inverse_write_label(label,x,y,z,val,fn)

% inverse_write_label	write dipole labels
%
% inverse_write_label(label,x,y,z,val,fn)
%
% fn: the file name of the output label. it must be xxxx-lh.label or xxxx-rh.label for MNE_SIMU to recognize appropriate hemisphere.
% label: a vector of dipole number (0-based).
% x: a vector of x-coordinate 
% y: a vector of y-coordinate
% z: a vector of z-coordinate
% val: a vector of values associated with each dipole
%
% fhlin@jul 30, 2003

fprintf('creating [%s]...\n',fn);
fp=fopen(fn,'w');
fprintf(fp,'# label file from inverse_write_label [%s]\n',date);
fprintf('total [%d] labels...\n',length(label));
fprintf(fp,'%d\n',length(label));
for i=1:length(label)
	fprintf(fp,'%d\t%3.3f\t%3.3f\t%3.3f\t%3.3f\n',label(i),x(i),y(i),z(i),val(i));
end;
fclose(fp);
fprintf('done!\n');

return;
