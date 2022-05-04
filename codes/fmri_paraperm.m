function [sequence]=fmri_paraperm(paradigm)
%fmri_paraperm	generate a random permutation index based on the paradigm file
%
%[sequence]=fmri_paraperm(paradigm)
%
%
%paradigm : the paradigm column vector
%
%written by fhlin@aug. 21, 1999
prev=0;
epochs=0;
for i=1:length(paradigm)
	if(paradigm(i)~=prev)
		if(epochs>=1&prev~=0)
			epoch_end(epochs)=i-1;
		end;
		
		prev=paradigm(i);
		
		if(paradigm(i)==1|paradigm(i)==-1)
			epochs=epochs+1;
			epoch_start(epochs)=i;
		end;
	end;
end

if(paradigm(length(paradigm))~=0)
	epoch_end(epochs)=length(paradigm);
end;


ss=[1:1:length(paradigm)];
for i=1:epochs
	s0=randperm(epoch_end(i)-epoch_start(i)+1);
		
	ss(epoch_start(i):epoch_end(i))=s0+epoch_start(i)-1;
end;

sequence=ss;