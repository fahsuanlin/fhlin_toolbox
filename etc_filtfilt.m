function X_filter=etc_filtfilt(fb,fa,X0)
% etc_filtfilt		zero-delay digital filtering (also good for complex data) for 1D and 2D data
%
% Y=etc_filfilt(B,A,X)
%
% B: nominator for digital filter
% A: denumerator for digital filter
% X: input data (can be 2D data; for 2D data, filter across different columns)
%
% fhlin@Mar. 3, 2003
%

X_filter=zeros(size(X0));
nb = length(fb);
na = length(fa);
len = size(X0,2);
nfilt = max(nb,na);
nfact = 3*(nfilt-1);  % length of edge transients
if nb < nfilt, fb(nfilt)=0; end 
if na < nfilt, fa(nfilt)=0; end
rows = [1:nfilt-1  2:nfilt-1  1:nfilt-2];
cols = [ones(1,nfilt-1) 2:nfilt-1  2:nfilt-1];
data = [1+fa(2) fa(3:nfilt) ones(1,nfilt-2)  -ones(1,nfilt-2)];
sp = sparse(rows,cols,data);
zi = sp \ ( fb(2:nfilt).' - fa(2:nfilt).'*fb(1) );

X_filter = [repmat(2*X0(:,1),[1,nfact])-X0(:,(nfact+1):-1:2),X0,repmat(2*X0(:,len),[1,nfact])-X0(:,(len-1):-1:len-nfact)];
X_filter = filter(fb,fa,X_filter,[zi*X_filter(:,1)'],2);
X_filter = fliplr(X_filter);
X_filter = filter(fb,fa,X_filter,[zi*X_filter(:,1)'],2);
X_filter = fliplr(X_filter);
X_filter(:,[1:nfact len+nfact+(1:nfact)]) = [];