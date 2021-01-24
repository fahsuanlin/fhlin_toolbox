function res=etc_comb(a,b)
% C(i,j) is i!/j!/(i-j)!
%
% written by fhlin@feb. 20 2000

res=etc_factorial(a)./etc_factorial(b)./etc_factorial(a-b);
