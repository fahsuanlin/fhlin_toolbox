function mat=regularize_matrix(m,scalar)

% regularize_matrix.m
%
% regularize a matrix by specified scalar
%
%  mat=regularize_matrix(m,scalar)
%
% Apr. 5, 2001
%

mat=0;

if(size(m,1)~=size(m,2))
	fprintf('error!! regularize_matrix is only valid for square matrix!\n');
	return;
end;


tr=trace(m); %Trace of matrix
tr_avg=tr./size(m,1); % averaged trace

if(tr==0)
	tr=1;
end;


% set output by changing diagonal entries only

mat=m+diag(ones(size(m,1),1).*scalar*tr_avg);

return;
