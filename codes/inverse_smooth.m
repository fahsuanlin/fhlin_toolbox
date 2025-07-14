function [smooth_value,vertex,w_regrid,Ds,D]=inverse_smooth(file_asc_surf,varargin)
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

Ds=[];
D=[];

w_regrid=[];

exc_vertex=[];
inc_vertex=[];

flag_fixval=1;
flag_display=0;
flag_regrid=1;
flag_regrid_zero=0;
flag_scale=1;

n_ratio=16;

default_neighbor=5;


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
        case 'flag_scale'
            flag_scale=option_value;
        case 'ds'
            Ds=option_value;
        case 'Ds'
            Ds=option_value;
        case 'D'
            D=option_value;
        case 'default_neighbor'
            default_neighbor=option_value;
        case 'n_ratio'
            n_ratio=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option);
            return;
    end;
end;


flag_050619=1;


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
if(~flag_050619)
    d1=[connection(1,:);[1:nf];ones(1,size(connection,2))]';
    d2=[connection(2,:);[1:nf];ones(1,size(connection,2))]';
    d3=[connection(3,:);[1:nf];ones(1,size(connection,2))]';
    A=spones(spconvert([d1;d2;d3]));
    xx=sum(A,2);
    %B=spones(A*A').*0.5+speye(size(A,1),size(A,1)).*0.5;
    %yy=sum(B,2);
end;

%prepare a graph if regridding is enabled
if(flag_regrid|flag_fixval)
    dd1=[connection(1,:);connection(2,:)]';
    dd2=[connection(2,:);connection(3,:)]';
    dd3=[connection(3,:);connection(1,:)]';
    dd=[dd1;dd2;dd3];
    dd=unique(sort(dd,2),'rows');
    G=graph(dd(:,1)',dd(:,2)',ones(1,size(dd,1)));
end;


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
if(~iscell(inc_vertex))
if(~isempty(inc_vertex))
    tmp=setdiff([1:length(value)],inc_vertex);
    exc_vertex=union(exc_vertex,tmp);
end;
end;

v_min=min(value(:));
v_max=max(value(:));
v_idx=find(abs(value(:))>eps);

if(flag_050619)
    if(isempty(D))
        dd1=[connection(1,:);connection(2,:)]';
        dd2=[connection(2,:);connection(3,:)]';
        dd3=[connection(3,:);connection(1,:)]';
        dd4=[connection(2,:);connection(1,:)]';
        dd5=[connection(3,:);connection(2,:)]';
        dd6=[connection(1,:);connection(3,:)]';
        dde=[[1:size(vertex,2)]; 1:size(vertex,2)]'; %for self-weighting
        dd=[dd1;dd2;dd3;dd4;dd5;dd6;dde];
        %dd=[dd1;dd2;dd3;dd4;dd5;dd6];
        %dd=unique(sort(dd,2),'rows');
        dd=unique(dd,'rows');
        dd(:,3)=1;
        
        D=spconvert(dd);
        D=D*D; %every repetition increases neighbors one connection further away from the source vertex
        
        D(find(D(:)>1))=1;
        D=spones(D);
    end;
    nD=sum(D,2);

    
    
    %for initial interpolation
    if(flag_regrid)
        dd0=[dd1;dd2;dd3;dd4;dd5;dd6];
        dd0=unique(dd0,'rows');
        dd0(:,3)=1;
        
       
        G = digraph(dd0(:,1),dd0(:,2));
        Dm = distances(G, value_idx);
        
        %dijk_A=spones(spconvert(dd0)); %<---replaced by 'digraph' and 'distances' functions after Matlab 2021.
        %Dm=dijkstra(dijk_A,value_idx);
        
        Dme=exp(-Dm.*2);
        Dme=Dme./repmat(sum(Dme,1),[size(Dme,1) 1]);
        non_value_idx=setdiff([1:size(Dme,2)],value_idx);
        for tt=1:size(value,2)
            %value(:,tt)=fmri_scale(Dme'*value(value_idx,tt),max(value,tt),min(value,tt));
            value(non_value_idx,tt)=Dme(:,non_value_idx)'*value(value_idx,tt);
        end;
    end;
    
    for tt=1:size(value,2)
        sv=value(:,tt);
        ii=find(abs(sv(:))>eps);
        vv_max=max(value(:,tt));
        vv_min=min(value(:,tt));
        for idx=1:step
            
            %sv(ii)=value(ii,tt);
            
            %ii=find(abs(sv(:))>eps);
            %sv=D(:,ii)*sv(ii);
            sv=(D*sv)./nD;
            %sv=D*sv;
            %sv=fmri_scale(sv,vv_max,vv_min);
            sv(exc_vertex)=0;

        end;
        if(~flag_regrid)
            smooth_value(:,tt)=sv*n_ratio;
        else
            smooth_value(:,tt)=sv;
        end;

        if(flag_scale)
            tmp=sv;
            
            idx=find(sv>eps);
            tmp(idx)=fmri_scale(sv(idx),v_max,eps);
            
            idx=find(sv<-eps);
            tmp(idx)=fmri_scale(sv(idx),-eps,v_min);
            
            smooth_value(:,tt)=tmp;
        end;
    end;
end;
return;

nn={};
D=[];

for tt=1:size(value,2)
    if(flag_display)
        fprintf('smoothing [%d|%d] ',tt,size(value,2));
    end;
    w=value(:,tt);
    w0=w;
    pidx=find(w0>eps);
    nidx=find(w0<-eps);
    
    mmin0=min(w0(:));
    mmax0=max(w0(:));
    
    if(flag_regrid)
        if(isempty(value_idx))
            if(~flag_regrid_zero)
                non_zero=find(abs(w)>100.*eps);
                %non_zero=[1:length(w)];
                if(flag_display)
                    fprintf('gridding...');
                end;
                
                if(isempty(Ds))
                    %regrdding from graph
                    count=0;
                    for n_idx=1:length(non_zero)
                        nn{n_idx}=nearest(G,non_zero(n_idx),default_neighbor);
                        count=count+length(nn{n_idx}(:));
                    end;
                    
                    D=zeros(count+length(non_zero),3);
                    count=1;
                    for n_idx=1:length(non_zero)
                        D(count,:)=[non_zero(n_idx) non_zero(n_idx) 1];
                        count=count+1;
                        D(count:count+length(nn{n_idx})-1,:)=[nn{n_idx}(:), ones(length(nn{n_idx}(:)),1).*non_zero(n_idx), ones(length(nn{n_idx}(:)),1)./default_neighbor];
                        count=count+length(nn{n_idx});
                    end;
                    %                     for n_idx=1:length(w)
                    %                         D(count,:)=[n_idx n_idx 1];
                    %                         count=count+1;
                    %                     end;
                    
                    Ds=spconvert(D);
                    Ds=Ds(:,non_zero);
                    
                end;
                Dsn=sum(Ds,2);
                nnz=find(Dsn>eps);
                
                %tmp=(Ds(nnz,:)*w(non_zero))./Dsn(nnz);
                tmp=(Ds(nnz,:)*w(non_zero));
                w(nnz)=tmp;
                %w=(Ds*w(non_zero))./Dsn;
                
                w(find(w(:)>v_max))=v_max;
                w(find(w(:)<v_min))=v_min;
                
            else
                non_zero=[1:length(w)];
                
                %regrdding from graph
                for n_idx=1:length(non_zero)
                    nn=nearest(G,non_zero(n_idx),default_neighbor);
                    w(nn)=w(non_zero(n_idx));
                end;
                
                w(find(w(:)>v_max))=v_max;
                w(find(w(:)<v_min))=v_min;
                
            end;
        else
            non_zero=[1:length(w)];
            [uv,uv_idx]=unique(vertex(1:3,value_idx+1)','rows'); %remove duplicate rows
            w=griddatan(uv,w(uv_idx),vertex(1:3,:)','nearest');
            
            w_regrid=w;
        end;
        
        scale_idx=find(abs(w)>eps);
        
        if(flag_display)
            fprintf('done!\n');
        end;
    else
        non_zero=[1:length(w)];
    end;
    
    if(tt==1)
        smooth_value=zeros(length(w),size(value,2));
    end;
    
    
    %    w0=w;
    
    
    if(~isempty(value_idx))
        non_zero_full=value_idx+1;
    else
        non_zero_full=non_zero;
    end;
    
    
    if(isempty(nn)&&isempty(Ds))
        if(flag_regrid|flag_fixval)
            %regrdding from graph
            clear nn;
            for n_idx=1:length(non_zero)
                nn{n_idx}=nearest(G,non_zero(n_idx),default_neighbor);
            end;
        end;
    end;
    
    if(isempty(D))
        if(isempty(Ds))
            D=zeros(count+length(non_zero),3);
            count=1;
            for n_idx=1:length(non_zero)
                D(count,:)=[non_zero(n_idx) non_zero(n_idx) 1];
                count=count+1;
                D(count:count+length(nn{n_idx})-1,:)=[nn{n_idx}(:), ones(length(nn{n_idx}(:)),1).*non_zero(n_idx), ones(length(nn{n_idx}(:)),1)./default_neighbor];
                count=count+length(nn{n_idx});
            end;
            %             for n_idx=1:length(w)
            %                 D(count,:)=[n_idx n_idx 1];
            %                 count=count+1;
            %             end;
            Ds=spconvert(D);
            Ds=Ds(:,non_zero);
        end;
        Dsn=sum(Ds,2);
        nnz=find(Dsn>eps);
    end;
    
    for ss=1:step
        if(flag_fixval)
            if(flag_display) fprintf('.'); end;
            %tmp=(Ds(nnz,:)*w(non_zero))./Dsn(nnz);
            tmp=(Ds(nnz,:)*w(non_zero));
            w(nnz)=tmp;
            w(non_zero)=w0(non_zero);
        else
            if(flag_display) fprintf('#'); end;
            %tmp=(Ds(nnz,:)*w(non_zero))./Dsn(nnz);
            tmp=(Ds(nnz,:)*w(non_zero));
            w(nnz)=tmp;
        end;
        
        
        ww(:,ss)=w(:);
        
        mmin=min(w(:));
        mmax=max(w(:));
        
        w=(w-mmin).*(mmax0-mmin0)./(mmax-mmin)+mmin0;
        
        w(exc_vertex)=0;
    end;
    if(flag_display) fprintf('\n'); end;
    
    if(~isempty(exc_vertex))
        w(exc_vertex)=nan;
    end;
    
    mmin=min(w(:));
    mmax=max(w(:));
    
    smooth_value(:,tt)=(w-mmin).*(mmax0-mmin0)./(mmax-mmin)+mmin0;
end;

return;


