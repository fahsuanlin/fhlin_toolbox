function [f,C]=sem_obj(val_free,val_fix,idx_free, idx_fix, a,s,F,covv,varargin)
% sem_obj   Objective function to be minimized in SEM path coefficients
%
% f=sem_obj(val_free, val_fix,a,s,covv)
%
% val_free: free path coefficients (1*p) row vector for p paths
% val_fix: free path coefficients (1*(n-p)) row vector for  n-p paths
% a: m*m matrix for uni-directional paths between m nodes. (from) in columns and (to) in rows.
% s: m*m mstrxi for bidirectional paths and auto-covariance.
% covv: observed m*m covariance matrix from m nodes.
%
% fhlin@aug. 26, 2002


obj_type='ml';


if(nargin>8)
	for i=1:ceil(length(varargin)/2)
		option=varargin{i*2-1};
		option_value=varargin{i*2};

		switch lower(option)
		case 'obj_type'
			obj_type=option_value;
		end;
	end;
end;


A=zeros(size(a));
S=zeros(size(s));

val(idx_free)=val_free;
val(idx_fix)=val_fix;

for i=1:max(max(a))
    idx=find(a==i);
    A(idx)=val(a(idx));
end;
for i=1:max(max(s))
    idx=find(s==i);
    S(idx)=val(s(idx)).^2;
end;

%keyboard;

val(idx_free)=val_free;
val(idx_fix)=val_fix;

inv_eye_A=inv(eye(size(A,1))-A);

%C=F*inv_eye_A*S*inv_eye_A'*F';
C=inv_eye_A*S*inv_eye_A';

Res = covv-C;

p = size(covv,1);

%Maximal likelihood 
if(strcmp('ml',obj_type)) 

 %   C
 %   det(C)
 %   det(covv)
	%f = log(det(C))+trace(covv*det(C))-log(det(covv))-p;
	V=pinv(C);
	f=0.5.*trace((covv-C)*V).^2;
%    keyboard;
end;

%Ordinary least square (OLS)
if(strcmp('ols',obj_type)) 
	V=eye(size(C,1));
	f=0.5.*trace((covv-C)*V).^2;
end;

%Generalized least square (GLS)
if(strcmp('gls',obj_type)) 
	V=inv(covv);
	f=0.5.*trace((covv-C)*V).^2;
end;

return;


