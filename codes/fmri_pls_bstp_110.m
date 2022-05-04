function [seq]=fmri_pls_bstp_110(datamat_struct)
%
% fmri_pls_bstp_110(datamat_struct)    this gives the randomized permuted sequence across tasks, while maintaing subjects' order
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

for t=1:tasks
   for s=1:subjects
      seq(t,s)=ceil(rand*tasks*subjects);
   end;
end;

ss_start=[];
ss_stop=[];
for t=1:tasks
   for s=1:subjects
      idx=seq(t,s);
      tt=ceil(idx/subjects);
      ss=mod(idx,subjects);
      if (ss==0) ss=subjects; end;
      ss_start(t,s)=start(tt,ss);
      ss_stop(t,s)=stop(tt,ss);
   end;
end;


seq=[];
for t=1:tasks
   for s=1:subjects
      seq=[seq,ss_start(t,s):ss_stop(t,s)];
	end;
end;




