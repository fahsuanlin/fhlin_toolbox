function [out]=etc_c2(input)
%etc_c2	get a combination sequence for a pair from an input row vector;
%
%[output]=etc_c2(input)
%
%input: the input row vector
%
%fhlin@aug.20.1999

sz=size(input);
output=[];

for a=1:sz(2)
	for b=a+1:sz(2)
		buffer=[input(a),input(b)];
		output=[output;buffer];			
	end;
end;

out=output;