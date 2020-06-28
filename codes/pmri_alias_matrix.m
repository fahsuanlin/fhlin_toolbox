function [alias_m]=pmri_alias_matrix(sample_vector)
%
% 	pmri_alias_matrix 		Create alias matrix for SENSE reconstruction
%
% 	[alias_m]=pmri_alias_matrix(sample_vector)
%
%	INPUT:
% 	sample_vector: 1D sample vector with entries of "0" or "1" indicating the corresponding phase-encoding line is acquired or not.
%
%	OUTPUT:
% 	alias_m: the alias matrix. This is assumed to alias the first dimension (rows) of the data.
%          	Appropriate transpose/reshape is needed when it is used to alias other dimensions.
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
% 	fhlin@sep. 15, 2001
% 	fhlin@aug. 10, 2002
% 	fhlin%jan. 25, 2005


   
    s=sample_vector;
    
    app=0;
    
    S=zeros(length(find(s)),length(s));
    col=find(s);
    row=[1:size(S,1)];
    idx=sub2ind(size(S),row,col);
    S(idx)=1;
    
    if(mod(size(S,2),2)==0)
        %fprintf('orig: even\n');
        inv_shift_orig=[zeros(size(S,2)/2),eye(size(S,2)/2);eye(size(S,2)/2), zeros(size(S,2)/2)];  
        
    else
        %fprintf('orig: odd\n');
        inv_shift_orig=[zeros((size(S,2)-1)/2,(size(S,2)+1)/2),eye((size(S,2)-1)/2);eye((size(S,2)+1)/2), zeros((size(S,2)+1)/2,(size(S,2)-1)/2)];
    end;
    
    if(mod(size(S,1),2)==0)
        %fprintf('acc: even\n');
        shift_acc=[zeros(size(S,1)/2),eye(size(S,1)/2);eye(size(S,1)/2), zeros(size(S,1)/2)]; 
    else
        %fprintf('acc: odd\n');
        shift_acc=[zeros((size(S,1)-1)/2,(size(S,1)+1)/2),eye((size(S,1)-1)/2);eye((size(S,1)+1)/2), zeros((size(S,1)+1)/2,(size(S,1)-1)/2)];
    end;
    
    %inv_F_orig=conj(dftmtx(size(S,2)))/size(S,2);
    inv_F_orig=conj(dftmtx(size(S,2)))/size(S,2);
    F_acc=dftmtx(size(S,1));
   
    alias_m=shift_acc*F_acc*shift_acc*S*inv_shift_orig*inv_F_orig*inv_shift_orig;
    
    alias_m=alias_m(:,1:end-app);
    

return;
