function inverse_patch_brain(surf_file,varargin)
% inverse_patch_brain	patch surfaces from freesurfer for matlab visualization
%
%	inverse_patch_brain(surf_file,[output_file, curv_file, reduce_ratio])
%
% surf_file: the ASCII version of the surface to be patched, including the path
% output_file: the output file name. The default is "patch_brain.mat".
% curv_file: the curvature file associated with the hemisphere. Use *.curv file from Freesurfer. Default takes no curvature.
% reduce_ratio: a scalar describes the ratio of the new patch and the old patch. If it is between 1 and 0, automatic patch reduction will be performed. 
%
% fhlin@Sep. 10, 2001
%

curv_file=[];
dip_file=[];
dec_file=[];
output_file='patch_brain';
reduce_ratio=0.1;



if(nargin>4)
	for i=1:length(varargin)/2
		option_name=varargin{(i-1)*2+1};		
		option_value=varargin{i*2};

		switch lower(option_name)
		case 'output_file'
			output_file=option_value;
			fprintf('output_file=[%s]\n',output_file);
		case 'curv_file'
			curv_file=option_value;
			fprintf('curvt_file=[%s]\n',curv_file);
		case 'dip_file'
			dip_file=option_value;
			fprintf('dip_file=[%s]\n',dip_file);
		case 'dec_file'
			dec_file=option_value;
			fprintf('dec_file=[%s]\n',dec_file);
		case 'reduce_ratio'
			reduce_ratio=option_value;
			fprintf('reduce_ratio=[%f]\n',reduce_ratio);
		otherwise
  		        fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
		    	return;
        end;
	end;
end;

% read decimated dipoles info
if((~isempty(dip_file))&(~isempty(dec_file)))
	[dipinfo,dec_dipole]=inverse_read_dipdec(dip_file,dec_file);
else
	dipinfo=[];
	dec_dipole=[];
end;


% read surface curvature
if(~isempty(curv_file))
	[curv]=inverse_read_curv(curv_file);
else
	curv=[];
end;

% read surface desciption
[vertices, faces, vertex_data, face_data]=inverse_read_surf_asc(surf_file);

face_data=face_data(1:3,:)'+1;
vertex_data=vertex_data(1:3,:)';

v0=size(vertex_data);
f0=size(face_data);

if((reduce_ratio<1)&(reduce_ratio>0))
	%reduce model
	fprintf('simplifying brain mesh (model reduction)...\n');
	[nf,nv]=reducepatch(face_data,vertex_data,reduce_ratio,'fast');
	f1=size(nf);
	v1=size(nv);
	fprintf('original faces: %s\n',mat2str(f0));
	fprintf('reduced faces: %s\n',mat2str(f1));
else
	fprintf('keep the original patch configuration...\n');
	nf=face_data;
	nv=vertex_data;
end;


% creating mapping between the original mesh and new mesh
fprintf('creating mapping index for nearest vertex between two models (0-based index)...\n');
if((reduce_ratio<1)&(reduce_ratio>0)) %reduced model
	fprintf('from new patch to original surface...\n');	% 0-based indices
	orig2patch_idx=griddatan(nv,[1:size(nv,1)]'-1,vertex_data,'nearest');
	fprintf('from original surface to new patch...\n');	% 0-based indices
	patch2orig_idx=griddatan(vertex_data,[1:size(vertex_data,1)]'-1,nv,'nearest');
else
	orig2patch_idx=[1:size(nv,1)]'-1;	% 0-based indices
	patch2orig_idx=[1:size(vertex_data,1)]'-1;	% 0-based indices
end;


if((~isempty(dipinfo))&(~isempty(dec_dipole)))
	fprintf('triangulation for decimated diopoles...\n');
	fg_v=vertex_data(orig2patch_idx(find(dec_dipole))+1,:);
	tri = delaunayn(fg_v);
	% Find the nearest triangle (t)
	[t,p] = tsearchn(fg_v,tri,vertex_data);
	triangle.tri=tri;
	triangle.p=p;
    triangle.t=t;
	triangle.dec_dipole=find(dec_dipole)-1;
	fprintf('triangulation...DONE!\n');
else
    triangle=[];
end;

if(~isempty(curv))
	%interpolating color
	nc=curv(patch2orig_idx+1);
	%fprintf('interpolating curvature...\n');
	%nc=griddatan(vertex_data,curv,nv);

	ncc=zeros(size(nc,1),3);
	idx_pos=find(nc>0);
	%ncc(idx_pos,:)=nc(idx_pos)./max(nc)*[1 0 0];
	ncc(idx_pos,:)=repmat([1 1 1],[length(idx_pos),1]).*0.5;

	idx_neg=find(nc<0);
	%ncc(idx_neg,:)=abs(nc(idx_neg))./abs(min(nc))*[0 1 0];
	ncc(idx_neg,:)=repmat([1 1 1],[length(idx_neg),1]).*0.2;
else
	nc=ones(size(nv,1),1);
	ncc=ones(size(nv,1),3).*0.6;
end;

%save output file
if(~isempty(curv))
	vertex=nv;
	face=nf;
	curv=nc;
	save(output_file,'vertex','face','curv','orig2patch_idx','patch2orig_idx');
else
	vertex=nv;
	face=nf;
	save(output_file,'vertex','face','orig2patch_idx','patch2orig_idx');
end;

% store triangulation data
if(~isempty(triangle))
	save(output_file,'triangle','-append');
end;

%render
ax=gca;
fprintf('rendering...\n');
p=patch('Faces',nf,...
   'Vertices',nv,...
   'FaceVertexCData',ncc,...
   'EdgeColor','none',...
   'FaceColor','interp',...
   'FaceLighting', 'phong',...
   'SpecularStrength' ,0.7, 'AmbientStrength', 1.0,...
   'DiffuseStrength', 0.9, 'SpecularExponent', 1000.0);

camlight
set(gcf,'color',[0 0 0]);
set(gca,'color',[0 0 0]);
set(gca,'xcolor',[1 1 1]);
set(gca,'ycolor',[1 1 1]);
set(gca,'zcolor',[1 1 1]);
set(gca,'xgrid','on') 
set(gca,'ygrid','on')
set(gca,'zgrid','on')
axis equal tight;

%determine the left/right hemisphere
tmp=get(gca,'xlim');
[mx0,idx]=max(abs(tmp));
if(mx0/tmp(idx)>0) %right hemisphere
	view([75,30]);
	lightangle(75,30);
else
	view([-75,30]);
	lightangle(-75,30);
end;







