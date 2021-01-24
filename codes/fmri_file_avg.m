function []=fmri_file_avg()
% fmri_oneshot a generic template to do one-shot work by script
%  
% user should update the code in the loop for specific purpose
%
% written by fhlin@dec. 30, 99
   pwd

for i=1:91
   fil=sprintf('*_%s.bshort',num2str(i-1,'%03d'));

   d=dir(fil);
   filename=struct2cell(d);
   filename=filename(1,:);
   [a,b]=size(filename);
   f=filename(1,1:b);
	

   %read bshort files in one folder
   for j=1:b
        fn1=char(f(j));

         data(:,:,j)=fmri_ldbfile(fn1);
mx=max(max(data(:,:,j)));
mn=min(min(data(:,:,j)));

        str=sprintf('loading [%s]...max=%d min=%d',fn1,mx,mn);
        disp(str);

   end;
 
   data=mean(data,3);
   fn2=sprintf('struct_%s.bshort',num2str(i-1,'%03d'));
mx=max(max(data));
mn=min(min(data));
   str=sprintf('saving [%s]...max=%d min=%d',fn2,mx,mn);
   disp(str);
   fmri_svbfile(data,fn2);
end;

str='done!';
disp(str);



