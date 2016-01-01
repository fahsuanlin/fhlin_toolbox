function [seq]=fmri_pls_perm_001(datamat_struct)
%
% fmri_pls_perm_001(datamat_struct)    this gives the randomized permuted sequence across tasks, while maintaing subjects' order
%
%
% written by fhlin@jan. 27, 00
%

tasks=size(datamat_struct,1);
subjects=size(datamat_struct,2);
s=reshape(datamat_struct',tasks*subjects,1);

start(1)=1;
stop(1)=s(1);
for i=2:length(s)
   start(i)=start(i-1)+s(i-1);
   stop(i)=stop(i-1)+s(i);
end;
start=reshape(start,[subjects,tasks])';
stop=reshape(stop,[subjects],tasks)';

seq=[];
for t=1:tasks
   for s=1:subjects
      tmp=(randperm(stop(t,s)-start(t,s)+1)'+start(t,s)-1)';
      seq=[seq,tmp];
	end;
end;




