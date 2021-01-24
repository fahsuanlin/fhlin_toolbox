function [alias_m]=sense_alias_matrix(sz,alias_ratio,varargin)
%
% sense_alias_matrix 	Create alias matrix for SENSE reconstruction
%
% [alias_m]=sense_alias_matrix(sz,alias_ratio)
% [alias_m]=sense_alias_matrix(ref_lines, acc_lines,'auto')
%
% sz: 2-element vector describing the size of the input matrix (2D)
% alias_ratio: the suggested alias ratio. Usually it is larger than 1
%
% ref_lines: number of full-FOV phase encoding
% acc_lines: number of accelerated reduced-FOV phase encoding
%
% alias_m: the alias matrix. This is assumed to alias the first dimension (rows) of the data.
%          Appropriate transpose/reshape is needed when it is used to alias other dimensions.
%
% fhlin@sep. 15, 2001
%fhlin@aug. 10, 2002

if(nargin==2)

	dim=1;
	skip=ceil(sz(dim)/alias_ratio);

	id=eye(skip);

	alias_m=[];
	for i=1:ceil(alias_ratio)
		alias_m=cat(2,alias_m,id);
	end;
	alias_m=alias_m(:,1:sz(1));
	alias_m=alias_m./repmat(sum(alias_m,2),[1,size(alias_m,2)]);	
end;


if((nargin==3|nargin==4)&(strcmp(varargin{1},'auto')))
    obs=alias_ratio;
    ref=sz(1);
    

	A=eye(obs);

	for i=1:ceil(ref/obs)+1
		A(:,obs*(i-1)+1:obs*i)=eye(obs);
	end;

	skip=obs-mod((ref-obs)/2,obs);
    
    if(nargin==4)
        alias_shift=varargin{2};
    else
        alias_shift=-1; %default correct shifting as verified using data sense-090202-bay2-2channel
    end;
    
	A=A(:,skip+2+alias_shift:skip+ref+1+alias_shift);
	A=A./max(sum(A,2));

	alias_m=A;
end;
if((nargin==3|nargin==4)&(strcmp(varargin{1},'auto_k')))
    
    s=sz;
    
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
    
    inv_F_orig=conj(dftmtx(size(S,2)))/size(S,2);
    F_acc=dftmtx(size(S,1));
   
    alias_m=shift_acc*F_acc*shift_acc*S*inv_shift_orig*inv_F_orig*inv_shift_orig;
    
    alias_m=alias_m(:,1:end-app);
    
end;
return;
