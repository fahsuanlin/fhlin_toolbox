function ph=inverse_get_phase(X)
%	inverse_get_phase	calculate the phase of the input signal
%
%	ph=inverse_get_phase(X);
%
%	X: input matrix
%	ph: output phase
%
%	if X is of A*exp(j*theta), ph is calculated as exp(j*theta);
%
%	fhlin@dec 30, 2004
%

ph=exp(sqrt(-1).*angle(X));

return;