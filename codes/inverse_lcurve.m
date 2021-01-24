function [reg_corner,rho,eta,reg_param,rho_c,eta_c] = inverse_lcurve(U,sm,b,varargin) 
%L_CURVE Plot the L-curve and find its "corner". 
% 
% [reg_corner,rho,eta,reg_param] = 
%                  l_curve(U,s,b,method) 
% 
% Plots the L-shaped curve of eta, the solution norm || x || or 
% semi-norm || L x ||, as a function of rho, the residual norm 
% || A x - b ||, for the following methods: 
%    method = 'Tikh'  : Tikhonov regularization   (solid line ) 
%
% The corresponding reg. parameters are returned in reg_param.  If no
% method is specified then 'Tikh' is default.  For other methods use plot_lc.
%
% Note that 'Tikh', 'tsvd' and 'dsvd' require either U and s (standard-
% form regularization) or U and sm (general-form regularization), while
% 'mtvsd' requires U and s as well as L and V.
% 
% If any output arguments are specified, then the corner of the L-curve 
% is identified and the corresponding reg. parameter reg_corner is 
% returned.  Use routine l_corner if an upper bound on eta is required. 
% 
% If the Spline Toolbox is not available and reg_corner is requested, 
% then the routine returns reg_corner = NaN for 'tsvd' and 'mtsvd'. 
%
% Reference: P. C. Hansen & D. P. O'Leary, "The use of the L-curve in 
% the regularization of discrete ill-posed problems",  SIAM J. Sci. 
% Comput. 14 (1993), pp. 1487-1503. 
%
% Per Christian Hansen, IMM, Sep. 13, 2001.
% fhlin, Dec. 12, 2005. 
% 

% Set defaults. 

npoints = 200;  % Number of points on the L-curve for Tikh and dsvd. 
smin_ratio = 16*eps;  % Smallest regularization parameter. 

prior=[];
reg_param=[];
V=[];

flag_log=0;
file_log=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'prior'
            prior=option_value;
        case 'reg_param'
            reg_param=option_value;
        case 'v'
            V=option_value;
        case 'flag_log'
            flag_log=option_value;
        case 'file_log'
            file_log=option_value;
    end;
end;


% Initialization. 
[m,n] = size(U); [p,ps] = size(sm); 
if (nargout > 0), locate = 1; else locate = 0; end 
beta = U'*b; beta2 = norm(b)^2 - norm(beta)^2; 
if (ps==1) 
    s = sm; beta = beta(1:p); 
else 
    s = sm(p:-1:1,1)./sm(p:-1:1,2); beta = beta(p:-1:1); 
end 
idx=find(s<eps);
xi = beta(1:p)./s; 

if(~isempty(prior))
    pr=V'*prior;
end;

eta = zeros(npoints,1); rho = eta; s2 = s.^2;

if(isempty(reg_param))
    reg_param(npoints) = max([s(p),s(1)*smin_ratio]); 
    ratio = (s(1)/reg_param(npoints))^(1/(npoints-1)); 
    for i=npoints-1:-1:1, reg_param(i) = ratio*reg_param(i+1); end 
end;

for i=1:npoints 
    f = s2./(s2 + reg_param(i)^2); 
    if(isempty(prior))
        eta(i) = norm(f.*xi); 
    else
        eta(i)=norm(f.*(xi-pr(1:p)));
    end;
    rho(i) = norm((1-f).*beta(1:p)); 
end 

%calculate curvature of l-curve
[reg_corner,rho_c,eta_c] = l_corner_fhlin(rho,eta,reg_param,U,sm,b,'tikh',[],'prior',prior,'v',V,'flag_log',flag_log,'file_log',file_log);

reg_param=reg_param';


return;

