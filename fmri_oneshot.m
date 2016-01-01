function [temp]=fmri_oneshot()
% fmri_oneshot a generic template to do one-shot work by script 
%
% written by fhlin@dec. 30, 99
pdir=pwd


fil=sprintf('*head4*.raw');
d=dir(fil);
dd=struct2cell(d);
filename=sort(dd(1,:));
[a,b]=size(filename);
f=filename(1,1:b);

for j=1:b
   
   [path,fn,ext]=fileparts(char(f(j)));
   fprintf('processing [%s%s]...\n',fn,ext);

   [k,img]=fmri_ldsiemens_raw(char(f(j)),[64,128],'3t');

   ff=sprintf('%s_k',fn);
   fprintf('saving [%s_k.mat]...\n',fn);
   save(ff,'k');
   ff=sprintf('%s_img',fn);
   fprintf('saving [%s_img.mat]...\n',fn);
   save(ff,'img');
   %save(fn,'mask','mask_1d','-append');
   
end;

cd(pdir);

str='done!';
disp(str);