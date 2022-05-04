function output=etc_mom_i1(t, l1_start, l1_end, l2_start, l2_end) 

output=integral2(@(t1,t2) 1./sqrt(...
    (l1_start(1)-l2_start(1)-t2.*(l2_end(1)-l2_start(1))+t1.*(l1_end(1)-l1_start(1))).^2 + ...
    (l1_start(2)-l2_start(2)-t2.*(l2_end(2)-l2_start(2))+t1.*(l1_end(2)-l1_start(2))).^2 + ...
    (l1_start(3)-l2_start(3)-t2.*(l2_end(3)-l2_start(3))+t1.*(l1_end(3)-l1_start(3))).^2), ...
    0,1,0,1);

%     A=l1_start(1)-l2_start(1)-t.*(l2_end(1)-l2_start(1));
%     C=l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2));
%     E=l1_start(3)-l2_start(3)-t.*(l2_end(3)-l2_start(3));
%     b=l1_end(1)-l1_start(1);
%     d=l1_end(2)-l1_start(2);
%     f=l1_end(3)-l1_start(3);
%     l1=norm(l1_end-l1_start);
%     l2=norm(l2_end-l2_start);
%     bdf2=b.^2+d.^2+f.^2;
%     
%     output=@(t) l1.*l2./ sqrt(bdf2) .*log((2.*sqrt(bdf2.*(bdf2+2.*(l1_start(1)-l2_start(1)-t.*(l2_end(1)-l2_start(1))).*b+2.*(l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2))).*d+2.*(l1_start(3)-l2_start(3)-t.*(l2_end(3)-l2_start(3))).*f+(l1_start(1)-l2_start(1)-t.*(l2_end(1)-l2_start(1))).^2+(l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2))).^2+(l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2))).^2))+2.*(bdf2+(l1_start(1)-l2_start(1)-t.*(l2_end(1)-l2_start(1))).*b+(l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2))).*d+(l1_start(3)-l2_start(3)-t.*(l2_end(3)-l2_start(3))).*f))./(2.*sqrt(bdf2.*((l1_start(1)-l2_start(1)-t.*(l2_end(1)-l2_start(1))).^2+(l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2))).^2+(l1_start(3)-l2_start(3)-t.*(l2_end(3)-l2_start(3))).^2))+2.*((l1_start(1)-l2_start(1)-t.*(l2_end(1)-l2_start(1))).*b+(l1_start(2)-l2_start(2)-t.*(l2_end(2)-l2_start(2))).*d+(l1_start(3)-l2_start(3)-t.*(l2_end(3)-l2_start(3))).*f)));
return;
