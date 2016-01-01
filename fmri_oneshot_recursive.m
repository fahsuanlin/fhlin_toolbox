function [temp]=fmri_oneshot_recursive()
% fmri_oneshot a generic template to do one-shot work by script
%  
% user should update the code in the loop for specific purpose
%
% written by fhlin@dec. 30, 99
str=sprintf('PWD: [%s]',pwd);
disp(str);



%get directory structure for recursive funtion
d=dir;
d=struct2cell(d);
directory=d(4,:);
name=d(1,:);
[n,m]=size(directory);
ddd=directory(1,1:m);
nnn=name(1,1:m);
dir_name='';
for j=1:m
   dir_name=strvcat(dir_name,char(nnn(j)));
   t=ddd(j);
   idx(j)=t{1};
end;
dir_name=dir_name(find(idx==1),:);
dir_name(1,:)=[];  %remove '.'
dir_name(1,:)=[];  %remove '..'
   
   
   
%recursive call to get into each directory
if(size(dir_name,1)>1)
	for i=1:size(dir_name,1)
   		cd(dir_name(i,:));
   		fmri_oneshot_recursive;
   	end;
else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% you have to modify code here every time for different tasks!

   	fmri_oneshot;
   	
   	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   	cd('..');
   	return;
end;
cd('..');
return;
str='done!';
disp(str);



