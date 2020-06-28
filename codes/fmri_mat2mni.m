function [out]=fmri_mat2mni(inp,matrix_size)
% fmri_mat2mni converting matrix indices to MNI space
%
% output=fmri_mat2mni(input,matrix_size)
%
% input: a vector of x, y,and z indices of image matrix (or a scalar index based on matrix_size)
% matrix_size: a vector number of voxels in x, y and z direction
% output: a vector of x, y,and z coordinates of MNI space
%

%different bounding boxes in SPM
template=[-90,91; -126,91; -72,109];
spm99=[-78,78; -122, 76; -50, 85];
spm95=[-64,64; -104, 68; -28, 72];

if(size(inp)==[1 1]) %scalar input
	zz=floor(inp/matrix_size(1)/matrix_size(2));
	rem=mod(inp,matrix_size(1)*matrix_size(2));
	yy=floor(rem/matrix_size(1));
	xx=mod(rem,matrix_size(1));
	inp=[xx,yy,zz];
end;

%get the transformation matrix
trans=template;

x=inp(1);
X=(x-1)/(matrix_size(1)-1)*(trans(1,2)-trans(1,1))+trans(1,1);

y=inp(2);
Y=(y-1)/(matrix_size(2)-1)*(trans(2,1)-trans(2,2))+trans(2,2);

z=inp(3);
Z=(z-1)/(matrix_size(3)-1)*(trans(3,2)-trans(3,1))+trans(3,1);

out=[X,Y,Z];

fprintf('MNI coordinates: %s\n',mat2str(out,2));



