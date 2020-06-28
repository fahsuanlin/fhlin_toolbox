function [vars]=etc_lowerfile()
% make file name all in lower case
%
% written by fhlin@jan. 28, 00

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
        
        fn2=lower(fn1);
        
        str=sprintf('renanming from [%s] to [%s]...',fn1,fn2);
	disp(str);
	
	if(computer=='LNX86')
		command=sprintf('!mv %s xyz',fn1);
		eval(command);
		command=sprintf('!mv xyz %s',fn2);
		eval(command);
       	else
		command=sprintf('!rename %s %s',fn1,fn2);
		eval(command);
	end;
  end;
end;




