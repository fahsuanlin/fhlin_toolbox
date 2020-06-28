function [h,v1,v2]=mri_homogenous(data,varargin)
% mri_homogeneous	calculate homogeneity index, H, of the input image
%
%	h=mri_homogeneous(data)
%
%	data: input 2D image matrix
%	h: homogeneity index
%
%	written by fhlin@apr. 22, 2000 

data=imresize(data,[256,256]);

if(nargin==1)
	mask=ones(size(data));
else	
	mask=varargin{1};
end;

idx=find(mask>0.6);
idx_mask=zeros(size(data));
idx_mask(idx)=mask(idx);


%normalize intensity between 0 and 1
mmax=max(max(data));
mmin=min(min(data));
data=(data-mmin)./(mmax-mmin);

%%%%%%%%%% homogeneity %%%%%%%%%%%%%%

v1=1;
lowpass_data=conv2(data,ones([16,16]),'same');
selected_lowpass_data=lowpass_data(idx);
v1=std(selected_lowpass_data);

%%%%%%%%%%% information %%%%%%%%%%%%%

v2=1;
selected_data=data(idx);
v2=std(selected_data);

%%%%%%%%%%%%% homogeneity index %%%%%%%%%%%%%

fprintf('v2=%6.8f	v1=%6.8f\n',v2,v1);

h=v2./v1;

return;









%do block mean calculation
i1=blkproc(data,[8,8],'mean(reshape(x,[1,64]))');

%do block variance calculation
i2=(blkproc(data,[8,8],'std2')).^2;

i1=imresize(i1,[256,256],'bilinear');
i2=imresize(i2,[256,256],'bilinear');

%estimate the homogeneity across blocks
v1=(std2(i1)).^2;

%estimate the local information within each block
v2=mean2(i2);

%get homogeneity index
%h=mean2(i1);
h=v2./v1;

return;


