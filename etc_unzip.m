function [vars]=etc_unzip()
% uncompress all WinZip files by script
%
% written by fhlin@jul. 05, 00

str=sprintf('working at [%s]',pwd);
disp(str);

fil=sprintf('*.gz');

d=dir(fil);
if(size(d,1)>0)
   	filename=struct2cell(d);
   	filename=filename(1,:);
   	[a,b]=size(filename);
   	f=filename(1,1:b);
	
   	for j=1:b
        	fn1=char(f(j));
        
        	fprintf('extracting [%s]...\n',fn1);
        	run=sprintf('!winzip32 -min -e -o -j %s %s\n',fn1,pwd);
        	eval(run);
        end;
end;




