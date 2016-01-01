function [temp]=etc_rename()
pwd

fil=sprintf('ws_head*.img');
d=dir(fil);
dd=struct2cell(d);
filename=dd(1,:);
[a,b]=size(filename);
f=filename(1,1:b);
for j=1:b
	fn1=char(f(j));
   fn2=sprintf('ws_1l_%s.img',num2str(j-1,'%03d'));
   str=sprintf('renaming [%s]...',fn1);
   disp(str);
      
   s=sprintf('! rename %s %s',fn1,fn2);
   eval(s);
      
   fn1=strcat(fn1(1:length(fn1)-4),'.hdr');
   fn2=sprintf('ws_1l_%s.hdr',num2str(j-1,'%03d'));
   str=sprintf('renaming [%s]...',fn1);
   disp(str);
      
   s=sprintf('! rename %s %s',fn1,fn2);
   eval(s);
   
end;
   
str='done!';
disp(str);



