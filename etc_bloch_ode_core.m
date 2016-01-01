function [yout]=etc_bloch_ode_core(t,y,ode_obj)

    T1=ode_obj.T1;
    T2=ode_obj.T2;
    gamma=ode_obj.gamma; %MHz/T for proton
    B0=ode_obj.B0;   %Tesla
    M0=ode_obj.M0;
    M_inf=ode_obj.M_inf;
    
    yout=[-1/T2 gamma*B0 0
        -gamma*B0 -1/T2 0
        0 0 -1/T1]*y+[0 0 M_inf(3)/T1]';
    
return;