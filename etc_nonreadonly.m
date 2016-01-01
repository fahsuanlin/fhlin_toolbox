function [vars]=etc_nonreadonly()
% make all files not read-only
%
% written by fhlin@aug. 18, 00

str=sprintf('[%s]',pwd);
disp(str);

fil=sprintf('*');

d=dir(fil);
if(size(d,1)>0)
   
   filename=struct2cell(d);
   filename=filename(1,:);
   [a,b]=size(filename);
   f=filename(1,1:b);
	




   %read bshort files in one folder
   for j=1:b
        fn1=char(f(j));
             
        str=sprintf('changing attribute of [%s]...',fn1);
	disp(str);
	
	if(computer=='LNX86')
		command=sprintf('!chmod a+rwx %s',fn1);
		eval(command);
       	else
 		command=sprintf('!attrib -r %s',fn1);
		eval(command);
	end;
  end;
end;




