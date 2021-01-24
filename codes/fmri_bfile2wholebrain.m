function [data]=fmri_bfile2wholebrain()
% fmri_bile2wholebrain
%  
% convert all bfiles in pwd into a 3d whole brain data
%
% [data]=fmri_bfile2wholebrain
%
% written by fhlin@apr. 20, 2000

pwd

fil=sprintf('*.bshort');
d=dir(fil);
dd=struct2cell(d);
filename=dd(1,:);
[a,b]=size(filename);
f=filename(1,1:b);

fn=char(f(1));
sz=size(fmri_ldbfile(fn));

data=zeros([sz(1),sz(2),b]);



for j=1:b
   fn1=char(f(j));

   fprintf('loading [%s]...\n',fn1);    
   im=fmri_ldbfile(fn1);  
   data(:,:,b-j+1)=im;

   fn1=sprintf('%s.bshort',num2str(j,'%03d')); 
end;

%save whole data

str='done!';
disp(str);