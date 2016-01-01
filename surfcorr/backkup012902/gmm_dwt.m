close all;
clear all;

%load corrected data
load('surfcorr_dwt');

for i=1:size(recon_all,3)
   fprintf('clustering [%d]...\n',i);
   
   recon=recon_all(:,:,i);
   recon1d=reshape(recon,[prod(size(recon)),1]);
   
   mx=max(max(recon));
   mn=min(min(recon));
   var0=var(reshape(recon,[1,prod(size(recon))]));
   
   
   
	%initializing GMM
	fprintf('initializing GMM...\n');
	mu0=[mn;(mn+mx)/2; mx]';
	sig0=[var0 var0 var0];
	p0=[1/3 1/3 1/3];


	%GMM....
	fprintf('training GMM...\n');
	[mn,sigma,prob,loglike]=fmri_gaussem(mu0,sig0,p0,recon1d');


	%show clustering
   fprintf('collecting index...\n');
   
   r1d=repmat(recon1d,[1,3]);
   mn1d=repmat(mn,[length(recon1d),1]);
   var1d=repmat(sigma,[length(recon1d),1]);
   
   dist=abs((r1d-mn1d)./sqrt(var1d));
   [dummy,cluster_idx]=min(dist,[],2);
   
   
   for j=1:3
       subplot(sprintf('22%d',j));
      im=zeros(size(recon));
      im(find(cluster_idx==j))=1;
      imagesc(im);
      colormap(gray(256));
      axis off image;
      parenchyma(j)=length(find(cluster_idx==j))/length(recon1d);
   end;
   subplot(224);
   imagesc(recon);
   axis off image;
   fprintf('cluster mean=%s\n', mat2str(mn,3));
   fprintf('cluster var=%s\n', mat2str(sigma,3));
   fprintf('cluster Z=%s\n', mat2str(mn./sqrt(sigma),3));
	fprintf('parenchyma =%s (%%)\n',num2str(parenchyma(2).*100,'%3.3f'));
   title(sprintf('recon [%d]',i));
   
   cluster_mean(i,:)=mn;
   cluster_var(i,:)=sigma;
   cluster_z(i,:)=mn./sqrt(sigma);
   cluster_population(i,:)=parenchyma;
	inhomo(i)=(1-parenchyma(2))*sqrt(sigma(2));
end;

save gmm_dwt cluster_mean cluster_var cluster_z cluster_population inhomo;

return;

