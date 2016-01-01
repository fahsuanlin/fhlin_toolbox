function inverse_render_dipole(brain_patch_file,mode,idx,varargin)
% inverse_render_dipole 	render decimated or undecimated dipole on brain patch
%
% inverse_render_dipole(brain_patch_file,mode,idx,opt1,opt_value1,...)
% 
% brain_patch_file: filename and path of the brain patch
% mode: 'dec' or 'dip' for decimated or undecimated dipole
% idx: 
%	'dec': index of decimated dipoles; ranging from 1 to total number of dipoles
%	'dip': index of undecimated dipoles; ranging from 1 to total number of dipoles
%
% option:
%	'dec_dipole': nessary for decimated dipole rendering; 1D vector of decimated dipole indices from the original dip.
%
% 	'idx_value': 1D vector for associated values of the dipole indices; default is setting to all ones.
%
%	'point': 'on' or 'off' (default); showing a blue point of the specified dipole
%	'patch': 'on' or 'off' (default); showing the patch associated with the specified dipole
%	'threshold': 2-element vector of mimimal and maximal display value. values lower than min are not shown; 
%					 values higher than max are saturated.
%	'interpolation': 'on' or 'off'; to switch on/off interpolation among patches
%
%
% Examples:
%
%	inverse_render_dipole(brain_patch_file,'dec',[5,17],'dec_dipole',dec_dipole,'idx_value',[1,2],'point','on','patch','on');
%
%		shwoing the decimated dipole number 5 and 17 with value 1 and 2 respectively. rendering with patches associated
%		with these two dipoles and also a blue dot on each of them
%
%	inverse_render_dipole(brain_patch_file,'dip',[1000:10:1200],'patch','on');
%
%		showing the location of diople [1000:10:1200] with a blue poitn at every dipole location
%
%
% fhlin@Oct. 30,2001



idx_value=ones(size(idx));
render_dipole_spot=0;
render_dipole_patch=1;
dec_dipole=[];
idx_color=[];
flag_patch='off';
flag_point='off';
flag_colorbar='off';
interp_onoff='off';
threshold=[];
point_idx=[];
point_dipole_idx=[];

if(nargin>3)
	for i=1:length(varargin)/2
		option_name=varargin{(i-1)*2+1};		
		option_value=varargin{i*2};

		switch lower(option_name)
		case 'idx_value'
			idx_value=option_value;
		case 'idx_color'
			idx_color=option_value;
		case 'dec_dipole'
			dec_dipole=option_value;
		case 'patch'
			flag_patch=option_value;
       	case 'point'
			flag_point=option_value;
		case 'point_idx'
			point_idx=option_value;
		case 'point_dipole_idx'
			point_dipole_idx=option_value;
       	case 'threshold'
       		if(length(option_value)==2)
       			threshold=[min(option_value), max(option_value)];
       		end;
       		if(length(option_value)==1)
      			threshold=[option_value];
       		end;
			if(length(option_value)>2)
				threshold=option_value;
			end;
		case 'interpolation'
   			interp_onoff=option_value;
		case 'flag_colorbar'
			flag_colorbar=option_value;
		otherwise
  	        fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
			return;
		end;
	end;
end;    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualization of brain mesh using Matlab functions
%
% load the brain patch for visualization
fprintf('loading brain patch...\n');
load(brain_patch_file,'face','vertex','curv','orig2patch_idx','patch2orig_idx','triangle');


if(isempty(threshold))
	threshold=min(idx_value);
end;

if(strcmp(lower(mode),'dec'))
    if(isempty(dec_dipole))
        fprintf('no decimated dipole defined!!\n');
        fprintf('error!\n\n');
        return;
    end;
    
    if((max(dec_dipole)==1)&(min(dec_dipole)==0))
        fprintf('input dec_dipole are [0/1] indicators.\n');
        dec_dipole=find(dec_dipole)-1;
    else
        fprintf('input dec_dipole are decimated dipole indices.\n');
        if(min(dec_dipole)==0)
            fprintf('0-based decimated dipole indices!\n');
        else
            fprintf('NOT 0-based decimated dipole indices!\n');
            fprintf('NO further process here!! Take cautions!!\n');
        end;
    end;

    fg_idx=orig2patch_idx(dec_dipole+1);
    fg_v=vertex(fg_idx+1,:);

    fg_data=zeros(size(fg_v,1),1);
    %if(min(idx)==0)
	%	fg_data(idx+1)=idx_value;
	%else
		fg_data(idx)=idx_value;
	%end;
end;


if(strcmp(lower(mode),'dip'))
    fg_idx=orig2patch_idx(idx+1);
    fg_v=vertex(fg_idx+1,:);

    fg_data=idx_value;
    if(size(fg_data,1)==1) fg_data=fg_data'; end;
end;


fg_color=[];
if(~isempty(idx_color))
    fg_color=zeros(size(fg_v,1),3);
    fg_color(idx,:)=idx_color;
end;

inverse_render_brain(vertex,face,...
        'fg_data',fg_data,...
        'fg_color',fg_color,...
        'fg_v',fg_v,...
        'threshold',threshold,...
        'bg_data',curv,...
        'dec_dipole',dec_dipole,...
        'interpolation',interp_onoff,...
        'fg_idx',fg_idx,...
        'point',flag_point,...
        'patch',flag_patch,...
		'point_idx',point_idx,...
		'point_dipole_idx',point_dipole_idx,...
		'flag_colorbar',flag_colorbar,...
        'triangle',triangle);

        
%control the display of axis label
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
set(gca,'zticklabel',[]);
% no grid; no axis
set(gca,'NextPlot','replace','Visible','off');
hold on;



		
return;
