close all; clear all;

%create simulation
n_x=32;
n_y=100;
x=randn(n_x,1);
x(setdiff([1:n_x],[3 10]))=0;
x0=zeros(n_x,1);
A=randn(n_y,n_x);
%A=randn.*eye(32);
y=A*x;

n_l1_iteration=20;
R=ones(n_x,1);

for l1_idx=1:n_l1_iteration
    %init
    a=(A*diag(sqrt(R)))'*y;
    b(:,1)=zeros(size(x));
    p(:,1)=a;
    r(:,1)=a;
    
    for i=2:20
        if(i==2)
            p(:,i)=r(:,1);
        else
            ww=norm(r(:,i-1)).^2/norm(r(:,i-2)).^2;
            p(:,i)=r(:,i-1)+ww.*p(:,i-1);
            beta(i)=ww;
        end;
        
        %this step is usually implemented via direct calculation of A*x and
        %A'*y;
        xx=(A*diag(sqrt(R)))'*(A*diag(sqrt(R)))*p(:,i);
        
        %%% CG starts
        w=norm(r(:,i-1)).^2/(p(:,i)'*xx);
        alpha(i)=w;
        
        b(:,i)=b(:,i-1)+p(:,i).*w;
        r(:,i)=r(:,i-1)-xx.*w;
        %%% CG ends
        
    end;
    
    
    R=sqrt(eps+abs(b(:,end)).^2);
    R=R./(max(R(:)));
    RR(:,l1_idx)=R(:);
    l1_history(:,l1_idx)=b(:,end);
    
end;

l1_history=cat(2,l1_history,x);
imagesc(l1_history)
return;


% %power iteration to get the largest singular value
% tmp=randn(32,1);
% tmp=tmp./sqrt(sum(tmp.^2));
% 
% clear vv;
% vv(:,1)=tmp(:);
% for ii=2:100
%     w=A'*A*vv(:,ii-1);
%     vv(:,ii)=w./sqrt(sum(w.^2));
% end;
% 
% mean(w./vv(:,end))
% 
% [u,s,v]=svd(A);
% diag(s)'.^2
% 
% imagesc([b,x])