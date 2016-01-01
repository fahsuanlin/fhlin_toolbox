function [cc,varargout]=fmri_helmert_event(para,varargin)
% fmri_helmert_event	generating Helmert bases given the order of the SOA for event-related fMRI
% 
% [cc,(c)]=fmri_helmert_event(para,ext)
% 
%  para: SOA index for each event; 2D matrix (p*q) for p-event and q repetition for each event. para(p,q) is the SOA temporal index.
%  ext: the temporal extension for each event (default: 1)
% 
%  cc: Helmert bases
%  (c): event matrix
%
%  written by fhlin@aug. 23,2001



ext=1;
if(nargin==2)
	ext=varargin{1};
end;


for i=1:size(para,1)
	for j=1:ext
		c(i,para(i,:)+j-1)=1;
	end;
end;

varargout{1}=c;

h=fmri_helmert(size(para,1));

cc=c'*h;

ene=sqrt(diag(cc'*cc));

cc=cc./repmat(ene',[size(cc,1),1]);
	