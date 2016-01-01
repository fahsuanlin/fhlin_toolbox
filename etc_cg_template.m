close all; clear all;

%create simulation
x=randn(32,1);
x0=zeros(32,1);
A=randn(48,32);
y=A*x;


%init
a=A'*y;
b(:,1)=zeros(size(x));
p(:,1)=a;
r(:,1)=a;

for i=2:20
    if(i==2)
        p(:,i)=r(:,1);
    else
        ww=norm(r(:,i-1)).^2/norm(r(:,i-2)).^2;
        p(:,i)=r(:,i-1)+ww.*p(:,i-1);
    end;
        
    %this step is usually implemented via direct calculation of A*x and
    %A'*y;
    xx=A'*A*p(:,i);
    
    %%% CG starts
    w=norm(r(:,i-1)).^2/(p(:,i)'*xx);
    b(:,i)=b(:,i-1)+p(:,i).*w;
    r(:,i)=r(:,i-1)-xx.*w;
    %%% CG ends
 
end;

imagesc([b,x])