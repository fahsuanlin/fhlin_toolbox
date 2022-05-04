function [angle,seq]=etc_matrix_cos(v1,v2)
%etc_matrix_cos		calculate the angle between rows of two matrices. two matrices must
%			the same size. the subroutine searches the "best fit" in terms of maximal 
%			absolute innerproduct
%
%	[angle,seq]=etc_matrix_cos(v1,v2)
%	v1: input matrix 1
%	v2: input matrix 2
%	angle: the angle between the best-fit rows from both matrices.
%	seq: the sequence of v2, which corresponds to the angle calculated.
%
%	written by fhlin@jul. 14, 2000

sz1=size(v1);
sz2=size(v2);
if ( sz1~=sz2 )
	str=sprintf('v1 of [%s], v2 of [%s]', num2str(sz1), num2str(sz2));
	disp(str);
	disp('size does not match! error!');
	return;
end;



vec1=v1;
vec2=v2;
for i=1:size(vec1,1)
     vec_a=vec1(i,:);

     %do the inner product between vectors
     clear inner_product;
     for j=1:size(vec2,1)
         vec_b=vec2(j,:);
	 inner_product(j)=sum(vec_a.*vec_b);
     end;

     %look for the maximal inner-product
     [yy,ii]=sort(abs(inner_product));
     idx=ii(length(inner_product));
     seq(i)=idx;


     %save the corresponding maximal vector
     vec_sort(i,:)=vec2(idx,:);
       
     vec2(idx,:)=0;
end;

seq;

v1=vec1;
v2=vec_sort;



l_v1=sqrt(sum(v1.^2,2));
l_v2=sqrt(sum(v2.^2,2));






cc=sum(v1.*v2,2);

ip=cc./l_v1./l_v2;
angle=acos(ip)*180/pi;
