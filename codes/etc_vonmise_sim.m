close all; clear all;


mu=45/180*pi;
k=0.1;


theta=[];
cont=1;

while(cont)
    u1=rand;
    u2=rand;
    u3=rand;
    
    
    a=1+sqrt(1+4*k^2);
    b=(a-sqrt(2*a))/2/k;
    r=(1+b^2)/(2*b);
    
    z=cos(pi*u1); f=(1+r*z)/(r+z); c=k*(r-f);
    if((c*(2-c)-u2)>0)
        theta(end+1)=sign(u3-0.5)*acos(f)+mu;
    elseif((log(c/u2)+1-c)<0)
        
    else
        theta(end+1)=sign(u3-0.5)*acos(f)+mu;
    end;
    
    if(length(theta)>=10000) cont=0; end;
end;

rose(theta);