function output=etc_mom_i4(t, l1_start, l1_end, l2_start, l2_end)

output=integral2(@(t1,t2) ...
    (l1_start(1)-l2_start(1)-t2.*(l2_end(1)-l2_start(1))+t1.*(l1_end(1)-l1_start(1))).^2 + ...
    (l1_start(2)-l2_start(2)-t2.*(l2_end(2)-l2_start(2))+t1.*(l1_end(2)-l1_start(2))).^2 + ...
    (l1_start(3)-l2_start(3)-t2.*(l2_end(3)-l2_start(3))+t1.*(l1_end(3)-l1_start(3))).^2, ...
    0,1,0,1);

% a=l1_start(1)-l2_start(1);
% c=l1_start(2)-l2_start(2);
% e=l1_start(3)-l2_start(3);
% b=l1_end(1)-l1_start(1);
% d=l1_end(2)-l1_start(2);
% f=l1_end(3)-l1_start(3);
% cx=l2_end(1)-l2_start(1);
% cy=l2_end(2)-l2_start(2);
% cz=l2_end(3)-l2_start(3);
% l1=norm(l1_end-l1_start);
% l2=norm(l2_end-l2_start);
% bdf2=b.^2+d.^2+f.^2;
% 
% 
% output=@(t) l1*l2.*(a.^2+c.^2+e.^2+a.*b+c.*d+e.*f+bdf2./3+(a.*cx+c.*cy+e.*cz+(b.*cx+d.*cy+f.*cz)./2)+(cx.^2+cy.^2+cz.^2)./3);


return;
