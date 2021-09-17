close all; clear all;

u=0;

[t,y] = ode45(@(t,y) fmri_balloonODE(t,y),[0 30],[1 1 1 1]');

E0=0.4;
v0=0.03;
k1=6.7/0.4*E0;
k2=2.73/0.4*E0;
k3=0.57;

bold=v0*(k1*(1-y(:,1))+k2*(1-y(:,1)./y(:,2))+k3*(1-y(:,2)));
%y_init=[0 1 0 1];
%bold0=v0*(k1*(1-y_init(1))+k2*(1-y_init(1)./y_init(2))+k3*(1-y_init(2)));
subplot(211);
plot(t,bold,t,y(:,1),t,y(:,2),t,y(:,3),t,y(:,4));

subplot(212);
plot(t,bold);