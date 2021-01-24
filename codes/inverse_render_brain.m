function inverse_render_brain(vertex,face,varargin)
%
%inverse_render_brain	render data on brain
%
%inverse_render_brain(brain_vertex,brain_face,[fg_data,fg_vertex,threshold,bg_data,bg_vertex]);
%brain_vertex: the brain mesh vertices from inverse_patch_brain
%brain_face: the brain mesh faces from inverse_patch_brain
%fg_data: foreground data (1D) 
%fg_vertex: vertices for the foreground data
%threshold: a two-element 1D vector specifiend the threshold to be displayed.
%bg_data: background data (1D); e.g. curvature
%bg_vertex: vertices for the background data
%
%fhlin@sep. 10, 2001

fg_data=[];
fg_weight=1;
fg_color=[];
fg_v=[];
fg_idx=[];
threshold=[];
bg_data=[];
bg_weight=1;
bg_v=[];
dec_dipole=[];
triangle=[];
flag_interpolation=1;
flag_point=0;
flag_patch=1;
point_idx=[];
point_dipole_idx=[];
flag_colorbar=0;


fig_visible='off';

%color map of the figure.....
%cmap=hot(128);
%cmap=cmap(49:128,:);
cmap=autumn(80);

if(nargin>4)
    for i=1:length(varargin)/2
        option_name=varargin{(i-1)*2+1};		
        option_value=varargin{i*2};
        
        switch lower(option_name)
        case 'fg_data'
            fg_data=option_value;
        case 'fg_weight'
            fg_weight=option_value;
        case 'fg_color'
            fg_color=option_value;
        case 'fg_v'
            fg_v=option_value;
        case 'fg_idx'
            fg_idx=option_value;
        case 'bg_data'
            bg_data=option_value;
        case 'bg_weight'
            bg_weight=option_value;
        case 'bg_v'
            bg_v=option_value;
        case 'threshold'
            threshold=option_value;
        case 'interpolation'
            if(strcmp(option_value,'on'))
                flag_interpolation=1;
            else
                flag_interpolation=0;
            end;
        case 'point'
            if(strcmp(option_value,'on'))
                flag_point=1;
            else
                flag_point=0;
            end;         
        case 'patch'
            if(strcmp(option_value,'on'))
                flag_patch=1;
            else
                flag_patch=0;
            end;         
        case 'triangle'
            triangle=option_value;
        case 'dec_dipole'
            dec_dipole=option_value;
        case 'point_idx'
            point_idx=option_value;
		case 'point_dipole_idx'
			point_dipole_idx=option_value;
		case 'flag_colorbar'
			flag_colorbar=option_value;
        otherwise
            fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
            return;
        end;
    end;
end;



if(isempty(threshold))
    ff=sort(max(fg_data,[],2));
    threshold(1)=ff(floor(length(ff).*0.90));
    threshold(2)=ff(floor(length(ff).*0.99));
    fprintf('automatic thesholding between [%2.2f] and [%2.2f]\n',min(threshold),max(threshold));
end;


%interpolating data
if(isempty(bg_data))	%no background
    fprintf('no background...\n');
    data=ones(size(vertex,1),1)*[1 1 1].*0.7;	
else
    fprintf('rendering background...\n');
    %render background
    if(~isempty(bg_v))
        if(size(vertex,1)>size(bg_v,1))
            data_1d=griddatan(bg_v,bg_data,vertex);
        else
            data_1d=griddatan(bg_v,bg_data,vertex);
        end;
    elseif(length(bg_data)==size(vertex,1))
        data_1d=bg_data;
    else
        fprintf('wrong background data type!\n');
        return;
    end;
    
    data=zeros(size(data_1d,1),3);
    idx_pos=find(data_1d>=0);
    data(idx_pos,:)=repmat([1 1 1],[length(idx_pos),1]).*0.2;
    
    idx_neg=find(data_1d<0);
    data(idx_neg,:)=repmat([1 1 1],[length(idx_neg),1]).*0.5;
end;
data_bg=data.*bg_weight;


if(isempty(fg_data))	% no foreground
    fprintf('no foreground...\n');
    
    %figure;
    %set(gcf,'visible',fig_visible);
    render_surface(face,vertex,data_bg);
else
    fprintf('rendering foreground...\n');
    
    if(~isempty(dec_dipole)) %foreground is based on decimadted dipole
        if((~isempty(triangle))&(isequal(triangle.dec_dipole,dec_dipole)))
            fprintf('using existed triangulation data...\n');
            tri=triangle.tri;
            t=triangle.t;
            p=triangle.p;
        else
            fprintf('about triangluation...\n');
            fprintf('press any key to start...\n');
            pause;
            
            fprintf('triangulation...\n');
            tri = delaunayn(fg_v);
            % Find the nearest triangle (t)
            [t,p] = tsearchn(fg_v,tri,vertex);
            fprintf('triangulation...DONE!\n');
        end;
        data_1d = zeros(size(vertex,1),1);
    end;
    
    for i=1:size(fg_data,2)
        
        fg_data_1d=fg_data(:,i);
        
        if(flag_patch)
            if(size(vertex,1)==size(fg_v,1))
                disp('same size of data; no interpolation');
                data_1d=fg_data;
            else
                if(~isempty(dec_dipole))
                    if(flag_interpolation)
                        disp('linear interpolation from the given foreground to the brain mesh');
                        
                       %parallelized version to do linear interpolation; refer to griddatan.m for details.
						idx_notnan=find(~isnan(t));
                        idx_nan=find(isnan(t));         

						%k = dsearchn(vertex(dec_dipole+1,:),tri,vertex(idx_nan,:));
						k = dsearchn(vertex(idx_notnan,:),tri,vertex(idx_nan,:));
						%p(idx_nan,:)=p(dec_dipole(k)+1,:);
						p(idx_nan,:)=p(idx_notnan(k),:);
						%t(idx_nan)=t(dec_dipole(k)+1);
						t(idx_nan)=t(idx_notnan(k));
						data_1d=sum(p.*fg_data_1d(tri(t,:)),2);

%                       data_1d(idx_notnan)=sum(p(idx_notnan,:).*fg_data_1d(tri(t(idx_notnan),:)),2);
%						data_1d(idx_nan)=fg_data_1d(k);

                        if(~isempty(fg_color))
                            data_1d_color=zeros(length(data_1d),3);
                            data_1d_color(idx,1)=sum(p(idx,:).*fg_color(tri(t(idx),:),1),2); 
                            data_1d_color(idx,2)=sum(p(idx,:).*fg_color(tri(t(idx),:),2),2); 
                            data_1d_color(idx,3)=sum(p(idx,:).*fg_color(tri(t(idx),:),3),2); 
                        end;
                    else
                        disp('nearest interpolation from the given foreground to the brain mesh');
                        
                        %refer to griddatan.m for details.
                        k = dsearchn(vertex(dec_dipole+1,:),tri,vertex);
                        zi = k;
                        d = find(isfinite(k));
                        zi(d) = fg_data_1d(k(d));
                        data_1d=zi;
                        
                        if(~isempty(fg_color))
                            data_1d_color=zeros(length(data_1d),3);
                            data_1d_color(d,1)=fg_color(k(d),1); 
                            data_1d_color(d,2)=fg_color(k(d),2); 
                            data_1d_color(d,3)=fg_color(k(d),3); 
                        end;
                    end;
                else
                    if(isempty(fg_idx))
                        fprintf('undecimated dipole rendering requires [fg_idx] variable!\n');
                        fprintf('error!\n');
                        return;
                    end;
                    
                    fprintf('direct painting using dipole location from dip file...\n');	                        
                    data_1d=zeros(size(vertex,1),1);
                    data_1d(fg_idx+1)=fg_data_1d;	%fg_idx should be zero-based
                    
                    if(~isempty(fg_color))
                        data_1d_color=zeros(length(data_1d),3);
                        data_1d_color(fg_idx)=fg_color;
                    end;
                end;
            end;
        else
            data_1d=fg_data_1d;
            
            if(~isempty(fg_color))
                data_1d_color=zeros(length(data_1d),3);
                data_1d_color(fg_idx)=fg_color;
            end;
        end;
        
		if(length(threshold)==1|length(threshold)==2)
	        idx=find(data_1d>=min(threshold));
        
	        data=data_bg;
        
			if(max(size(threshold))==1) %threshold is a scalar
				threshold=[threshold,max(data_1d).*0.8];
			end;
        
			if(isempty(fg_color))
				data(idx,:)=inverse_get_color(cmap,data_1d(idx),max(threshold),min(threshold));
			else
				data(idx,:)=data_1d_color(idx,:);
			end;
		end;



		if(length(threshold)==4)
	        data=data_bg;

	        idx=find(data_1d>=min(threshold([1,2])));

			data(idx,:)=inverse_get_color(autumn,data_1d(idx),max(threshold([1,2])),min(threshold([1,2])));

	        idx=find(data_1d<=max(threshold([3,4])));
        
			cc=winter;
			cmap_cold=flipud(cc(1:30,:));
			data(idx,:)=inverse_get_color(cmap_cold,data_1d(idx),max(threshold([3,4])),min(threshold([3,4])));
		end;

        
        render_surface(face,vertex,data);
        
        hold on;
        
        
        if(flag_point)
            if(~isempty(dec_dipole))
                if(isempty(point_idx))
                    idx=find(fg_data_1d>=min(threshold));
                    for j=1:length(idx)
                        %fprintf('[%d]--->%d\n',j,idx(j));
	                    plot3(fg_v(idx(j),1),fg_v(idx(j),2),fg_v(idx(j),3),'.','Color',[0 0 1],'markersize',10);
                    end;
                else
                    for j=1:length(point_idx)
                        %fprintf('[%d]--->%d\n',j,idx(j));
                        plot3(fg_v(point_idx(j),1),fg_v(point_idx(j),2),fg_v(point_idx(j),3),'.','Color',[0 0 1],'markersize',10);
                    end;
                end;
            else
                if(isempty(point_idx))
                    for j=1:length(idx)
                        %fprintf('[%d]--->%d\n',j,idx(j));
                        plot3(vertex(fg_idx(j),1),vertex(fg_idx(j),2),vertex(fg_idx(j),3),'.','Color',[0 0 1],'markersize',3);
                    end;
                else
                    %fprintf('[%d]--->%d\n',j,idx(j));
                    plot3(vertex(point_idx,1),vertex(point_idx,2),vertex(point_idx,3),'.','Color',[0 0 1],'markersize',10);
                end;
            end;

	 		if(~isempty(point_dipole_idx))
                    plot3(vertex(point_dipole_idx,1),vertex(point_dipole_idx,2),vertex(point_dipole_idx,3),'.','Color',[1 0 0],'markersize',3);
			end;
            hold on;
        end;

%		if(flag_colorbar)
%			ax=gca;
%			set(ax,'pos',[0 0.1 1 0.9]);
%			inverse_colorbar(ax,threshold);
%			axis(ax);
%		else
%			ax=gca;
%			set(ax,'pos',[0 0 1 1]);
%			axis(ax);
%		end;
    end;
end;


%set(gcf,'KeyPressFcn','inverse_render_handle(''kb'')');
set(gcf,'WindowButtonDownFcn','inverse_render_handle(''bd'')');

global inverse_vertex;
inverse_vertex=vertex;

global inverse_dec_dipole;
inverse_dec_dipole=dec_dipole;

return;


function render_surface(face,vertex,data)
%render
fprintf('rendering...\n');

set(gcf,'Renderer','opengl')

p=patch('Faces',face,...
    'Vertices',vertex,...
    'FaceVertexCData',data,...
    'MarkerEdgeColor','none',...
    'EdgeColor','none',...
    'FaceColor','interp',...
    'FaceLighting', 'flat',...
    'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
    'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);

%add lights
for i=1:4
%    for j=0:10
%        camlight(45*i,-150+30*j);
		camlight(90*i,0);
%    end;
end;

set(gcf,'color',[0 0 0]);
set(gca,'color',[0 0 0]);
set(gca,'xcolor',[1 1 1]);
set(gca,'ycolor',[1 1 1]);
set(gca,'zcolor',[1 1 1]);
set(gca,'xgrid','on') 
set(gca,'ygrid','on')
set(gca,'zgrid','on')
axis equal tight;
material dull;
set(gcf,'InvertHardcopy','off');

%determine the left/right hemisphere
tmp=get(gca,'xlim');
[mx0,idx]=max(abs(tmp));
if(mx0/tmp(idx)>0) %right hemisphere
    view([75,30]);
else
    view([-75,30]);
end;
return;
