function [index3d, index1d]=fmri_tal2mat(inp,matrix_size)
% fmri_tal2mat converting Talairach space coordinates to matrix indices
%
% output=fmri_tal2mat(input, matrix_size)
%
% input: a vector of x, y,and z coordinate of Talairach space
% matrix_size: a vector number of voxels in x, y and z direction
% index3d: a vector of x, y,and z indices of image matrix
% index1d: a scalar index based on matrix_size
%

%converting Talairach space to MNI brain
inp=fmri_tal2mni(inp);

%different bounding boxes in SPM
template=[-90,91; -126,91; -72,109];
spm99=[-78,78; -122, 76; -50, 85];
spm95=[-64,64; -104, 68; -28, 72];

%get the transformation matrix
trans=template;

x=inp(1);
X=(x-trans(1,1))/(trans(1,2)-trans(1,1))*(matrix_size(1)-1)+1;

y=inp(2);
Y=matrix_size(2)-(y-trans(2,1))/(trans(2,2)-trans(2,1))*(matrix_size(2)-1);

z=inp(3);
Z=(z-trans(3,1))/(trans(3,2)-trans(3,1))*(matrix_size(3)-1)+1;

out=[X,Y,Z];
fprintf('before rounding to integer: %s\n',mat2str(out,3));
index3d=round(out);
fprintf('INT index (3D): %s\n',mat2str(index3d));
index1d=(index3d(3)-1)*matrix_size(1)*matrix_size(2)+(index3d(1)-1)*matrix_size(2)+index3d(2);
fprintf('INT index (1D): %s\n\n',mat2str(index1d));



