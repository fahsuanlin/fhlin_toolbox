function output=etc_mom_i2(t, l1_start, l1_end, l2_start, l2_end) 
    a=l1_start(1)-l2_start(1)-t.*(l2_end(1)-l1_start(1));
    c=l1_start(2)-l2_start(2)-t.*(l2_end(2)-l1_start(2));
    e=l1_start(3)-l2_start(3)-t.*(l2_end(3)-l1_start(3));
    b=l1_end(1)-l1_start(1);
    d=l1_end(2)-l1_start(2);
    f=l1_end(3)-l1_start(3);
    l1=norm(l1_end-l1_start);
    l2=norm(l2_end-l2_start);
    bdf2=b.^2+d.^2+f.^2;
    
    output=@(t) 1;
    
%    output=@(t) (l1_end(:)-l1_start(:))'*(l2_end(:)-l2_start(:));
%    syms t1 t2;
%    output=integral2(@(t1,t2) ...
%    1, ...
%    0,1,0,1);

return;
