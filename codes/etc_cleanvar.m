function [vars]=etc_cleanvar(filter,varlist)
% clean up MAT file variables
%
% written by fhlin@jan. 28, 00

str=sprintf('[%s]',pwd);
disp(str);


d=dir(filter);
fnlist=strvcat(d.name);


%read bshort files in one folder
for j=1:size(fnlist,1)
        fn1=deblank(fnlist(j,:));
	str=sprintf('load [%s]....',fn1);
	disp(str);

	buffer=load(fn1);

	buffer_name=fieldnames(buffer);
	
	if(~isempty(intersect(buffer_name,varlist)))
		load(fn1);
		
		filtered_name=setdiff(buffer_name,varlist);
	
		str=fprintf('modifying [%s]....\n',fn1);
		
		save(fn1,filtered_name{:});
	else
		fprintf('no variable(s) in the list found in the file!\n');
	end;
end;




