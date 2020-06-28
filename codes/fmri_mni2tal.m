function [out]=fmri_mni2tal(inp)
% fmri_mni2tal converting MNI coordinates to Talarich coordinates
%
% output=fmri_mni2tal(input)
%
% input: a vector of x, y,and z coordinates of MNI brain
% output: a vector of x, y,and z coordinates of Talairach brain
%
% ref: http://www.mrc-cbu.cam.ac.uk/imaging/mnispace.html

x=inp(:,1);
y=inp(:,2);
z=inp(:,3);

X=zeros(size(x));
Y=zeros(size(y));
Z=zeros(size(z));

idx=find(z>=0);
X(idx)=0.99.*x(idx);
Y(idx)=0.9688.*y(idx)+0.046.*z(idx);
Z(idx)=-0.0485*y(idx)+0.9189*z(idx);

idx=find(z<0);
X(idx)=0.99.*x(idx);
Y(idx)=0.9688.*y(idx)+0.042.*z(idx);
Z(idx)=-0.0486*y(idx)+0.839*z(idx);

out=[X,Y,Z];

%fprintf('Talairach coordinates: %s\n',mat2str(out,2));



