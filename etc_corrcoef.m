function cc=etc_corrcoef(para,data)
% etc_corrcoef	calculate the correlation coefficients
%
% cc=etc_corrcoef(para,data)
%
% para: N*1 vector of the paradigm
% data: N*M matrix of the data for N time ponts and M voxels
%
% cc: 1*M vector of the correlation coefficients
%
% fhlin@mar 18, 2003
para_c=para-repmat(mean(para),[length(para),1]);
data_c=data-repmat(mean(data,1),[size(data,1),1]);

%calculating covariance
covv=para_c'*data_c./(size(data,1));

%calculating correlation coefficints
cc=covv./sqrt(para_c'*para_c./length(para_c))./sqrt(sum(data_c.^2,1)./size(data,1));