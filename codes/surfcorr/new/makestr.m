function str=makestr(level,signal_size,option)

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

if(option==0)
   str=sprintf('sub_input=input(1:%d',signal_size(1)./(2.^(level-1)));
	for i=2:length(signal_size)
   	str=strcat(str,sprintf(',1:%d',signal_size(i)./(2.^(level-1))));
	end;
	str=strcat(str,');');
end;
if(option==1)
   str=sprintf('(1:%d',signal_size(1)./(2.^(level-1)));
	for i=2:length(signal_size)
   	str=strcat(str,sprintf(',1:%d',signal_size(i)./(2.^(level-1))));
	end;
   str=strcat(str,')'); 
   str=sprintf('input%s=sub_input%s;',str,str);
end;
return;