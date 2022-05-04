function [e]=neuro_nernst(ci,co,z,t)
%neuro_nernst	Nernst equation for membrane potential
%
%[e]=neuro_nernst(ci,co,z,t)
%ci:inside concentration (mM)
%co:outside concentration (mM)
%z: # of electrons
%t: temperature (C)
%
%fhlin@sep.08, 1999
%

ci=ci/1000.0;
co=co/1000.0;
R=8.31;
F=96485;
t=t+273;
R*t/z/F;
e=R*t/z/F*log(co/ci);
e=e*1000.0;