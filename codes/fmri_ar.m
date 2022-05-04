function [d]=ar(datafile,order)
[datamat,coords,x,y]=fmri_pls_datamat(datafile,1,1,1,0,[1,1,0,1,0,0]);
[timepoint,voxel]=size(datamat);
close all;
for idx=1:1
	%sequence=randperm(timepoint);
	%d=datamat(sequence,:);
	d=datamat;

	a=zeros(order,voxel);
	disp('model parameter estimation...');
	for i=1:voxel
		Y=reshape(d(:,i),[timepoint,1]);
		a(:,i)=reshape(fmri_yw(Y,order),[order,1]);
		str=sprintf('YW estimation: [%d|%d]',i,voxel);
		%%disp(str);
	end;
	[brainlv,sv,designlv]=svd(d',0);
	brain_score=datamat*brainlv;      

	contrast=eye(timepoint);
	design_score=contrast*designlv;
	
	figure(idx);
	disp_datamat(brainlv(:,1),coords,y,x,1);
	slices=1;
	save ar-temp brainlv sv designlv coords y x timepoint slices brain_score design_score
end;

