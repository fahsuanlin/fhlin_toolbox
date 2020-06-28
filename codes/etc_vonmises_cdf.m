function cc=etc_vonmises_cdf(x,mu,k)
% cumulative distribution function of Von Mises distribution
%
% cdf=etc_vonmises_cdf(x,mu,k)
%
% x: input argument
% mu: mean
% k: a parameter tuning the "variance" of the normal distribution
%
% cdf: cumulative distribution function
%
% fhlin@june 4, 2007
%

tmp=0;
for j=1:100
    if(j>1)
        tmp=tmp+besseli(j,k)*sin(j.*(x-mu))./j;
    else
        tmp=besseli(j,k)*sin(j.*(x-mu))./j;
    end;
end;
cc=1./2./pi.*(x+2./besseli(0,k).*tmp)+0.5;

return;