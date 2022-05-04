function []=fmri_head2slice_folder()
% fmri_oneshot a generic template to do one-shot work by script
%  
% user should update the code in the loop for specific purpose
%
% written by fhlin@dec. 30, 99
   pwd

   fil=sprintf('*.bshort');

   d=dir(fil);
   filename=struct2cell(d);
   filename=filename(1,:);
   [a,b]=size(filename);
   f=filename(1,1:b);
	

   %read bshort files in one folder
   for j=1:b
        fn1=char(f(j));

subj=fn1(8:9);
cond=fn1(15:length(fn1)-17);
fn2=sprintf('%s.%s',subj,cond);
slice=91;
timepoint=1;

        str=sprintf('converting [%s] with prefix [%s]...',fn1,fn2);
        disp(str);

        fmri_head2slice(pwd,fn1,fn2,slice,timepoint);

   end;
end;

str='done!';
disp(str);



