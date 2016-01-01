function inverse_render_brain_new(varargin)

stc_data=[];
stc_timeVec=[];
stc_timeVec_idx=[];
dfg_data=[];
fg_data=[];
fg_color=[];
fg_v=[];
fg_idx=[];
threshold=[];
bg_data=[];
bg_v=[];
curv=[];
vertex=[];
face=[];
dec_dipole=[];

flag_point=0;
point_idx=[];
point_dipole_idx=[];
flag_colorbar=0;

subject='';
subjects_dir='';
subjectpath='';
hemi='lh';
surf='inflated';
smooth=0;

wfile='';
stcfile='';

file_surf='';

fig_visible='off';

cmap_pos=autumn(80);
cmap_neg=winter(80);

if(nargin>0)
    for i=1:length(varargin)/2
        option_name=varargin{(i-1)*2+1};		
        option_value=varargin{i*2};
        
        switch lower(option_name)
        case 'vertex'
        	vertex=option_value;
        case 'face'
        	face=option_value;
        case 'curv'
        	curv=option_value;
        case 'subjects_dir'
        	subjects_dir=option_value;
        case 'subject'
        	subject=option_value;
        case 'subjectpath'
        	subjectpath=option_value;
        case 'hemi'
        	hemi=option_value;
        case 'surf'
        	surf=option_value;
        case 'fg_data'
            fg_data=option_value;
        case 'dfg_data'
            dfg_data=option_value;
        case 'stc_data'
            stc_data=option_value;
        case 'stc'
            stc_data=option_value;
        case 'stc_timevec'
            stc_timeVec=option_value;
        case 'timevec'
            stc_timeVec=option_value;
        case 'fg_color'
            fg_color=option_value;
        case 'bg_data'
            bg_data=option_value;
        case 'threshold'
            threshold=option_value;
        case 'smooth'
	    smooth=option_value;
	case 'wfile'
	    wfile=option_value;
	case 'stcfile'
	    stcfile=option_value;
        case 'point'
            if(strcmp(option_value,'on'))
                flag_point=1;
            else
                flag_point=0;
            end;         
        case 'dec_dipole'
        	dec_dipole=option_value;
        case 'point_idx'
            point_idx=option_value;
            flag_point=1;
	case 'point_dipole_idx'
		point_dipole_idx=option_value;
		flag_point=1;
	case 'flag_colorbar'
		flag_colorbar=option_value;
        otherwise
            fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
            return;
        end;
    end;
end;

if(isempty(vertex)|isempty(face)|isempty(curv))
	%preparing files
	if(isempty(subjectpath))
		subjectpath=sprintf('%s/%s',subjects_dir,subject);
	end;
	file_surf=sprintf('%s/surf/%s.%s.asc',subjectpath,hemi,surf);
	file_curv=sprintf('%s/surf/%s.curv',subjectpath,hemi);

	[nv,nf,vertex,face]=inverse_read_surf_asc(file_surf);
	face=face(1:3,:)+1; %shift zero-based dipole indices to 1-based dipole indices
	vertex=vertex(1:3,:);
	vertex=vertex';
	face=face';

	[curv]=inverse_read_curv_new(file_curv);
	xx=dir(file_curv);
	%date_file_curv=datenum(xx.date);
	%date_threshold=datenum(2003,1,1);
	%if(max(abs(curv))>1.1*pi&(date_file_curv<date_threshold))
	
	%if(max(abs(curv))>1.1*pi)
	%		fprintf('old format....\n');
	%		[curv]=inverse_read_curv(file_curv);
	%end;
else
	nv=size(vertex,1);
	nf=size(face,1);
end;

stc_timeVec_idx=[];
if(isempty(fg_data)|isempty(dfg_data)|isempty(stc_data))
	if(~isempty(wfile))
		fprintf('reading w file [%s]...\n',wfile);
		[dfg_data,dec_dipole]=inverse_read_wfile(wfile);
		dec_dipole=dec_dipole+1;
	end;

	if(~isempty(stcfile))
		fprintf('reading stc file [%s]...\n',stcfile);
		[dfg_data,dec_dipole]=inverse_read_stc(stcfile);
		dec_dipole=dec_dipole+1;	
	end;

	if(~isempty(stc_data))
		stc_power=sum(abs(stc_data).^2,1);
		[stc_max, stc_timeVec_idx]=max(stc_power);
		
		if(isempty(stc_timeVec))
			fprintf('showing STC at time index [%d]\n',stc_max_idx);
		else
			fprintf('showing STC at time [%2.2f] ms\n',stc_timeVec(stc_timeVec_idx));
		end;
		
		if(~isempty(dec_dipole))
			fg_data=zeros(nv,1);
			fg_data(dec_dipole,:)=stc_data(:,stc_timeVec_idx);
		else
			fprintf('no decimation indices!\');
			return;
		end;
	end;
	
	if(~isempty(dfg_data))
		if(~isempty(dec_dipole))
			fg_data=zeros(nv,size(dfg_data,2));
			fg_data(dec_dipole,:)=dfg_data;
		else
			fprintf('no decimation indices!\');
			return;
		end;
	end;
end;


if(isempty(threshold))
	if(~isempty(fg_data))
		ff=sort(max(fg_data,[],2));
		threshold(1)=ff(floor(length(ff).*0.90));
		threshold(2)=ff(floor(length(ff).*0.99));
		fprintf('automatic thesholding between [%2.2f] and [%2.2f]\n',min(threshold),max(threshold));
	end;
end;

fg_v=vertex;
fg_idx=[1:nv];
bg_v=vertex;
bg_idx=[1:nv];
if(isempty(dec_dipole))
	dec_dipole=[1:nv];
end;

%interpolating data
fprintf('rendering background...\n');
%render background
if(~isempty(curv))
	data_1d=curv;
end;
    
data=zeros(size(data_1d,1),3);
idx_pos=find(data_1d>=0);
data(idx_pos,:)=repmat([1 1 1],[length(idx_pos),1]).*0.2;
 
idx_neg=find(data_1d<0);
data(idx_neg,:)=repmat([1 1 1],[length(idx_neg),1]).*0.35;
data_bg=data;



%smoothing foreground data
if(smooth>0)
	if(isempty(subjectpath))
		subjectpath=sprintf('%s/%s',subjects_dir,subject);
	end;
	file_surf=sprintf('%s/surf/%s.%s.asc',subjectpath,hemi,surf);
	fg_data=inverse_smooth(file_surf,'value',fg_data,'step',smooth);
end;

if(isempty(fg_data))	% no foreground
    fprintf('no foreground...\n');
    render_surface(face,vertex,data);
        
    hold on;
else
    fprintf('rendering foreground...\n');
    data_1d = zeros(size(vertex,1),1);

    for i=1:size(fg_data,2)
        
        data_1d=fg_data(:,i);
      
	if(length(threshold)==1|length(threshold)==2)
		idx=find(data_1d>=min(threshold));
        
	        data=data_bg;
		if(max(size(threshold))==1) %threshold is a scalar
			threshold=[threshold,max(data_1d).*0.8];
		end;
		if(isempty(fg_color))
			data(idx,:)=inverse_get_color(cmap_pos,data_1d(idx),max(threshold),min(threshold));
		else
			data(idx,:)=data_1d_color(idx,:);
		end;
		
		idx=find(data_1d.*(-1)>=min(threshold));
        
		if(isempty(fg_color))
			data(idx,:)=inverse_get_color(cmap_neg,data_1d(idx).*(-1),max(threshold),min(threshold));
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
                    idx=find(data_1d>=min(threshold));
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
    end;
end;
if(strcmp(hemi,'lh'))
	view([-90,0]);
end;
if(strcmp(hemi,'rh'))
	view([90,0]);
end;
axis off;

set(gcf,'WindowButtonDownFcn','inverse_render_handle(''bd'')');
set(gcf,'KeyPressFcn','inverse_render_handle(''kb'')');


global inverse_fig;
inverse_fig=gcf;

global inverse_vertex;
inverse_vertex=vertex;

global inverse_face;
inverse_face=face;

global inverse_curv;
inverse_curv=curv;

global inverse_stc_data;
inverse_stc_data=stc_data;

global inverse_stc_timeVec;
inverse_stc_timeVec=stc_timeVec;

global inverse_stc_timeVec_idx;
if(~isempty(stc_timeVec_idx))
	inverse_stc_timeVec_idx=stc_timeVec_idx;
end;

global inverse_fg_data;
inverse_fg_data=fg_data;

global inverse_dfg_data;
inverse_dfg_data=dfg_data;

global inverse_dec_dipole;
inverse_dec_dipole=dec_dipole;

global inverse_threshold;
inverse_threshold=threshold;

global inverse_dec_dipole;
inverse_dec_dipole=dec_dipole;

global inverse_fg_value;
inverse_fg_value=data_1d;

global inverse_smooth_step;
inverse_smooth_step=smooth;

global inverse_subject;
inverse_subject=subject;

global inverse_subjects_dir;
inverse_subjects_dir=subjects_dir;

global inverse_surf;
inverse_surf=surf;

global inverse_hemi;
inverse_hemi=hemi;

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


for i=1:4
	camlight(90*i,30);
	camlight(90*i,-30);	
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
return;
