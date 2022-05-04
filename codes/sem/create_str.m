function [Ustring, Bstring] = create_str(U,B,Rname,useit);

% Routine to create strings like "region1 --> region2" 
% These strings appear in the Matlab command window
% FORMAT [Ustring, Bstring] = create_str(U,B,Rname,useit);
%_______________________________________________________________________
%
% Input Parameters: 
% U	- 2 x N matrix for N unidirectional connections
% B	- 2 x G matrix for G bidirectional connections
% Rname	- matrix that contains the names of all regions available
% useit	- index into Rname indicating which regions are used 
%
% Output Parameters: 
% Ustring	- String matrix with N rows
% Bstring 	- String matrix with G rows


%---------------------------------------------------------------------------------

for f=1:size(U,2)
 Ustring(f,:) = [Rname(useit(U(1,f)),:) '-->' Rname(useit(U(2,f)),:)];
end
for i=1:size(B,2)
 Bstring(i,:) = [Rname(useit(B(1,i)),:) '<->' Rname(useit(B(2,i)),:)];
end







  