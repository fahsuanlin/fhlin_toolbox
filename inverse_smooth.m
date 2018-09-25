function [smooth_value,vertex,w_regrid]=inverse_smooth(file_asc_surf,varargin)
%
% inverse_smooth	smoothing surface values 
%
% [smooth_value,dd]=inverse_smooth(file_asc_surf,varargin)
% file_asc_surf		surface file in ASCII 
% 	[option, option_value]
%	'wfile':	w-file name/path
%	'stcfile': 	stc-file name/path
%	'value':	2D value matrix to be smoothed
%	'step':		the number of smoothing steps (default: 5)
%
% fhlin@feb. 26, 2004
%

wfile='';
stcfile='';
value=[];
value_idx=[];
step=5;
vertex=[];
face=[];
nv=[];
nf=[];

w_regrid=[];

exc_vertex=[];
inc_vertex=[];

flag_fixval=1;
flag_display=1;
flag_regrid=1;
flag_regrid_zero=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch option
        case 'wfile'
            wfile=option_value;
        case 'stcfile'
            stcfile=option_value;
        case 'value'
            value=option_value;
        case 'value_idx'
            value_idx=option_value;
        case 'step'
            step=option_value;
        case 'vertex'
            vertex=option_value;
        case 'exc_vertex'
            exc_vertex=option_value;
        case 'inc_vertex'
            inc_vertex=option_value;
        case 'face'
            face=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_fixval'
            flag_fixval=option_value;
        case 'flag_regrid'
            flag_regrid=option_value;
        case 'flag_regrid_zero'
            flag_regrid_zero=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option);
            return;
	end;
end;

if(~isempty(file_asc_surf))
	if(strcmp('asc',file_asc_surf(end-2:end)))
		[nv,nf,vertex,face]=inverse_read_surf_asc(file_asc_surf);
	else
		[vertex,face]=read_surf(file_asc_surf); %freesurfer dev toolbox 061706
		vertex=vertex';
		face=face';
		nv=size(vertex,2);
		nf=size(face,2);
	end;
else
	nv=size(vertex,2);
	nf=size(face,2);
end;

if(flag_display) fprintf('constructing connection graph\n'); end;
%assume triangle surface!!
connection=face(1:3,:)+1; %shift zero-based dipole indices to 1-based dipole indices

d1=[connection(1,:);[1:nf];ones(1,size(connection,2))]';
d2=[connection(2,:);[1:nf];ones(1,size(connection,2))]';
d3=[connection(3,:);[1:nf];ones(1,size(connection,2))]';
A=spones(spconvert([d1;d2;d3]));
xx=sum(A,2);
B=spones(A*A'+speye(size(A,1),size(A,1)));
yy=sum(B,2);

%yy1=sum(spones(A*A'+speye(size(A,1),size(A,1))),2);
%yy2=sum(spones(A*A'*A*A'+speye(size(A,1),size(A,1))),2);
%yy3=sum(spones(A*A'*A*A'*A*A'+speye(size(A,1),size(A,1))),2);
%yy4=sum(spones(A*A'*A*A'*A*A'*A*A'+speye(size(A,1),size(A,1))),2);

% keyboard;
% neighbor=find(B(:,52363));

if(~isempty(wfile))
	[dvalue,dec_dip] = inverse_read_wfile(wfile);
	value=zeros(nv,size(dvalue,2));
	value(dec_dip+1,:)=dvalue;
end;

if(~isempty(stcfile))
	[dvalue,dec_dip]=inverse_read_stc(stcfile);
	value=zeros(nv,size(dvalue,2));
	value(dec_dip+1,:)=dvalue;
end;

if(isempty(value))
	fprintf('nothing to be smoothed!\n');
	return;
end;

if(min(size(value))==1)
	value=reshape(value,[length(value),1]);
end;

%smooth_value=zeros(size(value));
%dd=zeros(size(value,2),step);

%inclusive label
if(~isempty(inc_vertex))
    tmp=setdiff([1:length(value)],inc_vertex);    
    exc_vertex=union(exc_vertex,tmp);    
end;

for tt=1:size(value,2)
    if(flag_display)
    	fprintf('smoothing [%d|%d]',tt,size(value,2));
    end;
    w=value(:,tt);
	w0=w;
	pidx=find(w0>eps);
	nidx=find(w0<-eps);
	
    if(flag_regrid)
        if(isempty(value_idx))
            if(~flag_regrid_zero)
                non_zero=find(abs(w)>eps);
                if(flag_display)
                    fprintf('gridding...');
                end;
                w=griddatan(vertex(1:3,non_zero)',w(non_zero),vertex(1:3,:)','nearest');
            else
                non_zero=[1:length(w)];
                w=griddatan(vertex(1:3,non_zero)',w(non_zero),vertex(1:3,:)','nearest');
            end;
        else
            non_zero=[1:length(w)];
            [uv,uv_idx]=unique(vertex(1:3,value_idx+1)','rows'); %remove duplicate rows
            w=griddatan(uv,w(uv_idx),vertex(1:3,:)','nearest');
            w_regrid=w;
            %w=griddatan(vertex(1:3,value_idx+1)',w(:),vertex(1:3,:)','nearest');
        end;

        scale_idx=find(abs(w)>eps);

        if(flag_display)
            fprintf('done!\n');
        end;
    end;

    if(tt==1)
        smooth_value=zeros(length(w),size(value,2));
    end;
    
    
    if(~isempty(value_idx))
        non_zero_full=value_idx+1;
    else
        non_zero_full=non_zero;
    end;
    
    for ss=1:step
		
		w=B*w./yy;
		ww(:,ss)=w(:);
                
        if(flag_fixval)
            if(flag_display) fprintf('.'); end;

            if(~isempty(value_idx))
                w(value_idx+1)=w0;
            else
                w(pidx)=w0(pidx);
                w(nidx)=w0(nidx);
            end;
        else
            if(flag_display) fprintf('#'); end;
        end;
            
        mmin=min(w(non_zero_full));
        mmax=max(w(non_zero_full));
        mmin0=min(w0(non_zero));
        mmax0=max(w0(non_zero));
        w=w.*(mmax0-mmin0)./(mmax-mmin);
		
        w(exc_vertex)=0;
	end;
	if(flag_display) fprintf('\n'); end;

    if(~isempty(exc_vertex))
                w(exc_vertex)=nan;
    end;
    
    mmin=min(w(non_zero_full));
    mmax=max(w(non_zero_full));
    mmin0=min(w0(non_zero));
    mmax0=max(w0(non_zero));
	smooth_value(:,tt)=w.*(mmax0-mmin0)./(mmax-mmin);
	%smooth_value(scale_idx,tt)=fmri_scale(w(scale_idx),max(w0(non_zero)),min(w0(non_zero)));
end;

return;


