function [contrast]=fmri_para2contrast(parafile)
% fmri_scanpara		read in a paradigm file and gerenate the contrast matrix
%
%[contrast]=fmri_para2contrast(parafile)
%
%parafile: the file name of the paradigm, including the full path
%
%
%written by fhlin@aug. 24 1999

fp=fopen(parafile,'r');
para=fscanf(fp,'%f');
fclose(fp);

count=0;
cont=1;

tmp=para;
plot(para);
length(tmp);
minn=min(para);

while cont==1
	maxx=max(tmp);
	if(maxx==minn)
		cont=0;
	else
		count=count+1;
		index=find(tmp==maxx);
		tmp(index)=0;
		contrast(count,index)=1;
	end;
end;

str=sprintf('total: %d epochs',count);
disp(str);
str=sprintf('length: %d ',length(para));
disp(str);
subplot(211);
plot(para);
subplot(212);
imagesc(contrast);


