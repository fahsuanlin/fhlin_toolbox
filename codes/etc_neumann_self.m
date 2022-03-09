function L=etc_neumann_self(l, w)
L=[];

%L_fun=@(r1, t1, t2) 1./sqrt((l.*t2-l.*t1).^2+(-w./2+w.*r1).^2);
%L_fun=@(t1, t2) 1./sqrt((l.*t2-l.*t1).^2);

%x1 = -l/2:l/100:l/2; 
%x2 = -l/2+eps:l/100:l/2+eps; 
%y = -w/2:w/100:w/2; 
%[X1,X2] = meshgrid(x1,x2);


try
    %L=1e-7.*norm(l).*norm(l).*norm(w).*integral3(L_fun,0,1,0,1,0,1,'RelTol',1e-1,'AbsTol',1e-3);
    %L=1e-7.*norm(l).*norm(l).*norm(w).*integral2(L_fun,0,1,0,1);
    %F = 1./sqrt((X1-X2).^2);
    %L = 1e-7.*trapz(x2,trapz(x1,F,2));
    L=200e-9.*(l).*log(4.*l./w-0.75); %Rosa, E.B. (1908). "The self and mutual inductances of linear conductors". Bulletin of the Bureau of Standards. U.S. Bureau of Standards. 4 (2): 301 ff. doi:10.6028/bulletin.088
catch ME
    fprintf('error in self inductance calculation!\n');   
end;

return;
