function SEM = mod_index(x, xfix, SEM)

% FORMAT SEM = mod_index(x, xfix, SEM) 
% Calculate Gradients and Hessian to determine Lagrangian multipliers also
% known as modification indices
% ________________________________________________________________________
%
% Input Parameters:
%
% x        	- 1 x n vector of n free parameter Estimates
% xfix 		- 2 x n vector. xfix(1,:) = values
%		  		xfix(2,:) = parameter to fix
% SEM		- see spm_sem.m
%
% OUTPUT
% SEM		- updated array SEM
%
% Example : 	x    = [.6 .2 .8 .1 .5 .7]
%
%		ConX = [0 1 0;
%			0 0 0;
%			0 2 0];
%			
%		ConZ = [3 0 6;
%			0 4 0;
%			0 0 5];
%
% After substitution:
%		A    = [0 .6  0;
%			0  0  0;
%			0 .2  0];
%			
%		S    = [.8   0 .7;
%			 0  .1  0;
%			 0   0 .5];
%



% Implements SEM with ML Estimation
%-----------------------------------------------------------
% The implied covariance matrix is calculated according to
% Est = inv(I_A)*S*inv(I_A)';


for k = 1:size(SEM,2)
 
 Obs  = SEM(k).Cov;
 ConX = SEM(k).ConX;
 ConZ = SEM(k).ConZ;
 df   = SEM(k).df;
 Fil  = SEM(k).Fil;

 %Combine free and fixed parameters in x
 %-------------------------------------- 
 for f=1:size(xfix,2)
  x(xfix(2,f)) = xfix(1,f);	%fill in fixed parameters
 end

 %Set up A
 %--------
 F           = find(ConX);
 A    	     = zeros(size(ConX));
 f           = x(ConX(F));
 A(F)        = f;
 %Set up S
 %--------
 F           = find(ConZ);
 S    	     = zeros(size(ConZ));
 f           = x(ConZ(F));
 S(F)        = abs(f);        % Do not allow neg covariances


 I = eye(size(ConZ));

 
 %Calculate implied covariance matrix
 %-----------------------------------
 invI_A = inv(I-A);
 Est    = Fil*inv(I-A)*S*inv(I-A)'*Fil';
 
 %Calculate finite forward differences
 %------------------------------------
 pp= prod(size(A)) + prod(size(S));
 C = zeros([size(Est) pp]);
 of= prod(size(A));
 u = 1e-4;
 Sn= S;
 for d = 1:pp
  if d > of
   Sn = S;
   Sn(d-of) = S(d-of) + u;
  else
   An = A;
   An(d) = A(d) + u;
  end
  C(:,:,d) = (Fil*inv(I-An)*Sn*inv(I-An)'*Fil' - Est) / u;
 end
 
 %Calculate 1st order partial derivatives
 %---------------------------------------
 Pd = zeros(pp,1);
 for d = 1:length(Pd)
  Pd(d) = 0.5*trace(inv(Est)*(Est - Obs)*inv(Est)*C(:,:,d));
 end

 %Calculate 2nd order partial derivatives
 %---------------------------------------
 HS = zeros(pp,pp);
 for d = 1:pp
  %for e = 1:pp
  HS(d,d) = 0.5*trace(inv(Est)*C(:,:,d)*inv(Est)*C(:,:,d));
  %end
 end 

 %Calculate Modification indices
 %------------------------------
 L = zeros(1,pp);
 for d = 1:pp
  L(d) = 0.5*(df - 1)*Pd(d)'*inv(HS(d,d))*Pd(d);
 end

SEM(k).AL = reshape(L(1:of),size(A));
SEM(k).SL = reshape(L(of+1:pp),size(S));

end % for k=1:...










































