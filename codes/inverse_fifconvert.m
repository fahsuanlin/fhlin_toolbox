function inverse_fifconvert(varargin)
% a matlab script to convert all fif files in the directory into matlab mat files using 4d toolbox programs
%
% written by fhlin@jul. 26, 01

pdir=pwd;

if(nargin>0)
	filename=varargin{1};
else
	fil=sprintf('*.fif');
	d=dir(fil);
	for i=1:size(d,1)
		filename{i}=d(i).name;
	end;
	filename
end;

for j=1:length(filename)
	fn1=filename{j};
	fprintf('loading [%s]...\n',fn1);
	[B,sfreq,t0]=loadfif(fn1);
	fn2=lower(fn1(1:length(fn1)-4));
	fprintf('saving [%s.mat]...\n',fn2);
	save(fn2,'B','sfreq','t0');

end;

cd(pdir);

str='done!';
disp(str);