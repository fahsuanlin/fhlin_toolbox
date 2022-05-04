function [grad, cost, cost_res, cost_sparse, grad_res]=pmri_cs_grad(x,m,pmri_cs_obj,varargin);
%  pmri_cs_grad      calculate the gradient of solution x in CS pMRI
%  using explicit or implicit forward matrix A, spasifying matrix S and measurement m.
%
%   y=grad(f(x))
%
% [grad, res]=pmri_cs_grad(x,[option, option_value]...);
%
% x: the source vector
%
% grad: gradieint vector
% res: measurement residual vector
%
% fhlin@sep 11 2009
%

S=[];
S_func='';
A=[];
A_func='pmri_cs_forward_func_default';
A_h_func='pmri_cs_forward_h_func_default';

S=[];
S_func='pmri_cs_sparsify_func_default';
S_h_func='pmri_cs_sparsify_h_func_default';

TV=[];
TV_func='pmri_cs_TV_func_default';
TV_h_func='pmri_cs_TV_h_func_default';

res=[];
grad=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'a' %explicit forward solution/matrix
            A=option_value;
        case 'a_func' %implicit forward solution/matrix
            A_func=option_value;
        case 'a_h_func' %hermittian of implicit forward solution/matrix
            A_h_func=option_value;
        case 's' %explicit sparsifying matrix
            S=option_value;
        case 's_func' %implicit sparsifying matrix
            S_func=option_value;
        case 's_h_func' %hermittian of implicit sparsifying matrix
            S_h_func=option_value;
        case 'tv' %explicit TV matrix
            TV=option_value;
        case 'tv_func' %implicit TV matrix
            TV_func=option_value;
        case 'tv_h_func' %hermittian of implicit TV matrix
            TV_h_func=option_value;
        otherwise
            fprintf('unkown option [%s]\n',option);
            fprintf('error!\n');
            return;
    end;
end;

%gradient for model residuals
if(~isempty(A)) %explicitly given A
    [y, res]=pmri_cs_forward(x,pmri_cs_obj,'A',A,'m',m);
    grad_res=2.*A'*res;
else %implicitly given A by functions
    [y, res]=pmri_cs_forward(x,pmri_cs_obj,'A_func',A_func,'m',m);
    eval(sprintf('[grad_res, Eh]=%s(res,pmri_cs_obj);',A_h_func));
    grad_res=2.*(grad_res);
    
%     load test.mat;
%     rr=E*x(:)-m{1}(:);
%     gg=2.*(E')*rr;
%     cost_1(1)=real(res(:)'*res(:));
%     
%     keyboard;
end;


if(pmri_cs_obj.l1_reg>0)
    %gradient for L1 sparsity
    if(~isempty(S)) %explicitly given S
        [y]=pmri_cs_sparsify(x,pmri_cs_obj,'S',S);
        grad_sparse=S'*(1./sqrt(abs(y).^2+cs_obj.mu)).*y;
        sparse_coeff=y;
    else %implicitly given S by functions
        [y,pmri_cs_obj]=pmri_cs_sparsify(x,pmri_cs_obj,'S_func',S_func);
        sparse_coeff=y;
        y=(1./sqrt(abs(y).^2+pmri_cs_obj.mu)).*y;
        eval(sprintf('grad_sparse=%s(y,pmri_cs_obj);',S_h_func));
    end;
else
    sparse_coeff=0;
    cost_sparse=0;
    grad_sparse=0;
end;

if(pmri_cs_obj.TV_reg>0)
    %gradient for TV
    if(~isempty(TV)) %explicitly given TV
        [y]=pmri_cs_TV(x,pmri_cs_obj,'TV',TV);
        grad_TV=TV'*(1./sqrt(abs(y).^2+cs_obj.mu)).*y;
        TV_coeff=y;
    else %implicitly given TV by functions
        [y]=pmri_cs_TV(x,pmri_cs_obj,'TV_func',TV_func);
        TV_coeff=y;
        y=(1./sqrt(abs(y).^2+pmri_cs_obj.mu)).*y;
        eval(sprintf('grad_TV=%s(y,pmri_cs_obj);',TV_h_func));
    end;
else
    TV_coeff=0;
    cost_TV=0;
    grad_TV=0;
end;


grad = grad_res + pmri_cs_obj.l1_reg*grad_sparse + pmri_cs_obj.TV_reg*grad_TV;

%cost= res(:)'*res(:) + pmri_cs_obj.l1_reg*sum(sum((conj(sparse_coeff).*sparse_coeff + pmri_cs_obj.mu).^(1/2))) + pmri_cs_obj.TV_reg*sum(abs(TV_coeff(:))) ;
if(iscell(res))
	r=[];
	for i=1:length(res)
		r=cat(1,r,res{i}(:));
	end;
	res=r;
end;
cost= res(:)'*res(:) + pmri_cs_obj.l1_reg*sum(abs(sparse_coeff(:))) + pmri_cs_obj.TV_reg*sum(abs(TV_coeff(:))) ;
cost_res=res(:)'*res(:);
cost_sparse=sum(abs(sparse_coeff(:)));

return;
