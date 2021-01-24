function [x,x_history,cost_history]=pmri_cs_cg(x,m,pmri_cs_obj)

%initialization
[grad,cost,cost_res,cost_sparse] = pmri_cs_grad(x, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
dx = -(grad);


%  dt=1e-0;
%  dt=+0.01;
%  [grad1,cost1,cost_res1,cost_sparse1] = pmri_cs_grad(x+dx.*dt, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
%  fprintf('cost =%2.2e (res: %2.2e\t sparsity %2.2e)\n',cost,cost_res,cost_sparse);
%  fprintf('cost new=%2.2e (res: %2.2e\t sparsity %2.2e)\n',cost1,cost_res1,cost_sparse1);
% 
%  x=x+dt.*dx;
%  [grad,cost,cost_res,cost_sparse] = pmri_cs_grad(x, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
%  dx=-(grad);
%  
%  
% keyboard;


t0=pmri_cs_obj.t0;

pmri_cs_obj.cg_count=0;
flag_cont=1;
while (pmri_cs_obj.cg_count < pmri_cs_obj.cg_max_iterations&flag_cont)
    if(pmri_cs_obj.flag_display)
        fprintf('CG [%d]',pmri_cs_obj.cg_count);
    end;
    
    %backtracking line-search
    t=t0;
    
  
    [grad_new,cost_new,cost_res_new,cost_sparse_new] = pmri_cs_grad(x+t.*dx, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
    cost_new0=cost_new;

  
    %fprintf('cost_new=%3.3f (%3.3f, %3.3f) < cost=%3.3f \n',cost_new,cost_res_new,cost_sparse_new,cost-pmri_cs_obj.alpha*t*abs(grad(:)'*dx(:)));
    lc=1;
    lc_max=10;
    if(pmri_cs_obj.flag_display) fprintf('\tline search...\n'); end;
    lc_adjust=0;
    lc_adjust_max=3;
    while(cost_new>cost+pmri_cs_obj.alpha*t*real(grad(:)'*dx(:))&(lc_adjust<lc_adjust_max))
        t=t*pmri_cs_obj.beta;
        [grad_new,cost_new, cost_res_new, cost_sparse_new] = pmri_cs_grad(x+t.*dx, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
        
        ddx=t.*grad_new;
    
        if(pmri_cs_obj.flag_display)
            fprintf('\tt=%1.1e\tcost_new=%3.3e (%3.3e, %3.3e) < cost=%3.3e (max. update=%1.1e avg. update=%1.1e)\n',t,cost_new,cost_res_new,cost_sparse_new,cost+pmri_cs_obj.alpha*t*real(grad(:)'*dx(:)),max(abs(ddx(:))),mean(abs(ddx(:))));
        end;
        lc=lc+1;
        if(lc==lc_max)
            lc_adjust=lc_adjust+1;
            pmri_cs_obj.alpha=pmri_cs_obj.alpha./10;
            t=t0*0.1;
            [grad_new,cost_new,cost_res_new,cost_sparse_new] = pmri_cs_grad(x+t.*dx, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);

            cost_new=cost_new0;
            
            if(pmri_cs_obj.flag_display)
                fprintf('max. line search failed!\n');
                fprintf('alpha now..[%2.2e]\n',pmri_cs_obj.alpha);
                fprintf('t now...[%2.2e]\n',t);
            end;
            
            lc=1;
        end;
    end;
    if(lc>=lc_max)
        if(pmri_cs_obj.flag_display)
                fprintf('max. line search failed!\n');
        end;
    end;

    if pmri_cs_obj.cg_count > 2
        t0 = t0 * pmri_cs_obj.beta;
    end
    if pmri_cs_obj.cg_count<1
        t0 = t0 / pmri_cs_obj.beta;
    end

    %update
    x=x+t.*dx;
    %imagesc(abs(x)); keyboard;
    
    if(pmri_cs_obj.cg_count==0)
        x_history=zeros([size(x),pmri_cs_obj.cg_max_iterations]);
    end;
    x_history(:,:,pmri_cs_obj.cg_count+1)=x;
    
    if(pmri_cs_obj.flag_archive_history)
        save(pmri_cs_obj.file_archive_history,'x','x_history','pmri_cs_obj');
    end;
    
    [grad_new,cost_new,cost_res_new,cost_sparse_new] = pmri_cs_grad(x, m, pmri_cs_obj,'A_func',pmri_cs_obj.A_func,'A_h_func',pmri_cs_obj.A_h_func);
    %fprintf('updated cost_new=%3.3f (%3.3f, %3.3f) \n',cost_new,cost_res_new,cost_sparse_new);
    
    gamma=norm(grad_new(:)).^2./norm(grad(:)).^2;
    %gamma=(grad_new(:)'*(grad_new(:)-grad(:)))./norm(grad(:)).^2;
    %gamma=max([0 gamma]);
    
     dx=-(grad_new)+gamma.*dx;
     %dx=-(grad_new);
% 
%     grad=grad_new;
%     cost=cost_new;
%     
%     
%     keyboard;
            
   
    pmri_cs_obj.cg_count=pmri_cs_obj.cg_count+1;

    cost_history(pmri_cs_obj.cg_count)=cost;
    if(pmri_cs_obj.flag_display)
       fprintf('\n');
    end;
    
    %check convergence
    if(pmri_cs_obj.cg_count>5)
        if((-cost_history(pmri_cs_obj.cg_count)+cost_history(pmri_cs_obj.cg_count-1))./cost_history(pmri_cs_obj.cg_count-1)<1e-6)
            flag_cont=0;
        end;
    end;
end;

% x=x.*pmri_cs_obj.I;
% 
% for i=1:size(x_history,3)
%     x_history(:,:,i)=x_history(:,:,i).*pmri_cs_obj.I;
% end;

return;
