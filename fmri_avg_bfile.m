function []=fmri_avg_bfile(fil,avg_count)
% fmri_avg_bfile 	average bfiles 
%  
% fmri_avg_bfile(fil,avg_count)
%
% fil: file filter
% avg_count: # of slice in each average
%
% written by fhlin@jun, 03, 2000

pwd
fil=sprintf(fil);
d=dir(fil);
dd=struct2cell(d);
filename=dd(1,:);
[a,b]=size(filename);
f=filename(1,1:b);


for j=1:b
	ff=[];
	fn1=char(f(j));
    	fprintf('loading [%s]...\n',fn1);
   	d=fmri_ldbfile(fn1);
   	
   	fprintf('averaging [%s]...\n',fn1); 
   	total=size(d,3)/avg_count;
   	z=zeros(size(d,1),size(d,2),total);
   	for k=1:total
   		buffer=d(:,:,1+(k-1)*avg_count:k*avg_count);
   		buffer=mean(buffer,3);
   		z(:,:,k)=squeeze(buffer);
   	end;
   	
   	fn2=sprintf('avg%d_%s',avg_count,fn1);
   	fprintf('saving [%s]...\n',fn2); 
   	fmri_svbfile(z,fn2);
end;

str='done!';
disp(str);