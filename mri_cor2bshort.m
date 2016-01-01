clear all;

fil=sprintf('COR-*');
d=dir(fil);
dd=struct2cell(d);
filename=sort(dd(1,:));
[a,b]=size(filename);
f=filename(1,1:b);

head=zeros(256,256,b);
for j=1:b
	fn1=char(f(j));
	if(strcmp(fn1,'COR-.info')==0)
		fprintf('reading [%s]...\n',fn1);
		fp=fopen(fn1,'r');
		data=fread(fp,[256,256],'uchar');
		fclose(fp);
		head(:,:,j)=data';
	end;
end;

fmri_svbfile(head,'head.bshort');

str='done!';
disp(str);