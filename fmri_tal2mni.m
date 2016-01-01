function [out]=fmri_tal2mni(inp)
% fmri_mni2tal converting Talairach coordinates to MNI coordinates
%
% output=fmri_tal2mni(input)
%
% input: a vector of x, y,and z coordinates of Talairach brain
% output: a vector of x, y,and z coordinates of MNI brain
%
% ref: http://www.mrc-cbu.cam.ac.uk/imaging/mnispace.htmlfm

x=inp(1);
y=inp(2);
z=inp(3);

X=x/0.99;

correct_guess=0;

%guessing Z>=0
trans=inv([0.9688 0.046; -0.0485, 0.9189])*[y;z];
Y=trans(1);
Z=trans(2);
if(Z>=0)
	fprintf('Z>=0\n');
	correct_guess=1; 
end;

if(correct_guess==0)
	%guessing Z<0
	trans=inv([0.9688 0.042; -0.0485, 0.839])*[y;z];
	Y=trans(1);
	Z=trans(2);
	if(Z<0)
		fprintf('Z<0\n');
		correct_guess=1;
	end;
end;

if(correct_guess==0)
	fprintf('weird coordinae. no MNI to Talairach transform available...\n');
	return;
end;


out=[X,Y,Z];

fprintf('MNI coordinates: %s\n',mat2str(out,2));