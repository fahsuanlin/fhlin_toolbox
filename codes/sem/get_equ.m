function [Free, xfix] = get_equ(Free, Equ);

% Parsing routine to incorporate equality constraints
% if called without parameter Equ it serves as a user interface


% FORMAT function [Free] = get_equ(Free);
% --------------------------------
% Function to set up equality constrains
%
% Input Parameters: 
%
% Free 	-  matrix of free parameters (uni- or bidirectional connections) (eg. [1 2 3 4])
% Equ	-  Matrix with one constraint per row
%
% Example: Free = [1 2 3 4 5 6 7], Equ = [Inf 2 4;0 6 7;1.2 3 3];
% Applying the equality constraints results in Free = [1 2 3 2 4 0 0] 
% and xfix [1.2 ; 3]
% If parameter Equ is specified, this is used as a list of equ
% constraints (one constraint per row)  

% Output
%
% Free	- Free parameters with applied constraints


% Split up free
%--------------

FreeAll = Free(1,:);
FreeInd = Free(2:3,:)


xfix = [];

for g = 1:size(Equ,2)
    e = Equ(g);		
    if isempty(e.value), break, end
    
    switch e.value
    case {Inf, 0}	% equality or zero constraint
        
        which = [];  
        
        for f = 1:size(e.conn,2)
            new   = find(FreeInd(1,:)==e.conn(1,f) & FreeInd(2,:)==e.conn(2,f));
            old_e = find(FreeAll == FreeAll(new));
            which = [which new old_e];
        end 
        
        if e.value == inf 
            NewVal   = min(FreeAll(which));
        else
            NewVal   = 0;
        end 
        
        for f = 1:size(which,2)
            FreeAll(which(f)) = NewVal;
            if max(diff(sort(FreeAll)))>1  % Fill in gaps if necessary		
                FreeAll = correct(FreeAll);
            end
        end
        
    otherwise	% fixed assignment     
        for f = 1:size(e.conn,2)
            which = find(FreeInd(1,:)==e.conn(1,f) & FreeInd(2,:)==e.conn(2,f));
            xfix = [xfix [e.value;FreeAll(which)]]; 
        end
    end  %switch
    
    FreeAll(find(FreeAll < 0)) = zeros(size(find(FreeAll < 0)));		% During the correction, zeros will be negative
end

Free(1,:) = FreeAll;


%-------------------------
function inp = correct(inp) 

[ii,jj] = sort(inp);  
d       = diff(ii);
ps      = find(d == max(d))+1;
cr      = inp(jj(ps));
inp(find(inp > cr-1)) = inp(find(inp > cr-1))-1;	% Do correction  











