function [proj_data,w,error_theory,error_data]=fmri_pca(data)
%fmri_pca	PCA analysis
%
%[proj_data,w,error_theory,error_data]=fmri_pca(data)
%
%data: M*N data matrix; M observation and N variables
%proj_data: the pricipal components of the data
%error_theory: the error from eigen value of PCA
%error_data: the error from the difference of original data and PC
%
%written by fhlin@oct 9, 1999
%

cov_matrix=cov(data);





%make sure it is a square vector
[m,n]=size(cov_matrix);

if(m~=n)
	disp('non-square data!');
	return;
end;

%get the eigen value and eigen vector
[vector,value]=eig(cov_matrix);

%sort the eigen value (ascending-order)
[v,index]=sort(diag(value));

%sort the eigen vector (ascending-order)
for i=1:size(cov_matrix,1)
	vc(:,i)=vector(:,index(i));
end;


%put the sorted eigen value in descending order
for i=1:size(cov_matrix,1)
	eig_value(i)=v(size(cov_matrix,1)+1-i);
	eig_vector(:,i)=vc(:,size(cov_matrix,1)+1-i);
end;

%transpose for column vectors
eig_value=eig_value';


k=length(find(eig_value));


% hw3_1c	the projection of data to the space spanned by the first k component  from covariance matrix p
%
%[proj_data,w,error_theory,error_data]=hw3_1c(data,eig_value,eig_vector,k)
%
%data: M*N matrix (M observation and N variables)
%eig_value: N*1 sorted eigen value (descending)
%eig_vector: N*N sorted and normalized eigen vector (descending)
%k: number of principal directions for recontruction
%proj_data: the projected covariance data to the space spanned by k pricipal directions
%w: reconstruced data from first k principal direction
%error_theory: mean square error of reconstruction from eigen-value
%error_data: mean square error of reconstruction from data
%
%written by fhlin@oct 9, 1999
%

%make sure dimensions are correct
[m1,n1]=size(data);
[m2,n2]=size(eig_value);
[m3,n3]=size(eig_vector);

if(m3~=n3)
	disp('non-square eigen vector matrix!');
	return;
end;

if((n1~=m2)|(m2~=m3)|(n1~=m3))
	disp('data/eigen-vector/eigen-value dimension error!');
	return;
end;

if(k>n1|k<0)
	disp('k value error!');
	return;
end;

%get the first K principal components
proj_vector=eig_vector(:,1:k);

% project the raw data to the first K principal components
proj_data=data*proj_vector;

% prepare the reconstructed data by using the first K principal components only
K=zeros(n1,n1);
KK=eye(k,k);
K(1:k,1:k)=KK;

%generate the reconstructed data by using first K principal components
w=(eig_vector*K*eig_vector'*data')';

%calculate the theoretical reconstruction error, adding all eignvalues from Lambd(K+1) to Lambda(N)
error_eig_value=eig_value(k+1:length(eig_value));
error_theory=sum(error_eig_value);

%calculate the mean square error by direct computation
e=w-data; %different between raw data and the reconstruction
error_data=sum(sum(e.*e,2),1)./size(data,1); %get mean square error of the reconstruction
