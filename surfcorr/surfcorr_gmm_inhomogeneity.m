function [inhomo,cluster_mean,cluster_var,cluster_population, im_cluster,smooth]=surfcorr_gmm_inhomogeneity(recon,n_cluster,profile,varargin)

%n_cluster=5;
mask=[];
flag_plot=1;
if(~isempty(varargin))
	%flag_plot=varargin{1};
    mask=varargin{1};
end;


   	fprintf('clustering [%d]...\n',i);
   
  	%recon=recon_all(:,:,i);
 	recon1d=reshape(recon,[prod(size(recon)),1]);
	
	mx=max(max(max(recon)));
  	mn=min(min(min(recon)));
 	var0=var(reshape(recon,[1,prod(size(recon))]));
   
   
   
	%initializing GMM
	fprintf('initializing GMM...\n');
    mu0=[mn:(mx-mn)/(n_cluster-1): mx];
    sig0=repmat(var0,[1,n_cluster]);
    p0=repmat(1/n_cluster,[1,n_cluster]);


	%GMM....
	fprintf('training GMM...\n');
	[mn,sigma,prob,loglike]=fmri_gaussem(mu0,sig0,p0,recon1d');
    
    [mn,idx]=sort(mn);
    sigma=sigma(idx);
    prob=prob(idx);


	%show clustering
   	fprintf('collecting index...\n');
   
	r1d=repmat(recon1d,[1,n_cluster]);
 	mn1d=repmat(mn,[length(recon1d),1]);
  	var1d=repmat(sigma,[length(recon1d),1]);
   
   	dist=abs((r1d-mn1d)./sqrt(var1d));
   	[dummy,cluster_idx]=min(dist,[],2);
   

	if(flag_plot)
	   	for j=1:n_cluster
            if(~isempty(mask))
                im=zeros(size(mask));
                mask_idx=find(mask);
            else
                im=zeros(size(recon));
            end;
            if(~isempty(mask))
                im(mask_idx(find(cluster_idx==j)))=1;
            else
                im(find(cluster_idx==j))=1;
            end;
            im_cluster(:,:,j)=im;
			parenchyma(j)=length(find(cluster_idx==j))/length(recon1d);
	 	end;
    end;
    
	fprintf('cluster mean=%s\n', mat2str(mn,3));
	fprintf('cluster var=%s\n', mat2str(sigma,3));
	fprintf('cluster Z=%s\n', mat2str(mn./sqrt(sigma),3));
	fprintf('parenchyma proportion=%s (%%)\n',num2str(parenchyma.*100,'%3.3f'));
	  
	cluster_mean=mn;
	cluster_var=sigma;
	cluster_z=mn./sqrt(sigma);
	cluster_population=parenchyma;

    zz=sqrt(cluster_var);
    contrast=abs(cluster_mean(:,1)-cluster_mean(:,end));
    inhomo=sum(zz,2)./contrast;

    %inhomo=1./abs(cluster_z(:,1)-cluster_z(end));
    
    f=[-1 -1 -1;
    -1 8 -1;
    -1 -1 -1]./8;

    %smooth=sum(sum(abs(conv2(profile,f,'same'))))
    smooth=norm(abs(conv2(profile,f,'same')));

    inhomo=inhomo.*smooth;

    return;

