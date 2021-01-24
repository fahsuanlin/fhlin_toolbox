function B=b1sim_ac_core(freq,current,fov_grids)

k=2*pi*freq/3e8; %free spaec wave number

fx=zeros(size(fov_grids,1),1);
fy=zeros(size(fov_grids,1),1);
fz=zeros(size(fov_grids,1),1);


for i=1:length(current)
    fprintf('.');
    if(isfield(current{1},'weight'))
        w=current{i}.weight;
    else
        w=1.0;
    end;
    
    alpha=repmat(current{i}.start(1)-current{i}.stop(1),[size(fov_grids,1),1]);
    beta=repmat(current{i}.start(2)-current{i}.stop(2),[size(fov_grids,1),1]);
    gamma=repmat(current{i}.start(3)-current{i}.stop(3),[size(fov_grids,1),1]);
    
    A=fov_grids(:,1)-repmat(current{i}.start(1),[size(fov_grids,1),1]);
    B=fov_grids(:,2)-repmat(current{i}.start(2),[size(fov_grids,1),1]);
    C=fov_grids(:,3)-repmat(current{i}.start(3),[size(fov_grids,1),1]);
    
    c=A.^2+B.^2+C.^2;
    b=2.*(A.*alpha+B.*beta+C.*gamma);
    a=alpha.^2+beta.^2+gamma.^2;
    
    qx=-B.*gamma+C.*beta;
    px=0;
    fx=fx+integral1(px,qx,a,b,c).*w.*(-1);
        
    qy=-C.*alpha+A.*gamma;
    py=0;
    fy=fy+integral1(py,qy,a,b,c).*w.*(-1);
    
    qz=-A.*beta+B.*alpha;
    pz=0;
    fz=fz+integral1(pz,qz,a,b,c).*w.*(-1);
    
end;
fprintf('\n');

B=[fx,fy,fz]./1e7;

return;



function output=integral1(p,q,a,b,c)
% integral{(q+p*t)/sqrt(c+b*t+a*t^2).^3}dt, t from 0 to 1

term1=q.*(2.*(2.*a+b)./(4.*a.*c-b.^2)./sqrt(a+b+c)-2.*b./(4.*a.*c-b.^2)./sqrt(c));
term2=p.*(2.*(b+2.*c)./(b.^2-4.*a.*c)./sqrt(a+b+c)-4.*c./(b.^2-4.*a.*c)./sqrt(c));

output=term1+term2;

return;

function output=integral2(p,q,a,b,c)
% integral{(q+p*t)/sqrt(c+b*t+a*t^2)}dt, t from 0 to 1

term1=q./sqrt(a).*log((2.*sqrt(a).*sqrt(a+b+c)+2.*a+b)./(2.*sqrt(a).*sqrt(c)+b));

term2=p.*(sqrt(a+b+c)./a-sqrt(c)./a-b./2./a.*(1./sqrt(a).*log((2.*sqrt(a).*sqrt(a+b+c)+2.*a+b)./(2.*sqrt(a).*sqrt(c)+b))));

output=term1+term2;

return;

function output=integral3(p,q)
% integral{(q+p*t)}dt, t from 0 to 1

output=q+1/2*p;
return;