function [output]=etc_factorial(input)
if (input==0)
	output=1;
	return;
end;

if(input<0)
	disp('input argument error!');
	return;
end;

output=input;
if (input~=1)
  	output=output*etc_factorial(input-1);
else
  	output=1;
end;

%output=1;
%for i=2:input;
%	output=output*i;
%end;