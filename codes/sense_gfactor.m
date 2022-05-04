function [g_unreg, g_reg, mask_g_unreg, mask_g_reg, mask]=sense_gfactor(varargin);
%	sense_gfactor		calculate g-factor
%
%	sense_gfactor('D',data,'R',acc_rate);
%	D: input data of [n_PE, n_FE, n_chan]. 
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	R: acceleration rate
%
%	sense_gfactor('D',data,'R',acc_rate,'C',coil_noise);
%	
%	C: noise covariance matrix [n_chan, n_chan]
%
%	sense_gfactor('D',data,'sample_vector',s,'C',coil_noise);
%	sample_vector: a vector of 0 and 1 indicating the sampled PE lines [1, n_PE];
%
%	fhlin@jan. 20, 2005


A=[];	%aliasing matrix; [dim_PE_acc,dim_PE_full];
R=[];
C=[];	%noise correlation matrix, [dim_chan, dim_chan];
D=[];	%coil sensitivity data, [dim_PE_full, dim_FE,dim_chan];

g_unreg=[];
g_reg=[];

sample_vector=[];

reg_param=[];
reg_param_frac=[];

mask=[];
mask_threshold=[];

flag_display=0;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
    case 'c'
        C=option_value;
    case 'a'
        A=option_value;
    case 'r'
        R=option_value;
    case 'sample_vector'
        sample_vector=option_value;
    case 'd'
        D=option_value;
    case 'flag_display'
	flag_display=option_value;
    case 'reg_param'
	reg_param=option_value;
    case 'reg_param_frac'
	reg_param_frac=option_value;
    case 'mask'
    	mask=option_value;
    case 'mask_threshold'
    	mask_threshold=option_value;
    otherwise
        fprintf('unknown option [%s]!\n',option);
        fprintf('error!\n');
        return;
    end;
end;


%get aliasing matrix
if(isempty(A)) %no aliasing matrix
	if(isempty(D))	%no data
		fprintf('no data for g-factor calculation!\nerror!\n');
		return;
	else
		if(~isempty(sample_vector))	%define aliasing matrix by sample vector
			A=sense_alias_matrix(sample_vector,[],'auto_k');
		else
			if(~isempty(R))		%define aliasing matrix be acceleration rate
				sample_vector=zeros(1,size(D,1));
				sample_vector(1:R:end)=1;
				A=sense_alias_matrix(sample_vector,[],'auto_k');
			else
				fprintf('no specified acceleration rate!\nerror!\n');
				return;
			end;
		end;
	end;
end;


%get noise correlation matrix
if(isempty(C))
	if(isempty(D))	%no data
		fprintf('no data for g-factor calculation!\nerror!\n');
		return;
	else
		C=eye(size(D,3));
	end;
end;


%check regularization
if(~isempty(reg_param)|~isempty(reg_param_frac))
	if(length(reg_param)~=size(D,2)&isempty(reg_param_frac))
		fprintf('legnth of regularization parameter is inconssitent to the freq, encoding linesn!\nerror!\n');
		return;
	elseif(~isempty(reg_param_frac))
		if(flag_display)
			fprintf('using fractional [%0.2f] 1st SV as regularization parameter\n',reg_param_frac);
		end;
	end;
	flag_reg=1;
else
	flag_reg=0;
end;

%prepare whitening data
[u,s,v]=svd(C);
W=pinv(sqrt(s))*u';	%whitening matrix

%prepare whitening data
if(isempty(mask))
	mm=sqrt(mean(abs(D).^2,3));
	
	if(isempty(mask_threshold))
		mask_threshold=0.2;
	end;
	
	mask=zeros(size(mm));
	maxx=max(mm(:));
	
	mask(find(mm>maxx.*mask_threshold))=1;
end;


for fe_idx=1:size(D,2)
	if(flag_display)
		fprintf('.');	
	end;
	
	d=squeeze(D(:,fe_idx,:));
	
	d_w=d*W';	%data whitening
	
	S=[];		%encoding matrix;
	for ch_idx=1:size(d_w,2)
		S=cat(1,S,A*diag(d_w(:,ch_idx)));
	end;

	if(flag_reg)
		[uu,ss,vv]=svd(S,0);
		g_unreg(:,fe_idx)=diag(vv*pinv(ss).^2*vv').*diag(vv*(ss).^2*vv');
		
		if(isempty(reg_param_frac))
			gamma=diag(diag(ss)./(diag(ss).^2+reg_param(fe_idx).^2));
		else
			gamma=diag(diag(ss)./(diag(ss).^2+(ss(1)*(1+reg_param_frac).^2)));		
		end;
		
		g_reg(:,fe_idx)=diag(vv*(gamma).^2*vv').*diag(vv*(ss).^2*vv');
	else

		%ss=sum(abs(S).^2,2);
		%wss=diag(1./(sqrt(ss)));
		%S=wss*S;
		
		M=S'*S;
		g_unreg(:,fe_idx)=diag(inv(M)).*diag(M);
		
	end;
	
end;

%g-factor is always real. the minor imaginary part are due to numerical precision
g_unreg=abs(g_unreg);
g_reg=abs(g_reg);


mask_g_unreg=mask.*g_unreg;
if(~isempty(g_reg))
	mask_g_reg=g_reg.*mask;
else
	mask_g_reg=[];
end;



if(flag_display)
	fprintf('\nDONE!\n');
end;









			
		
		
		