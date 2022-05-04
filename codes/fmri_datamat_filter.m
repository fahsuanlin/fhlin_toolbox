function [datamat]=fmri_datamat_filter(datamat,datamat_struct,flags)
%fmri_datamat_filter 	generate the datamat for the PLS analysis of functional data
%
%[datamat]=fmri_pls_datamat(datamat,datamat_struct,flag)
%
%datamat: 2D spatiotemporal data matrix
%datamat_threshold: the threshold to disgard the unnecessary voxels; 0 using the default-1/7 of the maximail value
%flag: 1D control flag
%	flag(1)==1	linearly detrending
%	flag(2)==1	linearly scaling row by row (0~1)
%	flag(3)==1	linearly scaling col by col (0~1)
%	flag(4)==1	removing mean row by row
%	flag(5)==1	removing mean col by col
%	flag(6)==1	normalize slice of the same timepoint within subject across tasks
%
%written by fhlin@feb, 22 2000

tasks=size(datamat_struct,1);
subjects=size(datamat_struct,2);
time=sum(datamat_struct,2);
totaltime=time(1);

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
	task_time=sum(datamat_struct,1);
	
	for i=1:tasks
	
		task_offset=0;
		if(i>1)
			task_offset=task_time(i-1);
		end;
		
		subject_time=datamat_struct(i,:);
		
		for j=1:subjects
				
			subject_offset=0;
   			for tos=1:j-1
   				subject_offset=subject_offset+subject_time(tos);
	   		end;
	   		time_span=subject_time(j);
					
   			time_offset=task_offset+subject_offset;
         
               		m=ones(time_span,1)*mean(datamat(time_offset+1:time_offset+time_span,:));
      			datamat(time_offset+1:time_offset+time_span,:)=datamatin(time_offset+1:time_offset+time_span,:)-m;
      		end;
	end;
end;


%
%normalize based on time point (row by row) across tasks for the same subject
%
if(flags(6)==1)
	disp('no filtering for this flag (flag(6)=1)!');
end;

str=sprintf('datamat filtered!');
disp(str);
