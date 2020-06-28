function [c]=fmri_contrast_interact(c1,c2)
%fmri_contrast_interact	make interaction of two contrast matrices
%
%[contrast]=fmri_contrast_interact(c1,c2)
%
%c1, c2: two contrast matrix of same number of rows
%contrast: the output interacton contrast matrix
%
%
%written by fhlin@Aug. 28, 2001

c=[];
c1_r=size(c1,1);
c2_r=size(c2,1);

if(c1_r~=c2_r)
   fprintf('C1 and C2 of different number of rows!!\n error!!n');
   return;
end;
   
c=zeros(size(c1,1),size(c1,2)*size(c2,2));
count=1;
for i=1:size(c1,2)
    for j=1:size(c2,2)
        c(:,count)=c1(:,i).*c2(:,j);
        count=count+1;
    end;
end;

return;
