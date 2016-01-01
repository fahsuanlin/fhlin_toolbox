close all; clear all;
     
E=[0 1 j; 3 0 1; 0 0 1];
x=[2 3 1]';

E=randn(10,8);
x=randn(8,1)

y=E*x;

a=E'*y;

b(:,1)=zeros(length(x),1);
p(:,1)=a;
r(:,1)=a;

%regularization parameter lambda and regularization matrix D

lambda=0.1;

D=speye(length(x));

lambda2=0.05;

M=randn(length(x),length(x));

for iteration_idx=2:10
        if(iteration_idx==2)
            p(:,iteration_idx)=r(:,1);
        else
            ww=sum(sum(abs(r(:,iteration_idx-1)).^2))/sum(sum(abs(r(:,iteration_idx-2)).^2));
            p(:,iteration_idx)=r(:,iteration_idx-1)+ww.*p(:,iteration_idx-1);
        end;
        
        tmp=E*p(:,iteration_idx);
    
        tmp=E'*tmp;
        
        tmp=tmp+lambda*D'*D*p(:,iteration_idx)+lambda2*M'*M*p(:,iteration_idx);
        
        %%% CG starts
        q=tmp;
        w=sum(sum(abs(r(:,iteration_idx-1)).^2))/sum(sum(conj(p(:,iteration_idx)).*q));
        b(:,iteration_idx)=b(:,iteration_idx-1)+p(:,iteration_idx).*w;
        r(:,iteration_idx)=r(:,iteration_idx-1)-q.*w;
end;

b(:,end)

(E'*E+lambda*D'*D++lambda2*M'*M)\E'*y