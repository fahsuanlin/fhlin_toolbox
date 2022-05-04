function inverse_render_bem(varargin)
% inverse_render_bem		showing BEM (1-layer or 3-layer) with/without MEG/EEG sensors
%
% inverse_render_bem(option1,option1_value,...);
%
% option: option_value
%	'subjects_dir': the path of the subjects_dir
%	'subject': the name of the subject to be render
%		* the combination of 'subjects_dir' and 'subject' will be used to find files of BEMs. 
%		* we will look for BEM files at subjects_dir/subject/bem/XXXX.tri for BEMs.	
%	'file_bem_outer_skin': the file name (without path) of the outer skin BEM
%	'file_bem_outer_skull': the file name (without path) of the outer skull BEM
%	'file_bem_inner_skull': the file name (without path) of the inner skull BEM
%	'fwd': matlab FORWARD matrix calculated from MNE stream. This file contains the coordinate transformation information.
%
% fhlin@mar. 28, 2004
%


file_bem_outer_skull='outer_skull.tri';
file_bem_inner_skull='inner_skull.tri';
file_bem_outer_skin='outer_skin.tri';
flag_bem_outer_skull=1;
flag_bem_inner_skull=1;
flag_bem_outer_skin=1;

subjectpath='';

subjects_dir='';
subject='';

Y=[];
timeVec=[];

global inverse_bem_vertex;
global inverse_bem_face;
global inverse_bem_name;
global inverse_bem_idx;

global inverse_bem_bem_fig;
global inverse_bem_explore_fig;


inverse_bem_vertex={};
inverse_bem_face={};
inverse_bem_name={};

coils='mag';

file_fwd=[];

if(nargin>0)
    for i=1:length(varargin)/2
        option_name=varargin{(i-1)*2+1};		
        option_value=varargin{i*2};
        
        switch lower(option_name)
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'subject'
            subject=option_value;
        case 'subjectpath'
            subjectpath=option_value;
        case 'file_bem_outer_skull'
            file_bem_outer_skull=option_value;
        case 'file_bem_outer_skin'
            file_bem_outer_skin=option_value;
        case 'file_bem_inner_skull'
            file_bem_inner_skull=option_value;
        case 'flag_bem_inner_skull'
            flag_bem_inner_skull=option_value;
        case 'flag_bem_outer_skull'
            flag_bem_outer_skull=option_value;
        case 'flag_bem_outer_skin'
            flag_bem_outer_skin=option_value;
        case 'fwd'
            file_fwd=option_value;
        case 'timevec'
            timeVec=option_value;
        case 'y'
            Y=option_value;
	case 'coils',
	    coils=option_value;
        otherwise
            fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
            return;
        end;
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loading data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%preparing files
if(isempty(subjectpath))
	if(~isempty(subjects_dir)&~isempty(subject))
		subjectpath=sprintf('%s/%s',subjects_dir,subject);
	end;
end;
		
if(~isempty(subjectpath))
if(flag_bem_outer_skin)		
	dd=dir(sprintf('%s/bem/%s',subjectpath,file_bem_outer_skin));		
	if(length(dd)==1)
		fprintf('loading outer skin BEM [%s]...\n',dd(1).name);
		[vertex_osn,face_osn]=inverse_read_tri(sprintf('%s/bem/%s',subjectpath,file_bem_outer_skin));
		if(min(min(face_osn))<1)
			[vertex_osn,face_osn]=inverse_read_tri_new(sprintf('%s/bem/%s',subjectpath,file_bem_outer_skin));
		end;
	else
		fprintf('no outer skin BEM ...\n');
	end;
end;

if(flag_bem_outer_skull)		
dd=dir(sprintf('%s/bem/%s',subjectpath,file_bem_outer_skull));	
	if(length(dd)==1)
		fprintf('loading outer skull BEM [%s]...\n',dd(1).name);
		[vertex_os,face_os]=inverse_read_tri(sprintf('%s/bem/%s',subjectpath,file_bem_outer_skull));
		if(min(min(face_os))<1)
			[vertex_os,face_os]=inverse_read_tri_new(sprintf('%s/bem/%s',subjectpath,file_bem_outer_skull));
		end;
	else
		fprintf('no outer skull BEM ...\n');
	end;
end;

if(flag_bem_inner_skull)		
	dd=dir(sprintf('%s/bem/%s',subjectpath,file_bem_inner_skull));		
	if(length(dd)==1)
		fprintf('loading inner skull BEM [%s]...\n',dd(1).name);
		[vertex_is,face_is]=inverse_read_tri(sprintf('%s/bem/%s',subjectpath,file_bem_inner_skull));
		if(min(min(face_is))<1)
			[vertex_is,face_is]=inverse_read_tri_new(sprintf('%s/bem/%s',subjectpath,file_bem_inner_skull));
		end;
	else
		fprintf('no inner skull BEM ...\n');
	end;
end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot 3-layer BEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(subjectpath))
inverse_bem_bem_fig=figure;
if(flag_bem_inner_skull)
	p=patch('Faces',face_is,...
		'Vertices',vertex_is,...
		'FaceVertexCData',ones(size(vertex_is,1),1),...
		'EdgeColor','none',...
		'FaceColor',[0 0.8 0.8],...
		'FaceLighting', 'flat',...
		'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
		'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);
	hold on;
    
    inverse_bem_vertex{end+1}=vertex_is;
    inverse_bem_face{end+1}=face_is;
    inverse_bem_name{end+1}='inner skull';
end;

if(flag_bem_outer_skull)
	p=patch('Faces',face_os,...
		'Vertices',vertex_os,...
		'FaceVertexCData',ones(size(vertex_os,1),1),...
		'EdgeColor',[0.5 0.5 0],...ls
		'FaceColor','none',...
		'FaceLighting', 'flat',...
		'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
 		'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);
	hold on;
    
    inverse_bem_vertex{end+1}=vertex_os;
    inverse_bem_face{end+1}=face_os;
    inverse_bem_name{end+1}='outer skull';
end;

if(flag_bem_outer_skin)
	p=patch('Faces',face_osn,...
		'Vertices',vertex_osn,...
		'FaceVertexCData',ones(size(vertex_osn,1),1),...
		'EdgeColor',[0.8 0.8 0.8].*0.8,...
		'FaceColor','none',...
		'FaceLighting', 'flat',...
		'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
		'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);
	hold on;
    
    inverse_bem_vertex{end+1}=vertex_osn;
    inverse_bem_face{end+1}=face_osn;
    inverse_bem_name{end+1}='outer skin';
end;

view(-150,30);
axis image;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot anatomical surface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(subjectpath))
inverse_bem_explore_fig=figure;

lightangle(90,30); 
lightangle(270,30); 

if(flag_bem_inner_skull)
	vv=vertex_is;
	ff=face_is;
end;

if(flag_bem_outer_skull)
	vv=vertex_os;
	ff=face_os;
end;

if(flag_bem_outer_skin)
	vv=vertex_osn;
	ff=face_osn;
end;

inverse_bem_idx=length(inverse_bem_face);

set(gcf,'Renderer','zbuffer'); lighting phong
global inverse_bem_brain;
inverse_bem_brain=[];

inverse_bem_brain=patch('Faces',ff,...
	'Vertices',vv,...
	'EdgeColor','none',...
	'FaceColor',[1,.75,.65],...
	'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
	'DiffuseStrength', 0.7, 'SpecularExponent', 10.0);
view(-150,30);
hold on; 
lighting phong;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot MEG sensors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch lower(coils)
	case 'mag'
		coil_offset=0;
	case 'grad1'
		coil_offset=1;
	case 'grad2'
		coil_offset=2;
end;

global inverse_bem_coil_offset;
inverse_bem_coil_offset=coil_offset;


if(~isempty(file_fwd))
    fprintf('loading forward [%s] for coordinate transformation...\n',file_fwd);
    load(file_fwd,'MNE_fwd_meg_head_trans','MNE_fwd_mri_head_trans');
end;

    fprintf('loading coil definition...\n');
    load NM306coildef.mat;
    [sensor_type,sensor_x,sensor_y,sensor_z,v1_x,v1_y,v1_z,v2_x,v2_y,v2_z,v3_x,v3_y,v3_z]=textread('vectorview_noname.apos','%d %f %f %f %f %f %f %f %f %f %f %f %f');
	
    global inverse_bem_chanlabels;
    global inverse_bem_sensor;
    global inverse_bem_sensor_visible;
    
    inverse_bem_chanlabels = load('nm306labels.txt');

if(~isempty(file_fwd))
	MNE_fwd_meg_mri_trans=inv(MNE_fwd_mri_head_trans)*MNE_fwd_meg_head_trans;
end;
	VM(:,1)=sensor_x(1:3:end);
	VM(:,2)=sensor_y(1:3:end);
	VM(:,3)=sensor_z(1:3:end);
	VM(:,4)=1; %the sensor coordinate from nm306coildef.mat;
if(~isempty(file_fwd))
	V=VM*(MNE_fwd_meg_mri_trans)'.*(1e3);
else
	V=VM.*1e3;
end;

    global inverse_bem_sensor_V;
    global inverse_bem_sensor_F;
    inverse_bem_sensor_V=V;
    inverse_bem_sensor_F=FM;

    global inverse_bem_patch;
    global inverse_bem_Y;
    global inverse_bem_timeVec;
    
    if(~isempty(Y))
        inverse_bem_Y=Y;
    end;
    
    if(~isempty(timeVec))
        inverse_bem_timeVec=timeVec;
    end;
			
    global inverse_bem_all_channel_fig;

    if(isempty(inverse_bem_all_channel_fig))
	inverse_bem_all_channel_fig=figure;
    else
	figure(inverse_bem_all_channel_fig);
    end;
    inverse_bem_all_channel_fig=gcf;
    set(inverse_bem_all_channel_fig,'WindowButtonDownFcn','inverse_render_bem_handle(''bd'')');
    set(inverse_bem_all_channel_fig,'KeyPressFcn','inverse_render_bem_handle(''kb'')');

    inverse_render_bem_handle('init');



