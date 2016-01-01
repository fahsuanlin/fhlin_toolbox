function forward=inverse_forward_meg_spherical(source_location, source_dipole_moment,sensor_location)

mu0=4*pi*1e-7;

for source_idx=1:size(source_location,1)
    rq=source_location(source_idx,:);
    q=source_dipole_moment(source_idx,:);
    for field_idx=1:size(sensor_location,1)
        r=sensor_location(field_idx,:);

        F_s=F(r,rq);
        delF_v=delF(r,rq);
        
        q1=inverse_crossproduct(q,rq);
        q2=r.*delF(r,rq);
        
        forward(field_idx,source_idx,:)=mu0./4./pi./F_s./F_s.*(F_s.*q1(:)'-q1(:)'*r(:).*delF_v);
    end;
end;

return;

function output=F(r,rq)
output=[];   
r_s=norm(r);
rq_s=norm(rq);

%d_s=r_s-rq_s;
d_s=norm(r-rq);
output=d_s*(r_s*d_s+r_s.^2-rq(:)'*r(:));
return;


function output=delF(r,rq)
output=[];   
r_s=norm(r);
rq_s=norm(rq);

%d_s=r_s-rq_s;
d_s=norm(r-rq);
d=r-rq;

output=(d_s.^2./r_s+(d(:)'*r(:)./d_s+2.*d_s+2.*r_s)).*r-(d_s+2.*r_s+d(:)'*r(:)./d_s).*rq;

return;