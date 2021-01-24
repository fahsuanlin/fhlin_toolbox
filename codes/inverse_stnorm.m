function [W,cost_total,cost_likelihood,cost_prior]=inverse_stnorm(W,A,Y,varargin)
%
% [W,last_cost_total,last_cost_likelihood,last_cost_prior]=inverse_stnorm(W,A,Y,[p,lambda])
%
% W: inverse operator;
% cost_total: history of total cost (with lambda weighted last_cost_likelihood and last_cost_prior)
% cost_likelihood: history of likelihood cost (difference between predicted forward model and realistic measurements)
% cost_prior: history of prior cost (parsimonious spatiotempral norm as prior constraint; not lambda weighted).
%
% A: forward operator;
% Y: measurement
% l_s: spatial norm (default: 2)
% l_t: temporal norm (default: 2)
% lambda: weighting for likelihood and prior (default: 1)
% alpha: momentum optimization; weight for the grand-father inverse operator (default: 0; no momentum)
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%		STNORM init			%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p_s=1;
p_t=2;
lambda=1;
alpha=0;
step_percent=1e-8;
nperdip=1;
F=[];
X=[];

cost_total={};
cost_likelihood={};
cost_prior={};

dcost_total={};
dcost_likelihood={};
dcost_prior={};

grad_history={};
dgrad_history={};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%		CG init				%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%default values for CG
i_max=100; %maximal number of iteration
j_max=10;  %maximal number of iteration in Seccant's method
epsilon=0.0001; %convergence threshold

flag_bookkeeping_cost=1;
flag_bookkeeping_cost_detail=0;
flag_bookkeeping_arg=0;
flag_bookkeeping_arg_detail=0;



if(nargin>3)
	for i=1:length(varargin)/2
		option_name=varargin{(i-1)*2+1};		
		option_value=varargin{i*2};

		switch lower(option_name)
		case 'p_s'
			p_s=option_value;
		case 'p_t'
			p_t=option_value;
		case 'lambda'
			lambda=option_value;
		case 'alpha'
			alpha=option_value;
		case 'iteration'
			iteration=option_value;
		case 'step_percent'
			step_percent=option_value;
		case 'nperdip'
			nperdip=option_value;
		case 'f'
			F=option_value;
		case 'x'
			X=option_value;
		otherwise
  		        fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
			return;
		end;
	end;
end;




%%%%%% calculate the gradient %%%%%%%%%%

%set initial step to be RMS of W
step=ones(size(W)).*sqrt(sum(sum(W.^2))./prod(size(W))).*(step_percent./100);	
%step=ones(size(W)).*sqrt(sum(sum(W.^2))).*(step_percent./100);	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%		START OF CG			%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('CG starts...\n');
idx=0;
i=0;
k=0;
r=-1.*get_grad(W,A,Y,p_s,p_t,nperdip,F,X,lambda);

W0=W;

%preconditioning....
% M should be the 2nd order derivative (Hessian) of the cost function.
% Here I ignore this preconditioning and set it as an identity.
% 
M=eye(size(r,1));


%s=inv(M)*r;
s=r;
	
d=s; 

%guessing the initial value in Secant method
%sigma_0=mean(mean(abs(d)))./1000000;
sigma_0=step_percent;

delta_new=sum(sum(r.*d));
delta_0=delta_new;

	
if(flag_bookkeeping_cost)	
  	[cost_total{i+1}, cost_likelihood{i+1}, cost_prior{i+1}]=get_cost(W,A,Y,p_s,p_t,nperdip,F,X,lambda);
end;	
if(flag_bookkeeping_cost_detail)	
  	[dcost_total{i+1}, dcost_likelihood{i+1}, dcost_prior{i+1}]=get_cost(W,A,Y,p_s,p_t,nperdip,F,X,lambda);
end;
if(flag_bookkeeping_arg)	W_history{i+1}=W;	end;
if(flag_bookkeeping_arg_detail)	dW_history{idx+1}=W;		end;

while (i<i_max)&(delta_new>=epsilon^2*delta_0)
	fprintf('\nCG iteration [%d]...\n',i);
	fprintf('Norm_s=%2.2f\tNorm_t=%2.2f\t,lambda=%2.2f\t\n',p_s,p_t,lambda);
	if(i>0)
		fprintf('previous cost=%6.6e\n',cost_total{i});
	end;

	fprintf('Difference of W=[%e]\n',sum(sum(abs(W-W0))));
	
	j=0;
	delta_d=sum(sum(d.*d));
	alpha=-1.*delta_0;
     
	k_prev=sum(sum(get_grad(W+sigma_0.*d,A,Y,p_s,p_t,nperdip,F,X,lambda).*d));
     
	while ((j<j_max)&(alpha^2*delta_d>epsilon^2)|j==0)
		fprintf('Secant method iteration [%d]...\n',j);

		k=sum(sum(get_grad(W,A,Y,p_s,p_t,nperdip,F,X,lambda).*d));
		alpha=alpha*k/(k_prev-k);
			
		%x=x+alpha.*d;

		W=W+alpha.*d;
			
		k_prev=k;
		j=j+1;

		idx=idx+1;
               
		%book keeping of cost and grad
		if(flag_bookkeeping_cost_detail)	
  			[dcost_total{i+1}, dcost_likelihood{i+1}, dcost_prior{i+1}]=get_cost(W,A,Y,p_s,p_t,nperdip,F,X,lambda);
		end;
		if(flag_bookkeeping_arg_detail)	dW_history{idx+1}=W;		end;
              
	end;
	fprintf('Secant method convergence!\n');
			

	r=-1.*get_grad(W,A,Y,p_s,p_t,nperdip,F,X,lambda);
	delta_old=delta_new;
	delta_mid=sum(sum(r.*s));
	  
	%calculate the preconditioner M again
	% ignore here...
	M=eye(size(r,1));
	%s=inv(M)*r;
	s=r;
			
	delta_new=sum(sum(r.*s));
          
	beta=(delta_new-delta_mid)/delta_old;
	k=k+1;

	if (beta<=0)
		fprintf('PR CG fails!\n');
		d=s;
		k=0;
	else
		fprintf('PR CG succeeds!\n');
		d=s+beta.*d;
	end;
          
		
	%book keeping of cost and grad          
	if(flag_bookkeeping_arg)	W_history{i+1}=W;	end;
	if(flag_bookkeeping_cost)	
		[cost_total{i+1}, cost_likelihood{i+1}, cost_prior{i+1}]=get_cost(W,A,Y,p_s,p_t,nperdip,F,X,lambda);
	end;	
		
	i=i+1;
	   
end;
fprintf('CG convergence!!\n\n');


fprintf('\nST-NORM INVERSE OPERATOR DONE!!\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%		END OF CG			%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
return;


function [output]=get_grad(W,A,Y,p_s,p_t,nperdip,F,X,lambda)

	%only succesful update requires new gradient!
	fprintf('prior gradient...');
	grad_prior_new=prior_grad(W,Y,p_s,p_t,nperdip,F,X);

	fprintf('likelihood gradient...');
	grad_likelihood_new=measurement_grad(W,A,Y);

	fprintf('\n');
	
	output=grad_likelihood_new+lambda*grad_prior_new;
	%grad_total_new=1/lambda*grad_likelihood_new+grad_prior_new;
	
return;



function [output,cost_likelihood,cost_prior]=get_cost(W,A,Y,p_s,p_t,nperdip,F,X,lambda)
   	
   	fprintf('prior cost...');
   	cost_prior=prior_error(W,Y,p_s,p_t,nperdip,F,X);
   	fprintf('likelihood cost...');
   	
   	fprintf('\n');
   	
   	cost_likelihood=measurement_error(W,A,Y,X);

   	%output=cost_likelihood+lambda*cost_prior;
   	output=1/lambda*cost_likelihood+cost_prior;

return;




function [error]=measurement_error(W,A,Y,varargin)

	X=[];
	if(nargin==4)
		X=varargin{1};
	end;
		
	
	n_time=size(Y,2);
	n_dipole=size(A,2);

	if(isempty(X))
		Y_est=A*W*Y;
	else
		Y_est=A*X;
	end;
		
	error=sqrt(sum(sum((Y-Y_est).^2))./n_time./n_dipole);


return;

function [error]=prior_error(W,Y,p_s,p_t,nperdip,F,varargin)
	
	X=[];
	if(nargin==7)
		X=varargin{1};
	end;
	
	
	if(nperdip==1)
		if(isempty(F))
			F=ones(size(W,1),1);
		end;
	
		n_time=size(Y,2);
		n_dipole=size(W,1);
	
		if(isempty(X))
			X=W*Y;
		end;
		
		T1=(sum(abs(X).^p_t,2)./n_time).^(p_s/p_t);
		error=(sum(T1.*(F.^p_s))./n_dipole).^(1/p_s);
	
	elseif(nperdip==3)
		if(isempty(F))
			F=ones(size(W,1),1);
		end;
	
		n_time=size(Y,2);
		n_dipole=size(W,1);
	
		if(isempty(X))
			X=W*Y;
		end;
		
		%collapse directional components by RMS 
		X=reshape(X,[3,size(X,1)/3,size(X,2)]);
		X=sqrt(squeeze(sum(X.^2,1)));
		
		T1=(sum(abs(X).^p_t,2)./n_time).^(p_s/p_t);
		error=(sum(T1.*(F.^p_s))./n_dipole).^(1/p_s);
		
	end;
return;


function [grad]=measurement_grad(W,A,Y,varargin)

	n_time=size(Y,2);
	n_dipole=size(A,2);
	
	grad=A'*(A*W+eye(size(A,1))).*2./n_time./n_dipole;

return;


function [grad]=prior_grad(W,Y,p_s,p_t,nperdip,F,varargin)

	X=[];
	if(nargin==7)
		X=varargin{1};
	end;


	if(nperdip==3)
		W=reshape(W,[3,size(W,1)/3,size(W,2)]);
		W=sqrt(squeeze(sum(W.^2,1)));		
	end;
	
	if(isempty(F))
		F=ones(size(W,1),1);
	end;

	n_time=size(Y,2);
	n_dipole=size(W,1);
	n_sensor=size(W,2);

	theta=(n_dipole.^(-1/p_s))*(n_time.^(-1/p_t));

	if(isempty(X))
		X=W*Y;
	end;

   
	T1=sum((sum(abs(X).^p_t,2).^(p_s/p_t)).*(F.^p_s));
	T1_prime=theta/p_s*(T1^(1/p_s-1));
	T2_prime=p_s/p_t.*repmat((sum(abs(X).^p_t,2).^(p_s/p_t-1)).*(F.^p_s),[1,n_sensor]);
	T3_prime=p_t.*((abs(X).^(p_t-1)).*sign(X)*Y');
	
	
	grad=T1_prime.*T2_prime.*T3_prime;
	
	if(nperdip==3)
		ndip=size(grad,1);
		nsensor=size(grad,2);
		grad=shiftdim(reshape(repmat(grad,[1,3]),[ndip,nsensor,3]),2);
	end;
return;
