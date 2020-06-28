function [s,A]=fmri_ica(x,varargin)
%hw6_ica	Independent Component Analysis 
%
%[s,A]=fmri_ica(x,learning_rate, A0, iteration_limit, output_file, sphere_flag)
%
%x: 	d*n data matrix; d channels and n observation
%learning_rate: the learning rate for natural gradient ascending algorithm to maximize likehood (default: 0.5)
%A0: 	the initialize (default: identity matrix)
%iteration_limit: the maximal iteration limit without convergency
%output_file: output file name for ICA matlab data (default: ica.mat)
%sphere_flag: the flag to enable/disable sphering of raw data before ICA, 
%	sphere_flag=1;	 enable (default)
%	sphere_flag=0;	 disable
%
%s: 	d*n data matrix; independent components from x
%
%
%   writtten by fhlin@nov. 15, 1999

close all;
x0=x;

[d,n]=size(x);

A=eye(d);		%initialized A
eta=0.5;		%learning rate
fn='ica';		%default output file name
iteration_limit=80;
eta_limit=1e-6;
sphere=1;

if(nargin==2)
	eta=varargin{1};
end;


if(nargin==3)
	A=varargin{2};	
	eta=varargin{1}(1);
end;

if(nargin==4)
	iteration_limit=varargin{3}(1);
	A=varargin{2};	
	eta=varargin{1}(1);
end;


if(nargin==5)
	fn=char(varargin{4});
	iteration_limit=varargin{3}(1);
	A=varargin{2};	
	eta=varargin{1}(1);
end;

if(nargin==6)
	sphere=varargin{5};
	fn=char(varargin{4});
	iteration_limit=varargin{3}(1);
	A=varargin{2};	
	eta=varargin{1}(1);
end;


A0=A;
eta=eta/n; 		%normalizing learnig rate
stop_likelihood=1/n;	%stoping for iteration
marginal_likelihood=stop_likelihood+1;


fine_tune_times=3;	%3-layer nested ICA learning rate fine tune

%%%%%%%%%%% sphering the data %%%%%%%%%%%%%%%
sphere=0;
if(sphere==1)

	disp('sphering the raw data...');
	Ws=2.*inv(sqrtm(x*x'));  %ref. McKeown. et. al. PNAS 1998 (95) pp. 803-810

	x=Ws*x0;
	disp('end of sphering');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



A=A0;
redo=1;
while(redo)

for fine_tune=1:fine_tune_times
	disp('');
	str=sprintf('[%d] Fine Tuning...',fine_tune);
	disp(str);
	disp('');
	interrupt=0;

	while(interrupt==0)
		str=sprintf('learning rate=%e',eta*n);
		disp(str);
		stop=0;
		iteration=0;
		likelihood=0;
		decline=0;
		interrupt=0;
		likelihood=[];


		while(stop==0)
		
			s=A*x; %get independent components

			A_mat(iteration+1,:,:)=A; %save current unmixing matrix
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%    get the log likelihood : valid for logistic only!!
		
			
			loglike=sum(sum( -s-2*log(1+exp(-s)) )) + n*log(abs(det(A)));
			
			
			if (loglike>0) %log-likelihood must be less than zero.
				stop=1;
				eta=eta/2;
			end;
			if(isnan(loglike)|isinf(loglike)) %log-likelihood must be finite.
				stop=1;
				eta=eta/2;
			end;

			%%%%%%%%    
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			

			likelihood(iteration+1)=loglike/n/d;	%get the likelihood for logistic function


			iteration=iteration+1;
			

			%updating unmixing matrix when learning rate is larger than the limit
			if((eta*n)>=eta_limit)
						
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%%%%%%%%    get the vector of partial directive of log likelihood : valid for logistic only!!
				phi=1-2./(1+exp(-s));
				%%%%%%%%    
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

							
				A=A+eta.*(n.*A+phi*s'*A);	%natural gradient ascending method
				%A=A-eta.*(n.*A+n.*phi*s'*A);	%natural gradient ascending method
			else
				stop=1;
				interrupt=1;
			end;
			
			%calculate marginal log-likelihood
			if(iteration>1)
				marginal_likelihood(iteration)=(likelihood(iteration)-likelihood(iteration-1))/likelihood(iteration-1)*100*-1;
			else
				marginal_likelihood(iteration)=stop_likelihood+1;
			end;
	
			%display log-likelihood and marginal log-likelihood
			if(iteration>1)
				s=sprintf('iteration[%d]: log(normalized likelihood)=[%f]; marg likelihood=[%.3f%%]', iteration,likelihood(iteration), marginal_likelihood(iteration));
			else
				s=sprintf('iteration[%d]: log(normalized likelihood)=[%f];',iteration,likelihood(iteration));
			end;
			disp(s);
		
			%check if log-likelihood converges
			if(abs(marginal_likelihood(iteration))<=stop_likelihood)
				stop=1;
				interrupt=1;
			end;
			
			%check if iteration reaches limit
			if(iteration==iteration_limit)
				stop=1;
				interrupt=1;
			end;
			
			%check if log-likelihood is decreasing
			if(iteration>=4)
				mm=marginal_likelihood(iteration-3:iteration);
				if(length(find(mm<0))>3)
					stop=1;
					interrupt=1;
				end;
			end;
		end;
	
		if(length(likelihood)>0)
		
			max_likelihood=1;
			while(max_likelihood>0)
				[max_likelihood,idx]=max(likelihood);
				if(max_likelihood>0)
					likelihood(idx)=-100000000;
				end;
			end;
			
			A=reshape(A_mat(idx,:,:),[d,d]);
		else
			A=reshape(A_mat(1,:,:),[d,d]);
		end;

	end;

	max_likelihood=1;
	while(max_likelihood>0)
		[max_likelihood,idx]=max(likelihood);
		if(max_likelihood>0)
			likelihood(idx)=-100000000;
		end;
	end;
			
	A=reshape(A_mat(idx,:,:),[d,d]);
	eta=eta/10;

end;

	if(A==A0)
		A0=A;
		A=A+A.*rand(size(A)).*(0.1);
		disp(' ');
		disp('perturbation...');
		disp(' ');
	else
		redo=0;
	end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%output to figure

marginal_likelihood(1)=0;
subplot(211);
plot(likelihood);
title('normalized likelihood');
xlabel('iteration');
ylabel('normalized log(likelihood)');
grid;

subplot(212);
plot(marginal_likelihood);
title('change of likelihood(in %)');
xlabel('iteration');
ylabel('change of likelihood(in %)');
grid;

%output to figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s=A*x;

save(fn, 'A','s', 'x', 'x0', 'likelihood', 'marginal_likelihood');



disp('done');
