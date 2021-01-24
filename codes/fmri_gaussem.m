function [mu_new,sigsq_new,p_new, loglikelihood]=fmri_gaussem(mu,sigsq,p,x)
%
% EM algorithm for mixture of spherical Gaussians
% (covariance matrices are multiples of the identity matrix)
% x is (d,n) matrix:
% d=dimension of data, 
% n=number of datapoints
% m=number of mixtures
%
% example use: (after parameters have been initialized)
%
% [mu,sigsq,p, loglikelihood]=fmri_gaussem(mu,sigsq,p,x);
% you may want to pass in a parameter specifying the
% number of iterations to perform.
%
%mu: the mean of the gaussian vector; a d*m matrix for data of d dimension and m clusters
%sigsq: the variance of the gaussian vector, a 1*m row vector for data of m clusters
%p: the initial probability for each cluster; a 1*m row vector for data of m clusters
%
%mu_new: the mean of the gaussian vector after EM, d*m matrix
%sigsq_new: the variance of the gaussian vector after EM, 1*m row vector
%p_new: the prob. for each cluster, 1*m row vector
%loglikelihood: the loglikelihood in each iteration, a row vector
%
% written by fhlin@nov. 30, 1999

[d,m]=size(mu);
[d,n]=size(x);

%%% the threshold to stop the EM iteration
loglikelihood_limit=1;
iteration_limit=100;


iteration=1;
go_on=1;

p_new=p;
mu_new=mu;
sigsq_new=sigsq;
loglikelihood=[];
while(go_on)
  %%%%%  pxgivenj is p(x|j), with pxgivenj(i,j)=p(x_i|j)
  if(isempty(find(sigsq<=0)))
      pxgivenj=fmri_sph_gauss(x,mu,sigsq);
  else
      return;
  end;
  %max(max(pxgivenj))
  %min(min(pxgivenj))
  %pause;
  
  
  %%%%%  numerator contains p(x|j)p(j)
  numerator=pxgivenj.*(ones(n,1)*p); 
  
  %%%%% pold is the old conditional probability p(j|x)
  %%%%% pold(i,j)=p(j|x_i)
  pold=zeros(n,m);
  pold=numerator./(sum(numerator,2)*ones(1,m));
  
  %%%%%  find log-likelihood 
  
   
  aa=pxgivenj.*(ones(n,1)*p);
  %max(max(aa))
  %min(min(aa))
  %a1=sum(aa,2);
  %plot(a1);
  %idx=find(pxgivenj>1)
  %a2=log(a1);
  %a3=sum(a2);
  %pause;
  
  
  loglikelihood(iteration)=sum(log(sum(pxgivenj.*(ones(n,1)*p),2)));
  
  fprintf('iteration [%d] Loglikelihood:      %10.16g \n',iteration,loglikelihood(iteration));
  
  
  Zold=sum(pold,1);  % useful normalization factor
  
  %%%%%  mu_new contains the new means
  idx=find(Zold==0);
  Zold(idx)=inf;
  mu_new=x*pold./(ones(d,1)*Zold);
  mu_new(idx)=mu(idx);

  %%%%% sigsq_new
  clear diff;
  for j=1:m
  	diff=(x-mu_new(:,j)*ones(1,n));
  	if(d>1)
  		buffer(j,:)=sum(diff.*diff);
  	else
  		buffer(j,:)=(diff.*diff);
  	end;
  end;
  
  sigsq_new=reshape(diag(buffer*pold),[1,m])./d./Zold;
  
  idx=find(sigsq_new==0);
  sigsq_new(idx)=sigsq(idx);
  
  %keyboard;
  %%%%% p_new
  p_new=Zold./n;
  
 
  %%%%% iteration controlling block
  if(iteration>=iteration_limit+1)
  	go_on=0;
  end;
  
  if(iteration>1&abs((loglikelihood(iteration)-loglikelihood(iteration-1))/loglikelihood(iteration-1)*100)<loglikelihood_limit)
%      abs((loglikelihood(iteration)-loglikelihood(iteration-1))/loglikelihood(iteration-1)*100)
%      loglikelihood_limit
      
    	go_on=0;
  end;

  iteration=iteration+1;
  
  %%%%% updating p, mu and sigsq
  p=p_new;
  mu=mu_new;
  sigsq=sigsq_new;
  
end;


