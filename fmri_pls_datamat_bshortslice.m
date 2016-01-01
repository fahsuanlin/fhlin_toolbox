function [datamat,coords,x,y,pls_struct]=fmri_pls_datamat_bshortslice(datafile,datamat_struct,threshold,flags,varargin)
%fmri_pls_datamat_bshortslice 	generate the datamat for the PLS analysis of functional data
%
%[datamat,coords,x,y]=fmri_pls_datamat(datafile,datamat_struct,tasks,subjects,slices,threshold,flag,time_idx)
%
%datafile: all bshort data files, must be arranged in tasks->subjects->slices
%tasks: number of tasks
%subjects: number of subjects
%slices: number of slices
%threshold: the threshold to disgard the unnecessary voxels; 0 using the default-1/7 of the maximail value
%flag: 1D control flag
%	flag(1)==1	linearly detrending
%	flag(2)==1	linearly scaling row by row (0~1)
%	flag(3)==1	linearly scaling col by col (0~1)
%	flag(4)==1	removing mean row by row
%	flag(5)==1	removing mean col by col
%	flag(6)==1	normalize slice of the same timepoint within subject across tasks
%	flag(7)==1	joint of voxels across slice included for datamat (default)
%	flag(7)==2	union of voxels across slice included for datamat
%time_idx: the indices for time point to be included to construct datamat, default: all time points
%
%written by fhlin@feb, 06 2000

[files,dummy]=size(datafile);
fn=char(datafile);
clear datafile;


%
%reading data files
%
str=sprintf('reading raw data...');
disp(str);

tasks=size(datamat_struct,1);
subjects=size(datamat_struct,2);

%
%preparing for reading data files
%
fn_idx=1;
totaltime=0;
for i=1:subjects
	buffer=fmri_ldbfile(fn(fn_idx,:));
   	fn_idx=fn_idx+datamat_struct(1,i);
   	[y,x,timepoints]=size(buffer);
   	if nargin==4
   	
		totaltime=totaltime+timepoints;
	else
		totaltime=totaltime+length(varargin{1});
	end;

   	img_struct(:,i)=[x,y,timepoints]';
   	str=sprintf('subject[%d] X=%d Y=%d timepoints=%d',i,x,y,timepoints);
   	disp(str);
end;
clear buffer;

max_x=max(img_struct(1,:));
max_y=max(img_struct(2,:));
max_timepoints=max(img_struct(3,:));

%reading data files and putting into datamat
fn_idx=1;
t_idx=1;
%zz=zeros(60,64*64*46);
if(size(fn,1)==sum(sum(datamat_struct)))
	for i=1:tasks
		for j=1:subjects
			for k=1:datamat_struct(i,j)
   			        str=sprintf('reading [%s]...',fn(fn_idx+k-1,:));
				disp(str);
	
				buffer=fmri_ldbfile(fn(fn_idx+k-1,:));
				
				if nargin==4
					time_idx=[1:img_struct(3,j)];
				else
					%time_idx=varargin{1};
				end;
				buffer=buffer(:,:,time_idx);
				
				buffer=reshape(buffer,[img_struct(1,j)*img_struct(2,j),length(time_idx)])';
				pls_struct(i,j)=length(time_idx);
				
								         			
         			datamatin(t_idx:t_idx+length(time_idx)-1,(k-1)*img_struct(1,j)*img_struct(2,j)+1:k*img_struct(1,j)*img_struct(2,j))=buffer;
         			%zz(t_idx:t_idx+length(time_idx)-1,(k-1)*img_struct(1,j)*img_struct(2,j)+1:k*img_struct(1,j)*img_struct(2,j))=1;
         			%imagesc(zz);
         			%pause;
         		end;
       			fn_idx=fn_idx+datamat_struct(i,j);
       			t_idx=t_idx+length(time_idx);
  		end;
	end;
end;


str=sprintf('generating datamat...');
disp(str);

if(length(flag)==6)
	datamat_switch=1;
else
	datamat_switch=flag(7);
end;
[datamat coords]=makedata_raw(datamatin,threshold,datamat_switch); %making the datamat
slices=max(max(datamat_struct));
show_datamat(coords,y,x,slices); %show the datamat

%
%detrending
%
if(flags(1)==1)
	disp('detrending within task....');
	for t=1:tasks
		datamat((t-1)*totaltime+1:t*totaltime,:)=detrend(datamat((t-1)*totaltime+1:t*totaltime,:));
	end;
end;


%
%linearly scale rows by rows
%
if(flags(2)==1)
	disp('linearly scaling row by row...');
	for i=1:size(datamat,1)
		datamat(i,:)=fmri_scale(datamat(i,:),1,0);
	end;
end;

%
%linearly scale cols by cols
%
if(flags(3)==1)
	disp('linearly scaling col by col...');
	for i=1:size(datamat,2)
		datamat(:,i)=fmri_scale(datamat(:,i),1,0);
	end;
end;

%
%removing mean rows by rows
%
if(flags(4)==1)
	disp('removing mean at each time point (row by row)...');
	datamat=datamat-mean(datamat,2)*ones(1,size(datamat,2));
end;


%
%remove the mean of the (task-subj)  col by col
%
if(flags(5)==1)
	disp('removing mean within task within subject (col by col)...');
	for i=1:tasks
		for j=1:subjects
			time_offset=0;
   		for tos=1:j-1
   				time_offset=time_offset+allsize(tos,3);
	   	end;
			all_time=sum(allsize(:,3),1);
   		time_offset=time_offset+(i-1)*all_time;
         
      	mm=mean(mean(datamatin(time_offset+1:time_offset+allsize(j,3),:)));
      	datamatin(time_offset+1:time_offset+allsize(j,3),:)=datamatin(time_offset+1:time_offset+allsize(j,3),:)-mm;
      end;
	end;
end;


%
%normalize based on time point (row by row) across tasks for the same subject
%

%before=datamat;
if(flags(6)==1)
	for i=1:subjects
		for j=1:allsize(i,3)
			clear t;
			for k=1:tasks
				t(k)=j+(k-1)*totaltime;
			end;
			d1=mean(datamat(t,:),2);
			d2=mean(d1);
			d3=d1-d2;
			vv(j)=var(d3);
			datamat(t,:)=datamat(t,:)-d3*ones(1,size(datamat,2));
		end;
	end;
end;

str=sprintf('generating datamat done!');
disp(str);
