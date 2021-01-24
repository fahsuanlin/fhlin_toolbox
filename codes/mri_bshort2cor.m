function mri_bshort2cor(fn)

head=fmri_ldbfile(fn);

for j=1:size(head,3)
	fn1=sprintf('COR-%s',num2str(j,'%03d'));

	fprintf('writing [%s]...\n',fn1);
	fp=fopen(fn1,'w');
	dd=squeeze(head(:,:,j))';
	imagesc(dd);
	pause(0.3);
	fwrite(fp,dd,'uchar');
	fclose(fp);
end;
	
str='done!';
disp(str);