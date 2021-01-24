function [temp]=makemoviet(fn)
% make movies from JPEG files into AVI files. 
% MATLAB 6.0 is required to run this program.
%
% makemoviet(fn)
% fn: the output AVI file name.
% 
% written by fhlin@dec. 30, 99

stem='cw_test_lh_';
root='.jpg';

pdir=pwd

%fil=sprintf('*.jpg');
%d=dir(fil);
%dd=struct2cell(d);
%filename=sort(dd(1,:));
%[a,b]=size(filename);
%f=filename(1,1:b);

%renaming...
%disp('file name changing...');
%for j=1:b
%	fn1=lower(char(f(j)));
%	nn=str2num(fn1(length(stem)+1:findstr(fn1,root)-1));
%	fn2=sprintf('%s%s%s',stem,num2str(nn,'%04d'),root);
%	cmd=sprintf('!rename %s %s',fn1,fn2);
%	eval(cmd);
%end;

%sorting names...
disp('sorting file names...');
fil=sprintf('*.jpg');
d=dir(fil);
dd=struct2cell(d);
filename=sort(dd(1,:));
[a,b]=size(filename);
f=filename(1,1:b);

mov = avifile('movie.avi')
mov.fps=5; %frame/sec;
mov.quality=100;
mov.compression='None';

%reading frames
for j=1:b
	fn1=lower(char(f(j)));
	d=imread(fn1,'jpg');
	fprintf('loading [%s]...\n',fn1);
	imagesc(d);
	axis off;
	axis image;
	d=getframe(gca);
	mov=addframe(mov,d);
end;
mov = close(mov);

       
str='done!';
disp(str);