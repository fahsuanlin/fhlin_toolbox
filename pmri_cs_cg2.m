function [x_recon,x,cost]=pmri_cs_cg2(x,m,pmri_cs_obj)

%initialization
[g,cost(1),cost_res(1),cost_sparse(1)] = pmri_cs_grad(x, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
% load test.mat;
% res=E*x(:)-m{1}(:);
% gg=2.*(E')*res;
% cost_1(1)=real(res(:)'*res(:));


t=1;
s=1;
alpha=1e-2;
n_iteration=20;

for i=1:n_iteration
    fprintf('iteration [%d] of [%d]...',i,n_iteration);
    %calculate total cost of a 'guess' solution by a step t
    [dummy,c,c_res,c_sparse] = pmri_cs_grad(x(:,:,end)-g.*t, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
    %xx=x(:,:,end);
    %rr=E*(xx(:)-g(:).*t.*s)-m;
    %c=real(rr(:)'*rr(:));
    c=c+alpha*t*real(g(:)'*g(:));


    %if cost of the new iteration is not smaller than the previous one; try
    %to reduce the step size
    counter=1;

   while(c>cost(end))
        fprintf('*');
        t=t.*0.2;

        %new total cost
        [dummy,c,c_res,c_sparse] = pmri_cs_grad(x(:,:,end)-g.*t, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
        %xx=x(:,:,end);
        %rr=E*(xx(:)-g(:).*t.*s)-m;
        %c=real(rr(:)'*rr(:));
        c=c+alpha*t*real(g(:)'*g(:));

        if(counter>100)
            keyboard;
        end;
        counter=counter+1;
    end;

    %update
    x(:,:,end+1)=x(:,:,end)-reshape(g,[size(x,1),size(x,2)]).*t;
    cost(end+1)=c;
    ng0 = norm(g(:));
    g0=g;
    
    [g1,c,c_res,c_sparse] = pmri_cs_grad(x(:,:,end), m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
    %xx=x(:,:,end);
    %rr=E*(xx(:))-m;
    %g1=2.*(E')*rr(:);

    gam = (norm(g1(:))/norm(g0(:))).^2;
    gam=(g1(:)'*(g0(:)-g1(:)))/(g0(:)'*g0(:));
    
    g = g1 + gam*g;
    %g = g1;


    t=1 ;
    fprintf('\n');

end;
x_recon=x(:,:,end);



return;
