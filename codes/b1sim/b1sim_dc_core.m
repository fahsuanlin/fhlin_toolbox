function B=b1sim_dc_core(current,fov_grids)

fx=zeros(size(fov_grids,1),1);
fy=zeros(size(fov_grids,1),1);
fz=zeros(size(fov_grids,1),1);


for i=1:length(current)
    if(isfield(current{1},'weight'))
        w=current{i}.weight;
    else
        w=1.0;
    end;
    
    a=repmat(norm(current{i}.start-current{i}.stop).^2,[size(fov_grids,1),1]);
    b=2.*(sum(repmat(current{i}.stop-current{i}.start,[size(fov_grids,1),1]).*(repmat(current{i}.start,[size(fov_grids,1),1])-fov_grids),2));
    c=sum((repmat(current{i}.start,[size(fov_grids,1),1])-fov_grids).^2,2);
    
    s1=current{i}.start;
    s1=repmat(s1,[size(fov_grids,1),1]);
    s2=current{i}.stop;
    s2=repmat(s2,[size(fov_grids,1),1]);    
    
    px=(s2(:,2)-s1(:,2)).*(s2(:,3)-s1(:,3))-(s2(:,3)-s1(:,3)).*(s2(:,2)-s1(:,2));
    qx=(s2(:,2)-s1(:,2)).*(s1(:,3)-fov_grids(:,3))-(s2(:,3)-s1(:,3)).*(s1(:,2)-fov_grids(:,2));
    
    fx=fx+integral(px,qx,a,b,c).*w;
    
    py=(s2(:,3)-s1(:,3)).*(s2(:,1)-s1(:,1))-(s2(:,1)-s1(:,1)).*(s2(:,3)-s1(:,3));
    qy=(s2(:,3)-s1(:,3)).*(s1(:,1)-fov_grids(:,1))-(s2(:,1)-s1(:,1)).*(s1(:,3)-fov_grids(:,3));
    
    fy=fy+integral(py,qy,a,b,c).*w;
    
    pz=(s2(:,1)-s1(:,1)).*(s2(:,2)-s1(:,2))-(s2(:,2)-s1(:,2)).*(s2(:,1)-s1(:,1));
    qz=(s2(:,1)-s1(:,1)).*(s1(:,2)-fov_grids(:,2))-(s2(:,2)-s1(:,2)).*(s1(:,1)-fov_grids(:,1));
    
    fz=fz+integral(pz,qz,a,b,c).*w;
    

end;

B=-1.*[fx,fy,fz]./1e7;

return;



function output=integral(p,q,a,b,c)
% integral{(q+p*t)/sqrt(c+b*t+a*t^2).^3}dt, t from 0 to 1

term1=q.*(2.*(2.*a+b)./(4.*a.*c-b.^2)./sqrt(a+b+c)-2.*b./(4.*a.*c-b.^2)./sqrt(c));
term2=p.*(2.*(b+2.*c)./(b.^2-4.*a.*c)./sqrt(a+b+c)-4.*c./(b.^2-4.*a.*c)./sqrt(c));

output=term1+term2;

return;