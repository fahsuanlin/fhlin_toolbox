function [inefficiency]=fmri_design_core(P,TR,dt,varargin)

%initializations and defaults
inefficiency=inf;
C=[];
hdr_type='fir';
hdr_length=20;	%sec

%reading parameters
for i=1:length(varargin)./2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch lower(option)
	case 'c'
		C=option_value;
	case 'hdr_type'
		hdr_type=option_value;
	case 'hdr_length'
		hdr_length=option_value;
	otherwise
		fpritnf('unknown option [%s]. error!\n',option);
		return;
	end;
end;

% free variables
L=P(1,1:end-1);
T=P(2:end,1:end-1);			

%auxiliary variables
nc=size(P,1)-1;				%number of conditions
nt=size(P,2)-1;				%number of trials

%preparing hemodynamic response model
hdr_discrete_length=round(hdr_length/dt);
if(strcmp(hdr_type,'fir'))
	hdr=eye(round(hdr_length/dt));
end;

%design STM matrix
X=zeros(ceil(TR*nt./dt),nc*hdr_discrete_length);

for i=1:nt
	type=find(T(:,i));
	time_start=L(i);
	time_offset=(i-1)*TR;
	time_index=ceil((time_offset+time_start)./dt);
	if(~isempty(find(time_index<1)))
		keyboard;
	end;
	X(time_index,(type-1)*hdr_discrete_length+1)=1;
end;

D=zeros(size(X));
for i=1:nc
	for j=1:length(hdr)
		dd=conv(X(:,(i-1)*size(hdr,2)+1),hdr(:,j));
		D(:,(i-1)*size(hdr,2)+j)=dd(1:size(X,1));
	end;
end;

if(isempty(C))
	C=eye(size(X,1));
end;

fprintf('calculating (in)efficiency...\n');
inefficiency=trace(pinv(D'*pinv(C)*D));

%efficiency is 1./inefficiency