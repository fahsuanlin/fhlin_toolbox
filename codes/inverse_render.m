function [varargout]=inverse_render(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defaults

process_id=1;
file_measure_mat='';
file_dip={};
file_dec={};
dipdec_format='mgh-nmr';
file_brain_patch={};
file_avi_output='';
file_quicktime_output='';
file_stc_output='';

flag_write_stc=0;
flag_render_stc=0;
flag_collapse_3to1=0;
flag_filter_dipole=0;		%assume no aposteriori filtering of dipole estimates


sample_time=[];
init_latency=[];

nperdip=[];

threshold=[];
stc_threshold=[];

render_hemisphere=[1 1];	%render both hemisphere
render_interval=[];		
render_window=[];
ma_window=[];

bg_weight=1;

view_angle={
	[-90,0],
	[90,0],
};

sample_time=[];
sample_unit=[];
show_sample_time='off';



dip={};
dec={};
W=[];
Y=[];
X=[];
x={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read-in parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(varargin)/2
	option=varargin{2*i-1};
	option_value=varargin{2*i};

	switch lower(option)
	case 'process_id'
		process_id=option_value;
	case 'flag_write_stc'
		flag_write_stc=option_value;
	case 'flag_render_stc'
		flag_render_stc=option_value;
	case 'flag_collapse_3to1'
		flag_collapse_3to1=option_value;
	case 'file_measure_mat'
		file_measure_mat=option_value;
	case 'file_brain_patch'
		file_brain_patch=option_value;
	case 'file_dip'
		file_dip=option_value;
	case 'file_dec'
		file_dec=option_value;
    case 'dipdec_format'
        dipdec_format=option_value;
	case 'file_stc_output'
		file_stc_output=option_value;
	case 'file_avi_output'
		file_avi_output=option_value;
	case 'file_quicktime_output'
		file_quicktime_output=option_value;
	case 'sample_time'
		sample_time=option_value;
	case 'init_latency'
		init_latency=option_value;
	case 'nperdip'
		nperdip=option_value;
	case 'threshold'
		threshold=option_value;
	case 'render_hemisphere'
		render_hemisphere=option_value;
	case 'render_interval'
		render_interval=option_value;
	case 'render_window'
		render_window=option_value;
	case 'ma_window'
		ma_window=option_value;
	case 'view_angle'
		view_angle=option_value;
	case 'w'
		W=option_value;
	case 'y'
		Y=option_value;
	case 'x'
		X=option_value;
    case 'bg_weight'
        bg_weight=option_value;
	case 'sample_unit'
		sample_unit=option_value;
	case 'show_sample_time'
        show_sample_time=option_value; %'on' or 'off'
	case 'sample_time'
		sample_time=option_value;
    otherwise
		fprintf('unknown option [%s]\n',option);
		return;
	end;
end;


if(isempty(ma_window))
	ma_window=render_window;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculation dipole estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(isempty(X))
	
	fprintf('\n\n%d. Calculating dipole estimates...\n',process_id);
	
	process_id=process_id+1;

	if(isempty(W))
		fprintf('ERROR!! NO INVERSE OPERATOR!!\n');
		fprintf('EXIT!\n');
		return;
	else
		if(~isempty(Y))		

			fprintf('estimating dipoles...\n');
			
			X=W*Y;
	
			elseif(~isempty(file_measure_mat))
			
			fprintf('loading measurement data...\n');
		
			tmp=load(file_measure_mat,'B');
		
			fprintf('estimating dipoles...\n');
		
			X=W*(tmp.B);
	
		else
			
			fprintf('CANNOT LOAD MEASUREMENT!!\n');
		
			fprintf('EXIT!!\n');

			return;
	
		end;

	end;

else

	fprintf('\n\nSKIP DIPOLE ESTIMATION!\n');
	
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collapse directional components
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(flag_collapse_3to1>0)
	%collapse 3 directional components into magnitude

	fprintf('\n\n%d. Collapsing 3 directional dipole componenets into magnitude...\n',process_id);

	process_id=process_id+1;				
				
	X=reshape(X,[3,size(X,1)/3,size(X,2)]);
						
	switch(flag_collapse_3to1)
	case 1				
		X=sqrt(squeeze(sum(abs(X).^2,1)));	%modulus of absolute values
	case 2
		X=squeeze(sum(abs(X).^2,1));		%power sum
	end;
		
	nperdip=1;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparing dipole info
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(isempty(dec))
	
	fprintf('\n\n%d. preparing dipole info...\n',process_id);

	process_id=process_id+1;				
	
	% dip and dec information
	for i=1:size(file_dip,1)
		[DIP{i},DEC{i}]=inverse_read_dipdec(file_dip{i}, file_dec{i},dipdec_format);
		dec{i}=find(DEC{i});
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writing STC file
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(flag_write_stc)
	
	fprintf('\n\n%d. Writing STC file...\n',process_id);
	
	process_id=process_id+1;
		
	if(isempty(sample_time))	
		if(~isempty(file_measure_mat))
			tmp=load(file_measure_mat,'sfreq');
			sample_time=1/(tmp.sfreq)*1000.0;	%sample period in msec
		end;
	end;

	if(isempty(init_latency))	
		if(~isempty(file_measure_mat))
			tmp=load(file_measure_mat,'t0');
			init_latency=(tmp.t0).*1000.0;		%MEG recording initial latency
		end;
	end;
			
	fprintf('Sampling period = [%3.3f] msec\n', sample_time);
	fprintf('Init latency = [%3.3f] msec\n', init_latency);

	if(flag_filter_dipole)
		%fprintf('\nFiltering dipole estimates using a band pass filter between %s (Hz)...\n',mat2str(dipole_filter));
		%x=inverse_filter(x,dipole_filter,dipole_filter_width, 1/sample_time.*1000);
	end;

	if(isempty(file_stc_output))
		file_stc=sprintf('inverse_render_%s.stc',date);
		fprintf('writing STC [%s]...\n',file_stc);
	end;

	inverse_write_stc(X,dec{i}-1,init_latency,sample_time,file_stc); 

else
	
	fprintf('\n\nSKIP WRITING STC FILE!\n');

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%

% render STC 

%%%%%%%%%%%%%%%%%%%%%%%%%%%



if(flag_render_stc)
	
	fprintf('\n\n%d. Render STC...\n',process_id);
	
	process_id=process_id+1;
	
	fprintf('separating whole brain estimates into hemispheres...\n');
	if(isempty(nperdip))
		fprintf('nperdip must be specified!!\n ERROR!!\n');
		return;
	end;

	offset=0;
	for i=1:length(dec)
		x{i}=X(offset*nperdip+1:offset*nperdip+length(dec{i})*nperdip,:);

		offset=offset+length(dec{i});
	end;
	
	if(isempty(render_interval))
		render_interval=[1:size(x{1},2)];
	end;
	
	if(isempty(render_window))
		render_window=1;
	end;

	for i=1:length(render_hemisphere)
		if((render_hemisphere(i))&(~isempty(file_brain_patch{i})))
			stc=x{i};
 		    stc=stc(:,render_interval);
			
			if(render_window~=1)
				if(render_window<1) %collapsing in seconds
					render_window=round(render_window./mean(diff(sample_time./1000.0)));
				end;

			  	if(ma_window<1) %collapsing in seconds
				    ma_window=round(ma_window./mean(diff(sample_time./1000.0)));
				end;
													
				ss=[];
				for j=1:ceil(length(render_interval)/render_window)
					if((j-1)*render_window+ma_window<size(stc,2))
						ss(:,j)=mean(stc(:,(j-1)*render_window+1:(j-1)*render_window+ma_window),2);
						time_stamp(j)=mean(sample_time((j-1)*render_window+1:(j-1)*render_window+ma_window));
					else
						ss(:,j)=mean(stc(:,(j-1)*render_window+1:end),2);
						time_stamp(j)=mean(sample_time((j-1)*render_window+1:end));
					end;
				end;

			else
				ss=stc;
			end;
			

			if(isempty(file_avi_output))
				fn_avi='';
            else
       			fn_avi=sprintf('%s_%02d.avi',file_avi_output,i);
            end;
	

  			if(isempty(file_quicktime_output))
				fn_quicktime='';
            else
       			fn_quicktime=sprintf('%s_%02d.qt',file_quicktime_output,i);
            end;

			fprintf('begin rendering...\n');
			inverse_render_stc(file_brain_patch{i},ss,dec{i}-1,threshold,dec{i}-1,...
                'avi_output_file',fn_avi,...
                'quicktime_output_file',fn_quicktime,...
                'view_angle',view_angle{i},...
                'grid','off',...
                'threshold',threshold,...
                'bg_weight',bg_weight,...
                'sample_time',time_stamp,...
                'sample_unit',sample_unit,...
                'show_sample_time',show_sample_time);
		end;
	end;
else
	
	fprintf('\n\nSKIP STC RENDERING!\n');

end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preparation of output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~isempty(X))
	varargout{1}=X;
	output_count=1;
	fprintf('output[%d]--> dipole estimates of all [A]\n',output_count);
	output_count=output_count+1;
end;

if(~isempty(x))
	varargout{2}=x;
	fprintf('output[%d]--> dipole estimates for hemispheres\n',output_count);
	output_count=output_count+1;
end;




fprintf('\nINVERSE RENDER DONE!!\n');
