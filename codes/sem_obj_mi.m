function [mi, pars, f,C]=sem_obj(val_free,val_fix,idx_free, idx_fix, a,s,F,covv, dof, varargin)
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
mi_eta=1e-4;

if(nargin>8)
    for i=1:ceil(length(varargin)/2)
        option=varargin{i*2-1};
        option_value=varargin{i*2};

        switch lower(option)
            case 'obj_type'
                obj_type=option_value;
                if(~strcmp(obj_type,'ml'))
                    fprintf('Modificaiton index is only valid for ML estimator!\n');
                    obj_type='ml';
                end;
            case 'mi_eta'
                mi_eta=option_value;
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

val(idx_free)=val_free;
val(idx_fix)=val_fix;

inv_eye_A=inv(eye(size(A,1))-A);

C0=inv_eye_A*S*inv_eye_A';
C_null=S;

Res0 = covv-C0;

p = size(covv,1);


%Maximal likelihood
if(strcmp('ml',obj_type))
    f0 = log(det(C0))+trace(covv*inv(C0))-log(det(covv))-p;
    f_null=log(det(C_null))+trace(covv*inv(C_null))-log(det(covv))-p;
end;

chi_null=(dof-1)*f_null;

A0=A;

zero_path_idx=find(a==0);
for idx=1:length(zero_path_idx)
    A=A0;
    path_avg=mean(abs(val(idx_free)));

    A(zero_path_idx(idx))=mi_eta.*path_avg;

    inv_eye_A=inv(eye(size(A,1))-A);

    C=inv_eye_A*S*inv_eye_A';

    C_l=(C-C0)./mi_eta;

    Res = covv-C;

    p = size(covv,1);

    %Maximal likelihood
    if(strcmp('ml',obj_type))
        f(idx) = log(det(C))+trace(covv*inv(C))-log(det(covv))-p;
    end;

    % modification index
    g(idx)=0.5.*trace(inv(C0)*(C0-covv)*inv(C0)*C_l);
    k(idx)=0.5.*trace(inv(C0)*C_l*inv(C0)*C_l);
    mi(idx)=0.5.*g(idx).*g(idx)./k(idx);

    chi(idx)=(dof-1)*f(idx);

    %parsimonious index
    qq=length(idx_free)+1;
    kk=p*(p-1)/2;
    pars(idx)=((chi_null/kk)-(chi(idx)/(kk-qq)))/(chi_null/kk);
end;

return;


