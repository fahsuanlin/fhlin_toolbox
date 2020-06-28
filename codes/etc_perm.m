function res=etc_perm(a,b)
% P(i,j) is i!/(i-j)!
%
% written by fhlin@feb. 20 2000

res=etc_factorial(a)./etc_factorial(a-b);
