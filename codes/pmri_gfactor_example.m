close all; clear all;
% An example script to calculate g-factoc maps by 
% 1) direct matrix inversion on the encoding matrix and
% 2) conjugate-gradient method to solve g-factor iteratavely for each
% pixel.
%
% fhlin@sep. 14 2010
%

matrix={
    [8 8];
    };
n_chan=2;
R=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k=zeros(matrix{1});
k(1:R:end)=1;
for ch_idx=1:n_chan
    s(:,:,ch_idx)=randn(matrix{1}); %use random number to generate n-channel b1 maps
end;

%obtain encoding matrix
[E,F]=pmri_encoding_matrix('s',s,'k',k);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%use direct matrix inversion to calculate g-factor maps (G1)
D=E'*E;
Dinv=inv(D);
G1=reshape(real(sqrt(diag(D).*diag(Dinv))),matrix{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%use CG to calculate g-factor maps (G2)
g_1=zeros(matrix{1});
g_2=zeros(matrix{1});
ll=[1:prod(size(k))];
for v_idx=1:length(ll)
    b=zeros(matrix{1});
    b(ll(v_idx))=1;
    [recon,d0,d1,g2]=pmri_core_cg('K',k,'S',s,'Y',b,'flag_display',0,'flag_cg_gfactor',1,'iteration_max',20);
    g_1(ll(v_idx))=recon(ll(v_idx));
    g_2(ll(v_idx))=g2(ll(v_idx));
end;
G2=sqrt(real(g_1).*real(g_2));

return;

