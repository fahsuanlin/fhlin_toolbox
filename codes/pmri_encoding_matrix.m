function [E,F,F_fwd, F_inv]=pmri_encoding_matrix(varargin)
%
%	pmri_encoding_matrix		generate encoding matrix for pMRI
%
%
%	[E,F]=pmri_encoding_matrix(''S',S,'K',K,'flag_display',1);
%
%	INPUT:
%	S: n-dimensional coil sensitivity maps of [n_PE1, n_PE2, ..., n_PEn, n_chan].
%		n_PE1: # of phase encoding in dimension 1
%		n_PE2: # of phase encoding in dimension 2
%		n_PEn: # of phase encoding in dimension n
%		n_chan: # of channel
%	K: 2D k-space sampling matrix with entries of 0 or 1 [n_PE1, n_PE2, ..., n_PEn].
%		n_PE1: # of phase encoding in dimension 1
%		n_PE2: # of phase encoding in dimension 2
%		n_PEn: # of phase encoding in dimension n
%		"0" indicates the correponding entries are not sampled in accelerated scan.
%		"1" indicates the correponding entries are sampled in accelerated scan.
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	E: 2D encoding matrix of [n_pixel*n_chan, n_pixel]
%		n_pixel: # of image pixe; n_pixel=n_PE1*n_PE2*...*n_PEn
%		n_chan: # of RF channel
%	F: 2D Fourier encoding matrix for n-dimensional DFT [n_pixel, n_pixel]
%		n_pixel: # of image pixe; n_pixel=n_PE1*n_PE2*...*n_PEn
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@sep. 14, 2010

E=[];
F=[];

S=[];
K=[];

flag_display=0;
flag_unique_output=1;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 's'
            S=option_value;
        case 'k'
            K=option_value;
        case 'flag_unique_output'
            flag_unique_output=option_value;
        case 'flag_display'
            flag_display=option_value;            
        otherwise
            fprintf('unknown option [%s]...\nerror!\n',option);
            return;
    end;
end;

dim_S=length(size(S));
sz=size(S);
if(ndims(S)==ndims(K)+1)
    n_chan=sz(end);
    
    k_sz=sz(1:end-1);
else
    if(size(K,ndims(K))==1)
        n_chan=sz(end);
    else
        n_chan=1;
    end;
    k_sz=[sz(1:end-1) 1];
end;
n_pixel=prod(size(K));


if(sum(abs(size(K)-k_sz))>0)
    fprintf('size of [K] (k-space sampling pattern) does not equal to size in [S] (sensitivity maps)!\n');
    fprintf('size of [K] = %s\n',mat2str(size(K)));
    fprintf('size of [S] = %s\n',mat2str(size(S)));
    fprintf('error!\n');
    return;
end;

%generating the n-dimensional Fourier encoding matrix
idx=zeros(size(K));
idx(1:end)=[1:prod(size(idx))];
E_idx=[1:prod(size(K))];
k_idx=find(abs(K)>eps);

K=fftshift(K);
sk=size(K);
if (sk(end)==1)
    n_d=length(sk)-1;
else
    n_d=length(sk);
end;

%for i=1:ndims(K)
for i=1:n_d
    if(flag_display) fprintf('.'); end;
    %DFT matrix
    a=dftmtx(size(K,i));

    p=[1:ndims(K)];
    t0=p(i);
    t1=p; t1(i)=[];
    t1=[t0,t1];
    idx_dim=permute(idx,t1);

    %fourier encoding matrix for each FT along ONE single dimension
    F0=zeros(prod(size(K)),prod(size(K)));
    for j=1:size(idx_dim,2)
        if(flag_display) fprintf('*'); end;
        F0(idx_dim(:,j),idx_dim(:,j))=a;
    end;
    if(i==1)
        F=F0;
    else
        F=F*F0;
    end;

    if(flag_display) fprintf('\n'); end;

end;

F_fwd=F;
F(find(abs(K)<eps),:)=0;

%for i=1:ndims(K)
for i=1:n_d
    if(flag_display) fprintf('#'); end;
    %IDFT matrix
    a=conj(dftmtx(size(K,i)))./size(K,i);

    p=[1:ndims(K)];
    t0=p(i);
    t1=p; t1(i)=[];
    t1=[t0,t1];
    idx_dim=permute(idx,t1);

    %inverse fourier encoding matrix for each IFT along ONE single dimension
    F0=zeros(prod(size(K)),prod(size(K)));
    for j=1:size(idx_dim,2)
        if(flag_display) fprintf('*'); end;
        F0(idx_dim(:,j),idx_dim(:,j))=a;
    end;
    if(i==1)
        F_inv=F0;
    else
        F_inv=F_inv*F0;
    end;

    if(flag_display) fprintf('\n'); end;

end;
F=F_inv*F;
% F is the final n-dimensional DFT matrix

if(flag_unique_output)
    select_idx=zeros(size(F,1),1);
    
    redundant_idx=[];
    for ii=1:size(F,1)
        idx=find(abs(F(ii,:))>eps);
        
        
        if(sum(select_idx(idx))<length(idx)) %redundant output
            select_idx(idx)=1;            
        else
            redundant_idx(end+1)=ii;
        end;
    end;
    F(redundant_idx,:)=[];
end;
%F(find(abs(K)<eps),:)=[];

S=reshape(S,[n_pixel,n_chan]);
if(flag_display) fprintf('init encoding matrix...'); end;
E=zeros(size(F,1)*n_chan,size(F,2));
if(flag_display) fprintf('done!\n'); end;
for ch_idx=1:n_chan
    if(flag_display) fprintf('#'); end;
    E((ch_idx-1)*size(F,1)+1:(ch_idx)*size(F,1),:)=F.*transpose(repmat(S(:,ch_idx),[1,size(F,1)]));
end;
if(flag_display) fprintf('\n'); end;

return;
