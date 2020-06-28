function [inhomo,cluster_mean,cluster_var,cluaster_population]=surfcorr_gmm_inhomogeneity(recon,varargin)

flag_plot=1;
if(nargin)==2;
	flag_plot=varargin{1};
end;


   	fprintf('clustering [%d]...\n',i);
   
  	%recon=recon_all(:,:,i);
 	recon1d=reshape(recon,[prod(size(recon)),1]);
	
	mx=max(max(max(recon)));
  	mn=min(min(min(recon)));
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
   
   
	if(flag_plot)
	   	for j=1:3
			subplot(sprintf('22%d',j));
			im=zeros(size(recon));
			im(find(cluster_idx==j))=1;
			fmri_mont(im);
			colormap(gray(256));
			axis off image;
			parenchyma(j)=length(find(cluster_idx==j))/length(recon1d);
	 	end;
		subplot(224);
		fmri_mont(recon);
		axis off image;
		title(sprintf('recon [%d]',i));
	end;
 	
	fprintf('cluster mean=%s\n', mat2str(mn,3));
	fprintf('cluster var=%s\n', mat2str(sigma,3));
	fprintf('cluster Z=%s\n', mat2str(mn./sqrt(sigma),3));
	fprintf('parenchyma proportion=%s (%%)\n',num2str(parenchyma(2).*100,'%3.3f'));
	  
	cluster_mean=mn;
	cluster_var=sigma;
	cluster_z=mn./sqrt(sigma);
	cluster_population=parenchyma;
	inhomo=(1-parenchyma(2))*sqrt(sigma(2));


%save gmm_dwt cluster_mean cluster_var cluster_z cluster_population inhomo;

return;

