function [output]=inverse_collapse3(input,varargin)
% inverse_collapse3		collapsing 3 directional components into one
%
% [output]=inverse_collapse3(input,mode)
%
% input: (3*d)-by-(t) matrix of d-dipoles and t-timepoints
% mode: 
% output: d-by-ty matrix 
%
% fhlin@may, 23, 2003
%

if(mod(size(input,1),3)~=0)
	fprintf('wrong dimension of the input!\n');
	fprintf('input has no 3-multiple rows!\n');
	return;
end;

mode='sos';

if(nargin>1)
	mode=varargin{1};
end;

output=zeros(size(input,1)/3,size(input,2));
switch mode
	case 'sos'
		output=squeeze(sum(reshape(input,[3,size(input,1)/3,size(input,2)]).^2,1));
	case 'sum'
		output=squeeze(sum(reshape(input,[3,size(input,1)/3,size(input,2)]),1));
	case 'abs'
		output=squeeze(sqrt(sum(reshape(input,[3,size(input,1)/3,size(input,2)]).^2,1)));
	case 'rms'
		output=squeeze(sqrt(sum(reshape(input,[3,size(input,1)/3,size(input,2)]).^2,1)./3));
	case 'lcc_prin'
		output=squeeze(input(1:3:end,:));
	otherwise
		fprintf('unknown collapsing mode [%s]!',mode);
		return;
end;
if(size(input,1)==3) output=output'; end;
if(min(size(input))==1)
	output=reshape(output,[length(output),1]);
end;
return;
