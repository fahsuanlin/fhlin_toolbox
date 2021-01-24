function [Am,Km,C,Vm]=etc_bivsam(A,B,C,R,m)  % copyright V Solo 2000
%==================================================================
%  COMMAND  :  [Am,Km,C,Vm]=bivsam(A,B,C,R,m)
%   ACTION  :  Gets sampled ISS model
%
%   INPUTS  :  [A,B,C,R] = ISS model 
%                      m = sampling multiple (>1)
%
%  OUTPUTS  :  [Am,Km,C,Vm] = sampled SS model
%          
%===============================================================
if m==1
    display('must have m>1')
    return
end
% stability test
[V,D]=eig(A);
[Vi,Di]=eig(A');  % so A=V*D*Vi
% get inverse V^{-1} by rescaling
Del=Vi'*V;
Vi=Del\Vi;
%
em=max(abs(D));
if em>=1
    display('unstable A matrix')
return
end
%
[p,p]=size(A);
Lr=(chol(R))';
Lo=B*Lr;
%BL=B*L;
%BRB=BL*BL';
%Dm=U;   
Am=eye(p,p);
%Qm=BRB;
for i=1:m-1
    Am=Am*A;         % this gives A^(m-1)
    %Dm=Dm*D;
    %Qm=A*Qm*A'+BRB;  % gives correct Qm
    M=[A*Lo B*Lr];    % get Qm via cholesky update: Qm=(A*Lo)*(A*Lo)'+(B*Lr)*(B*Lr)'
    [Q,U]=qr(M',0);    % => Qm=M*M'=U'*Q'*Q*U=U'*U
    Lo=U';           % => Qm=Lo*Lo';
end
%
Qm=Lo*Lo';
%Am=V*Dm*Vi';
Sm=Am*B*R;
Am=Am*A;             % gets A^m
%

%[Pm,L,G]=DARE(Am',C',Qm,R,Sm,U);
RR=Lr*Lr';
[Pm,L,G]=DARE(Am',C',Qm,RR,Sm,eye(size(Am')));
Lm=(chol(Pm))';
CLm=C*Lm;
Vm=R+CLm*CLm';  %Vm=R+C*Pm*C';
Km=G';
Dm=(chol(Vm))';
%  end