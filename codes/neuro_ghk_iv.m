function [i,v,iin,iout,s,r]=neuro_ghk_iv(ci,co,z,t,p)
%neuro_ghk_iv	I-V plot for Goldman-Hodgkin-Katz eq.
%
%[i,v,s,r]=neuro_ghk_iv(ci,co,z,t,p)
%
%ci:inside concentration (mM)
%co:outside concentration (mM)
%z: # of electrons
%t: temperature (C)
%p: permeability of the membrane (amp/molar)
%
%i: current (nAmp)
%v: voltage (mV)
%iin: inward current (nAmp)
%iout: outward current (nAmp)
%s: conductance (u-S)
%r: resistance (M-ohm)
%
%fhlin@sep.08, 1999
%

close all;

ci=ci/1000.0;
co=co/1000.0;
R=8.31;
F=96485;
t=t+273;

v=[-0.101:0.002:0.101];
iin=(co*z*p*v*z*F/R/t)./(1-exp(v*z*F/R/t))*10^9;
iout=(ci*z*p*v*z*F/R/t)./(1-exp(-1*v*z*F/R/t))*10^9;
i=iin+iout;
v=v.*10^3;

figure(1)
plot(v,iin,'b:',v,iout,'b:',v,i,'r');
grid;
legend('inward I','outward I','total I');
xlabel('voltage (mV)');
ylabel('current (nAmp)');

figure(2)
i0=[i,0];
i1=[0,i];
idiff=i1-i0;
idiff=idiff(2:length(i));
v0=[v,0];
v1=[0,v];
vdiff=v1-v0;
vdiff=vdiff(2:length(v));
s=idiff./vdiff;
r=vdiff./idiff;

subplot(211);
plot(v(1:(length(v)-1)),s);
grid;
title('conductance');
xlabel('voltage (mV)');
ylabel('conductance (uS)');
subplot(212);
plot(v(1:(length(v)-1)),r);
grid;
title('resistance');
xlabel('voltage (mV)');
ylabel('resistance (M-ohm)');

