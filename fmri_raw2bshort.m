function fmri_raw2bshort(data,prefix)

[x,y,z,t]=size(data);

for i=1:z
	current_slice=squeeze(data(:,:,i,:));
	fn=sprintf('%s_%s.bshort',prefix,num2str(i,'%03d'));
	str=sprintf('saving [%s]...',fn);
	disp(str);
	fmri_svbfile(current_slice,fn);
end;